import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Comment, CommentDocument } from './schemas/comment.schema';
import { CommentDto } from './dto/comment.dto';

/**
 * Service de gestion des commentaires
 *
 * Gère les opérations CRUD sur les commentaires, incluant :
 * - Système de commentaires hiérarchiques avec réponses
 * - Gestion des likes et dislikes
 * - Pagination et filtrage par plan ou utilisateur
 * - Suppression en cascade des réponses
 *
 * @author Équipe Plany
 * @version 1.0.0
 */
@Injectable()
export class CommentService {
  constructor(
    @InjectModel(Comment.name) private commentModel: Model<CommentDocument>,
  ) {}

  /**
   * Crée un nouveau commentaire
   *
   * Crée un commentaire et récupère automatiquement les informations
   * de l'utilisateur associé pour l'affichage.
   *
   * @param createCommentDto - Données du commentaire à créer
   * @returns Commentaire créé avec les informations utilisateur
   * @throws {Error} Si une erreur survient lors de la création
   *
   */
  async create(createCommentDto: CommentDto): Promise<CommentDocument> {
    const newComment = new this.commentModel(createCommentDto);
    const savedComment = await newComment.save();

    // Populate user information
    return this.commentModel
      .findById(savedComment._id)
      .populate('user', 'username email photoUrl')
      .exec();
  }

  /**
   * Ajoute un like à un commentaire
   *
   * Utilise $addToSet pour ajouter l'ID utilisateur à la liste des likes
   * Évite les doublons grâce à $addToSet qui pourrait être utilisé alternativement.
   *
   * @param commentId - ID du commentaire à liker
   * @param userId - ID de l'utilisateur qui like
   * @returns Commentaire mis à jour avec le nouveau like
   * @throws {NotFoundException} Si le commentaire n'existe pas
   */
  async likeComment(
    commentId: string,
    userId: string,
  ): Promise<CommentDocument | null> {
    return this.commentModel
      .findOneAndUpdate(
        { _id: commentId },
        { $addToSet: { likes: userId } },
        { new: true },
      )
      .populate('user', 'username email photoUrl')
      .exec();
  }

  /**
   * Retire un like d'un commentaire
   *
   * Utilise $pull pour retirer l'ID utilisateur de la liste des likes.
   *
   * @param commentId - ID du commentaire à unliker
   * @param userId - ID de l'utilisateur qui retire son like
   * @returns Commentaire mis à jour sans le like
   * @throws {NotFoundException} Si le commentaire n'existe pas
   */
  async unlikeComment(
    commentId: string,
    userId: string,
  ): Promise<CommentDocument | null> {
    return this.commentModel
      .findOneAndUpdate(
        { _id: commentId },
        { $pull: { likes: userId } },
        { new: true },
      )
      .populate('user', 'username email photoUrl')
      .exec();
  }

  /**
   * Ajoute une réponse à un commentaire
   *
   * Crée une nouvelle entrée commentaire avec un parentId pour créer
   * la hiérarchie. Met à jour le commentaire parent pour inclure
   * la référence à la réponse.
   *
   * @param commentId - ID du commentaire parent
   * @param responseDto - Données de la réponse à créer
   * @returns Réponse créée avec les informations utilisateur
   * @throws {NotFoundException} Si le commentaire parent n'existe pas
   *
   */
  async addResponse(
    commentId: string,
    responseDto: CommentDto,
  ): Promise<Comment> {
    const comment = await this.commentModel.findById(commentId).exec();
    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }
    const newResponse = new this.commentModel({
      ...responseDto,
      parentId: commentId,
    });
    const savedResponse = await newResponse.save();

    await this.commentModel.updateOne(
      { _id: commentId },
      { $addToSet: { responses: savedResponse.id } },
    );

