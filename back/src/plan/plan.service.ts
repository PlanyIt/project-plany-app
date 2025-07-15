import {
  Injectable,
  NotFoundException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { PlanDto } from './dto/plan.dto';
import { InjectConnection, InjectModel } from '@nestjs/mongoose';
import { Plan, PlanDocument } from './schemas/plan.schema';
import { Connection, Types, isValidObjectId } from 'mongoose';
import { Model } from 'mongoose';
import { StepService } from '../step/step.service';
import { Step, StepDocument } from 'src/step/schemas/step.schema';
import { Comment, CommentDocument } from 'src/comment/schemas/comment.schema';

/**
 * Service de gestion des plans de sortie
 *
 * Gère les opérations CRUD sur les plans, incluant :
 * - Création avec calcul automatique des coûts et durées
 * - Gestion des favoris et de la visibilité
 * - Relations avec les utilisateurs et les étapes
 * - Statistiques et métriques
 *
 * @author Équipe Plany
 * @version 1.0.0
 */
@Injectable()
export class PlanService {
  constructor(
    @InjectModel(Plan.name) private planModel: Model<PlanDocument>,
    @InjectModel(Step.name) private stepModel: Model<StepDocument>,
    @InjectModel(Comment.name) private commentModel: Model<CommentDocument>,
    @InjectConnection() private connection: Connection,
    @Inject(forwardRef(() => StepService))
    private stepService: StepService,
  ) {}

  /**
   * Crée un nouveau plan avec calcul automatique des totaux
   *
   * Calcule automatiquement le coût total et la durée totale
   * en fonction des étapes associées au plan.
   *
   * @param createPlanDto - Données du plan à créer
   * @returns Plan créé avec toutes les relations populées
   * @throws {Error} Si une erreur survient lors de la création
   *
   * @example
   * ```typescript
   * const plan = await planService.createPlan({
   *   title: 'Sortie Paris',
   *   description: 'Une journée à Paris',
   *   user: userId,
   *   category: categoryId,
   *   steps: [stepId1, stepId2],
   *   isPublic: true
   * });
   * ```
   */
  async createPlan(createPlanDto: PlanDto): Promise<PlanDocument> {
    const stepIds = createPlanDto.steps.map((stepId) => stepId.toString());

    const totalCost = await this.stepService.calculateTotalCost(stepIds);
    const totalDuration =
      await this.stepService.calculateTotalDuration(stepIds);

    const createdPlan = new this.planModel({
      ...createPlanDto,
      totalCost,
      totalDuration,
    });

    const savedPlan = await createdPlan.save();

    return this.planModel
      .findById(savedPlan._id)
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();
  }

  /**
   * Récupère tous les plans publics
   *
   * Retourne uniquement les plans marqués comme publics,
   * triés par nombre de favoris (popularité).
   *
   * @returns Liste des plans publics avec relations populées
   */
  async findAll(): Promise<PlanDocument[]> {
    return this.planModel
      .find({ isPublic: true })
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ favorites: -1 })
      .exec();
  }

  /**
   * Récupère un plan par son ID
   *
   * @param planId - ID du plan à récupérer
   * @returns Plan avec toutes les relations populées
   * @throws {NotFoundException} Si l'ID n'est pas valide ou le plan n'existe pas
   */
  async findById(planId: string): Promise<PlanDocument | undefined> {
    if (!isValidObjectId(planId)) {
      throw new NotFoundException(
        `Plan with ID ${planId} is not a valid ObjectId`,
      );
    }
    return this.planModel
      .findById(planId)
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();
  }

  /**
   * Met à jour un plan existant
   *
   * Recalcule automatiquement les totaux si les étapes sont modifiées.
   * Vérifie que l'utilisateur est propriétaire du plan.
   *
   * @param planId - ID du plan à mettre à jour
   * @param updatePlanDto - Données de mise à jour
   * @param userId - ID de l'utilisateur (vérification propriétaire)
   * @returns Plan mis à jour avec relations populées
   */
  async updateById(
    planId: string,
    updatePlanDto: PlanDto,
    userId: string,
  ): Promise<PlanDocument> {
    if (updatePlanDto.steps) {
      const stepIds = updatePlanDto.steps.map((stepId) => stepId.toString());
      updatePlanDto.totalCost =
        await this.stepService.calculateTotalCost(stepIds);
      updatePlanDto.totalDuration =
        await this.stepService.calculateTotalDuration(stepIds);
    }

    return this.planModel
      .findOneAndUpdate({ _id: planId, user: userId }, updatePlanDto, {
        new: true,
      })
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();
  }

  /**
   * Supprime un plan et toutes ses données associées
   *
   * Effectue une suppression en cascade pour maintenir l'intégrité :
   * - Supprime tous les steps du plan
   * - Supprime tous les commentaires sur le plan
   * - Retire le plan des favoris de tous les utilisateurs (automatique)
   *
   * @param planId - ID du plan à supprimer
   * @param userId - ID de l'utilisateur (vérification propriétaire)
   * @returns Plan supprimé
   * @throws {NotFoundException} Si le plan n'existe pas ou n'appartient pas à l'utilisateur
   */
  async removeById(planId: string, userId: string): Promise<PlanDocument> {
    // Utiliser une transaction pour garantir la cohérence
    const session = await this.connection.startSession();

    try {
      return await session.withTransaction(async () => {
        // 1. Vérifier que le plan existe et appartient à l'utilisateur
        const plan = await this.planModel
          .findOne({ _id: planId, user: userId })
          .session(session);

        if (!plan) {
          throw new NotFoundException(`Plan not found or not owned by user`);
        }

        // 2. Supprimer tous les steps associés à ce plan
        if (plan.steps && plan.steps.length > 0) {
          await this.stepModel
            .deleteMany({
              _id: { $in: plan.steps },
            })
            .session(session);
        }

        // 3. Supprimer tous les commentaires sur ce plan
        await this.commentModel
          .deleteMany({
            planId: planId,
          })
          .session(session);

        // 4. Supprimer le plan
        const deletedPlan = await this.planModel
          .findOneAndDelete({ _id: planId, user: userId })
          .session(session);

        return deletedPlan;
      });
    } finally {
      await session.endSession();
    }
  }
  /**
   * Ajoute un plan aux favoris d'un utilisateur
   *
   * @param planId - ID du plan à ajouter aux favoris
   * @param userId - ID de l'utilisateur
   * @returns Plan mis à jour
   * @throws {NotFoundException} Si le plan n'existe pas
   */
  async addToFavorites(planId: string, userId: string): Promise<PlanDocument> {
    const plan = await this.planModel.findById(planId);
    if (!plan) {
      throw new NotFoundException(`Plan with ID ${planId} not found`);
    }

    if (plan.favorites === null) {
      await this.planModel.updateOne(
        { _id: planId },
        { $set: { favorites: [] } },
      );
    }

    return this.planModel.findByIdAndUpdate(
      planId,
      { $addToSet: { favorites: userId } },
      { new: true },
    );
  }

  /**
   * Retire un plan des favoris d'un utilisateur
   *
   * @param planId - ID du plan à retirer des favoris
   * @param userId - ID de l'utilisateur
   * @returns Plan mis à jour
   * @throws {NotFoundException} Si le plan n'existe pas
   */
  async removeFromFavorites(
    planId: string,
    userId: string,
  ): Promise<PlanDocument> {
    const plan = await this.planModel.findById(planId);
    if (!plan) {
      throw new NotFoundException(`Plan with ID ${planId} not found`);
    }
    if (plan.favorites === null) {
      return plan;
    }

    return this.planModel.findByIdAndUpdate(
      planId,
      { $pull: { favorites: userId } },
      { new: true },
    );
  }

  /**
   * Récupère tous les plans d'un utilisateur
   *
   * Si l'utilisateur consulte ses propres plans, retourne tous les plans (publics et privés).
   * Sinon, retourne uniquement les plans publics.
   *
   * @param userId - ID de l'utilisateur propriétaire des plans
   * @param viewerId - ID de l'utilisateur qui consulte (optionnel)
   * @returns Liste des plans de l'utilisateur
   */
  async findAllByUserId(
    userId: string,
    viewerId?: string,
  ): Promise<PlanDocument[]> {
    const userObjectId = new Types.ObjectId(userId);
    const query: any = { user: userObjectId };

    const isOwner = viewerId?.toString() === userId.toString();
    if (!isOwner) {
      query.isPublic = true;
    }

    return this.planModel
      .find(query)
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ createdAt: -1 })
      .exec();
  }

  /**
   * Récupère les plans favoris d'un utilisateur
   *
   * @param userId - ID de l'utilisateur
   * @returns Liste des plans favoris
   */
  async findFavoritesByUserId(userId: string): Promise<PlanDocument[]> {
    return this.planModel
      .find({ favorites: userId })
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ createdAt: -1 })
      .exec();
  }
}
