import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Step, StepDocument } from './schemas/step.schema';
import { StepDto } from './dto/step.dto';

/**
 * Service de gestion des étapes de plan
 *
 * Gère les opérations CRUD sur les étapes et les calculs de métriques.
 * Les étapes représentent les différentes activités d'un plan de sortie.
 *
 * @author Équipe Plany
 * @version 1.0.0
 */
@Injectable()
export class StepService {
  constructor(
    @InjectModel(Step.name) private stepModel: Model<StepDocument>,
    @InjectModel('Plan') private planModel: Model<any>,
  ) {}

  /**
   * Crée une nouvelle étape
   *
   * @param createStepDto - Données de l'étape à créer
   * @returns Étape créée
   */
  async create(createStepDto: StepDto): Promise<StepDocument> {
    const newStep = new this.stepModel(createStepDto);
    return newStep.save();
  }

  /**
   * Récupère toutes les étapes
   *
   * @returns Liste de toutes les étapes
   */
  async findAll(): Promise<StepDocument[]> {
    return this.stepModel.find().exec();
  }

  /**
   * Récupère une étape par son ID
   *
   * @param stepId - ID de l'étape
   * @returns Étape trouvée ou undefined
   */
  async findById(stepId: string): Promise<StepDocument | undefined> {
    const step = await this.stepModel.findOne({ _id: stepId }).exec();
    if (!step) {
      return undefined;
    }
    return step;
  }

  /**
   * Récupère plusieurs étapes par leurs IDs
   *
   * Retourne les étapes triées par ordre croissant.
   *
   * @param stepIds - Tableau des IDs d'étapes
   * @returns Liste des étapes trouvées, triées par ordre
   */
  async findByIds(stepIds: string[]): Promise<StepDocument[]> {
    return this.stepModel
      .find({ _id: { $in: stepIds } })
      .sort({ order: 1 })
      .exec();
  }

  /**
   * Met à jour une étape
   *
   * @param stepId - ID de l'étape à mettre à jour
   * @param updateStepDto - Données de mise à jour
   * @param userId - ID de l'utilisateur (vérification propriétaire)
   * @returns Étape mise à jour ou null
   */
  async updateById(
    stepId: string,
    updateStepDto: StepDto,
    userId: string,
  ): Promise<StepDocument | null> {
    return this.stepModel
      .findOneAndUpdate({ _id: stepId, userId }, updateStepDto, {
        new: true,
      })
      .exec();
  }

  /**
   * Supprime une étape
   *
   * Met également à jour tous les plans qui référencent cette étape.
   *
   * @param stepId - ID de l'étape à supprimer
   * @returns Étape supprimée ou null
   */
  async removeById(stepId: string): Promise<StepDocument | null> {
    const step = await this.stepModel.findOneAndDelete({ _id: stepId }).exec();

    if (step) {
      await this.planModel.updateMany(
        { steps: stepId },
        { $pull: { steps: stepId } },
      );
    }

    return step;
  }

  /**
   * Calcule le coût total d'une liste d'étapes
   *
   * @param stepIds - Tableau des IDs d'étapes
   * @returns Coût total en euros
   *
   * @example
   * ```typescript
   * const total = await stepService.calculateTotalCost(['step1', 'step2']);
   * console.log(`Coût total: ${total}€`);
   * ```
   */
  async calculateTotalCost(stepIds: string[]): Promise<number> {
    const steps = await this.findByIds(stepIds);
    return steps.reduce((total, step) => total + (step.cost || 0), 0);
  }

  /**
   * Calcule la durée totale d'une liste d'étapes
   *
   * @param stepIds - Tableau des IDs d'étapes
   * @returns Durée totale en minutes
   *
   * @example
   * ```typescript
   * const duration = await stepService.calculateTotalDuration(['step1', 'step2']);
   * console.log(`Durée totale: ${duration} minutes`);
   * ```
   */
  async calculateTotalDuration(stepIds: string[]): Promise<number> {
    const steps = await this.findByIds(stepIds);
    return steps.reduce((total, step) => {
      if (!step.duration) return total;
      return total + step.duration;
    }, 0);
  }
}
