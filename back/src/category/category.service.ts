import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Category, CategoryDocument } from './schemas/category.schema';
import { CategoryDto } from './dto/category.dto';
import { Plan, PlanDocument } from '../plan/schemas/plan.schema';

/**
 * Service de gestion des catégories de plans
 *
 * Gère les opérations CRUD sur les catégories utilisées pour classifier
 * les plans de sortie (Restaurant, Culture, Shopping, etc.).
 * Les catégories permettent aux utilisateurs de filtrer et organiser leurs plans.
 *
 * @author Équipe Plany
 * @version 1.0.0
 */
@Injectable()
export class CategoryService {
  constructor(
    @InjectModel(Category.name) private categoryModel: Model<CategoryDocument>,
    @InjectModel(Plan.name) private planModel: Model<PlanDocument>,
  ) {}

  /**
   * Crée une nouvelle catégorie
   *
   * @param createCategoryDto - Données de la catégorie à créer (nom, icône, couleur)
   * @returns Catégorie créée avec son ID généré
   * @throws {MongoError} Si le nom de catégorie existe déjà (contrainte unique)
   *
   * @example
   * ```typescript
   * const category = await categoryService.create({
   *   name: 'Restaurant',
   *   icon: 'utensils',
   *   color: '#FF6B6B'
   * });
   * ```
   */
  async create(createCategoryDto: CategoryDto): Promise<CategoryDocument> {
    const newCategory = new this.categoryModel(createCategoryDto);
    return newCategory.save();
  }

  /**
   * Récupère toutes les catégories disponibles
   *
   * @returns Liste de toutes les catégories triées par ordre de création
   */
  async findAll(): Promise<CategoryDocument[]> {
    return this.categoryModel.find().exec();
  }

  /**
   * Récupère une catégorie par son ID
   *
   * @param categoryId - ID de la catégorie à récupérer
   * @returns Catégorie trouvée ou undefined si inexistante
   */
  async findById(categoryId: string): Promise<CategoryDocument | undefined> {
    return this.categoryModel.findOne({ _id: categoryId }).exec();
  }

  /**
   * Récupère une catégorie par son nom
   *
   * Utile pour vérifier l'existence d'une catégorie ou pour la recherche.
   *
   * @param name - Nom de la catégorie à rechercher
   * @returns Catégorie trouvée ou undefined si inexistante
   *
   * @example
   * ```typescript
   * const restaurant = await categoryService.findByName('Restaurant');
   * ```
   */
  async findByName(name: string): Promise<CategoryDocument | undefined> {
    return this.categoryModel.findOne({ name }).exec();
  }

  /**
   * Met à jour une catégorie existante
   *
   * @param categoryId - ID de la catégorie à mettre à jour
   * @param updateCategoryDto - Nouvelles données de la catégorie
   * @returns Catégorie mise à jour ou null si inexistante
   *
   * @example
   * ```typescript
   * const updated = await categoryService.updateById('64f...', {
   *   name: 'Fine Dining',
   *   icon: 'wine-glass',
   *   color: '#8B4513'
   * });
   * ```
   */
  async updateById(
    categoryId: string,
    updateCategoryDto: CategoryDto,
  ): Promise<CategoryDocument | null> {
    return this.categoryModel
      .findOneAndUpdate({ _id: categoryId }, updateCategoryDto, {
        new: true,
      })
      .exec();
  }

  /**
   * Supprime une catégorie par son ID
   *
   * Vérifie d'abord qu'aucun plan n'utilise cette catégorie avant de la supprimer.
   * Cette vérification garantit l'intégrité référentielle des données.
   *
   * @param categoryId - ID de la catégorie à supprimer
   * @returns Catégorie supprimée ou null si inexistante
   * @throws {BadRequestException} Si des plans utilisent encore cette catégorie
   */
  async removeById(categoryId: string): Promise<CategoryDocument | null> {
    // Vérifier si des plans utilisent cette catégorie
    const plansUsingCategory = await this.planModel
      .countDocuments({
        category: categoryId,
      })
      .exec();

    if (plansUsingCategory > 0) {
      throw new BadRequestException(
        `Impossible de supprimer cette catégorie. ${plansUsingCategory} plan(s) l'utilise(nt) encore.`,
      );
    }

    return this.categoryModel.findOneAndDelete({ _id: categoryId }).exec();
  }
}
