/* eslint-disable prettier/prettier */
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Comment, CommentDocument } from './schemas/comment.schema';
import { CommentDto } from './dto/comment.dto';

@Injectable()
export class CommentService {
  constructor(
    @InjectModel(Comment.name) private commentModel: Model<CommentDocument>,
  ) {}

  async create(createCommentDto: CommentDto): Promise<CommentDocument> {
    const newComment = new this.commentModel(createCommentDto);
    return newComment.save();
  }

  async likeComment(commentId: string, userId: string): Promise<CommentDocument | null> {
    return this.commentModel.findOneAndUpdate(
      { _id: commentId },
      { $push: { likes: userId } },
      { new: true }
    ).exec();
  }

  async unlikeComment(commentId: string, userId: string): Promise<CommentDocument | null> {
    return this.commentModel.findOneAndUpdate(
      { _id
      : commentId },
      { $pull: { likes: userId } },
      { new: true }
    ).exec();
  }

  async addResponse(commentId: string, responseDtro: CommentDto): Promise<Comment> {
    const comment = await this.commentModel.findById(commentId).exec();
    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }
    const newResponse = new this.commentModel({...responseDtro,
      parentId: commentId
    });
    const savedResponse = await newResponse.save();

    await this.commentModel.updateOne(
      { _id: commentId },
      { $push: { responses: savedResponse.id } }
    );

    return savedResponse;
  }

  async findAllByPlanId(
    planId: string, 
    paginationOptions: { page: number; limit: number; }
  ): Promise<CommentDocument[]> {
    const { page, limit } = paginationOptions;
    const skip = (page - 1) * limit;
    
    return this.commentModel.find({ 
      planId,
      parentId: { $exists: false } // Ne retourne que les commentaires principaux
    })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('responses')
      .exec();
  }
  async removeResponse(commentId: string, responseId: string): Promise<{ comment: CommentDocument; response: CommentDocument }> {
    // 1. Retirer l'ID de la réponse du tableau responses du commentaire parent
    const comment = await this.commentModel.findByIdAndUpdate(
      commentId,
      { $pull: { responses: responseId } },
      { new: true }
    ).exec();
  
    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }
  
    // 2. Supprimer le commentaire de réponse
    const response = await this.commentModel.findByIdAndDelete(responseId).exec();
  
    if (!response) {
      throw new NotFoundException(`Response with ID ${responseId} not found`);
    }
  
    return { comment, response };
  }


  async countByPlanId(planId: string): Promise<number> {
    return this.commentModel.countDocuments({ planId }).exec();
  }
  // Et vous pouvez ajouter une méthode pour récupérer toutes les réponses
  async findAllResponses(commentId: string): Promise<Comment[]> {
    return this.commentModel.find({ parentId: commentId }).exec();
  }

  async findAllByUserId(userId: string): Promise<CommentDocument[]> {
    return this.commentModel.find({ userId }).exec();
  }
  
  async findById(commentId: string): Promise<CommentDocument | undefined> {
    const comment = await this.commentModel.findOne({ _id: commentId }).populate('responses').exec();
    return comment;
  }

  async removeById(commentId: string): Promise<CommentDocument> {
    // 1. Trouver le commentaire pour vérifier s'il a des réponses
    const comment = await this.commentModel.findById(commentId).exec();
    
    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }
    
    // 2. Supprimer toutes les réponses associées
    if (comment.responses && comment.responses.length > 0) {
      await this.commentModel.deleteMany({ _id: { $in: comment.responses } }).exec();
    }
    
    // 3. Supprimer le commentaire lui-même
    return this.commentModel.findByIdAndDelete(commentId).exec();
  }

  async updateById(
    commentId: string,
    updateCommentDto: CommentDto,

  ): Promise<CommentDocument | null> {
    return this.commentModel
      .findOneAndUpdate({ _id: commentId }, updateCommentDto, {
        new: true,
      })
      .exec();
  }
}