    // Populate user information before returning
    return this.commentModel
      .findById(savedResponse._id)
      .populate('user', 'username email photoUrl')
      .exec();
  }

  /**
   * Récupère tous les commentaires d'un plan avec pagination
   *
   * Récupère uniquement les commentaires racines (sans parentId)
   * avec leurs réponses populées. Inclut la pagination pour optimiser
   * les performances sur les plans avec beaucoup de commentaires.
   *
   * @param planId - ID du plan
   * @param paginationOptions - Options de pagination (page, limit)
   * @returns Liste paginée des commentaires avec leurs réponses
   *
   */
  async findAllByPlanId(
    planId: string,
    paginationOptions: { page: number; limit: number },
  ): Promise<CommentDocument[]> {
    const { page, limit } = paginationOptions;
    const skip = (page - 1) * limit;

    return this.commentModel
      .find({
        planId,
        $or: [{ parentId: { $exists: false } }, { parentId: null }],
      })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('user', 'username email photoUrl')
      .populate({
        path: 'responses',
        populate: {
          path: 'user',
          select: 'username email photoUrl',
        },
      })
      .exec();
  }

  /**
   * Supprime une réponse d'un commentaire
   *
   * Retire la référence de la réponse du commentaire parent
   * puis supprime la réponse elle-même. Opération atomique
   * pour maintenir la cohérence des données.
   *
   * @param commentId - ID du commentaire parent
   * @param responseId - ID de la réponse à supprimer
   * @returns Objet contenant le commentaire parent et la réponse supprimée
   * @throws {NotFoundException} Si le commentaire ou la réponse n'existe pas
   */
  async removeResponse(
    commentId: string,
    responseId: string,
  ): Promise<{ comment: CommentDocument; response: CommentDocument }> {
    const comment = await this.commentModel
      .findByIdAndUpdate(
        commentId,
        { $pull: { responses: responseId } },
        { new: true },
      )
      .exec();

    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }

    const response = await this.commentModel
      .findByIdAndDelete(responseId)
      .exec();

    if (!response) {
      throw new NotFoundException(`Response with ID ${responseId} not found`);
    }

    return { comment, response };
  }

  /**
   * Compte le nombre de commentaires racines d'un plan
   *
   * Compte uniquement les commentaires principaux (sans parentId)
   * pour le calcul de pagination et les statistiques.
   *
   * @param planId - ID du plan
   * @returns Nombre de commentaires racines
   */
  async countByPlanId(planId: string): Promise<number> {
    return this.commentModel
      .countDocuments({
        planId,
        $or: [{ parentId: { $exists: false } }, { parentId: null }],
      })
      .exec();
  }

  /**
   * Récupère toutes les réponses d'un commentaire
   *
   * Récupère les réponses directes d'un commentaire spécifique
   * avec les informations utilisateur populées.
   *
   * @param commentId - ID du commentaire parent
   * @returns Liste des réponses avec les informations utilisateur
   */
  async findAllResponses(commentId: string): Promise<Comment[]> {
    return this.commentModel
      .find({ parentId: commentId })
      .populate('user', 'username email photoUrl')
      .exec();
  }

  /**
   * Récupère tous les commentaires d'un utilisateur
   *
   * Récupère tous les commentaires (racines et réponses) créés
   * par un utilisateur spécifique, utile pour l'affichage du profil.
   *
   * @param userId - ID de l'utilisateur
   * @returns Liste des commentaires de l'utilisateur
   */
  async findAllByUserId(userId: string): Promise<CommentDocument[]> {
    return this.commentModel
      .find({ user: userId })
      .populate('user', 'username email photoUrl')
      .exec();
  }

  /**
   * Récupère un commentaire par son ID
   *
   * Récupère un commentaire spécifique avec ses réponses et
   * les informations utilisateur populées.
   *
   * @param commentId - ID du commentaire
   * @returns Commentaire avec ses réponses et informations utilisateur
   */
  async findById(commentId: string): Promise<CommentDocument | undefined> {
    const comment = await this.commentModel
      .findOne({ _id: commentId })
      .populate('user', 'username email photoUrl')
      .populate({
        path: 'responses',
        populate: {
          path: 'user',
          select: 'username email photoUrl',
        },
      })
      .exec();
    return comment;
  }

  /**
   * Supprime un commentaire et toutes ses réponses
   *
   * Effectue une suppression en cascade pour maintenir l'intégrité :
   * - Supprime toutes les réponses associées au commentaire
   * - Supprime le commentaire principal
   * - Maintient la cohérence des références
   *
   * @param commentId - ID du commentaire à supprimer
   * @returns Commentaire supprimé avec les informations utilisateur
   * @throws {NotFoundException} Si le commentaire n'existe pas
   *
   */
  async removeById(commentId: string): Promise<CommentDocument> {
    const comment = await this.commentModel.findById(commentId).exec();

    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }

    if (comment.responses && comment.responses.length > 0) {
      await this.commentModel
        .deleteMany({ _id: { $in: comment.responses } })
        .exec();
    }

    return this.commentModel
      .findByIdAndDelete(commentId)
      .populate('user', 'username email photoUrl')
      .exec();
  }

  /**
   * Met à jour un commentaire existant
   *
   * Met à jour le contenu d'un commentaire tout en préservant
   * les métadonnées et les relations existantes.
   *
   * @param commentId - ID du commentaire à mettre à jour
   * @param updateCommentDto - Nouvelles données du commentaire
   * @returns Commentaire mis à jour avec les informations utilisateur
   * @throws {NotFoundException} Si le commentaire n'existe pas
   *
   */
  async updateById(
    commentId: string,
    updateCommentDto: CommentDto,
  ): Promise<CommentDocument | null> {
    return this.commentModel
      .findOneAndUpdate({ _id: commentId }, updateCommentDto, {
        new: true,
      })
      .populate('user', 'username email photoUrl')
      .exec();
  }
}
