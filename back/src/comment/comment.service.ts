import { Injectable, NotFoundException, Inject } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
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
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}

  private get cache(): any {
    return this.cacheManager as any;
  }

  private async invalidatePlanCommentsCache(planId: string) {
    await this.cache.del(`comments:plan:${planId}`);
    await this.cache.del(`comments:count:${planId}`);
  }

  private async invalidateUserCommentsCache(userId: string) {
    await this.cache.del(`comments:user:${userId}`);
  }

  async create(createCommentDto: CommentDto): Promise<CommentDocument> {
    const newComment = new this.commentModel(createCommentDto);
    const savedComment = await newComment.save();

    await this.invalidatePlanCommentsCache(savedComment.planId.toString());
    await this.invalidateUserCommentsCache(savedComment.user.toString());

    return this.commentModel
      .findById(savedComment._id)
      .populate('user', 'username email photoUrl')
      .exec();
  }

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

    await this.cache.del(`comments:responses:${commentId}`);
    await this.invalidatePlanCommentsCache(comment.planId.toString());
    await this.invalidateUserCommentsCache(responseDto.user.toString());

    return this.commentModel
      .findById(savedResponse._id)
      .populate('user', 'username email photoUrl')
      .exec();
  }

  async findAllByPlanId(
    planId: string,
    paginationOptions: { page: number; limit: number },
  ): Promise<CommentDocument[]> {
    const { page, limit } = paginationOptions;
    const skip = (page - 1) * limit;
    const cacheKey = `comments:plan:${planId}:page:${page}:limit:${limit}`;

    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const comments = await this.commentModel
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

    await this.cache.set(cacheKey, comments, 30);
    return comments;
  }

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

    await this.cache.del(`comments:responses:${commentId}`);
    await this.invalidatePlanCommentsCache(comment.planId.toString());

    return { comment, response };
  }

  async countByPlanId(planId: string): Promise<number> {
    const cacheKey = `comments:count:${planId}`;
    const cached = await this.cache.get(cacheKey);
    if (cached !== undefined) return cached;

    const count = await this.commentModel
      .countDocuments({
        planId,
        $or: [{ parentId: { $exists: false } }, { parentId: null }],
      })
      .exec();

    await this.cache.set(cacheKey, count, 30);
    return count;
  }

  async findAllResponses(commentId: string): Promise<Comment[]> {
    const cacheKey = `comments:responses:${commentId}`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const responses = await this.commentModel
      .find({ parentId: commentId })
      .populate('user', 'username email photoUrl')
      .exec();

    await this.cache.set(cacheKey, responses, 30);
    return responses;
  }

  async findAllByUserId(userId: string): Promise<CommentDocument[]> {
    const cacheKey = `comments:user:${userId}`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const comments = await this.commentModel
      .find({ user: userId })
      .populate('user', 'username email photoUrl')
      .exec();

    await this.cache.set(cacheKey, comments, 30);
    return comments;
  }

  async findById(commentId: string): Promise<CommentDocument | undefined> {
    const cacheKey = `comment:${commentId}`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

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

    await this.cache.set(cacheKey, comment, 30);
    return comment;
  }

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

    await this.invalidatePlanCommentsCache(comment.planId.toString());
    await this.invalidateUserCommentsCache(comment.user.toString());
    await this.cache.del(`comment:${commentId}`);

    return this.commentModel
      .findByIdAndDelete(commentId)
      .populate('user', 'username email photoUrl')
      .exec();
  }

  async updateById(
    commentId: string,
    updateCommentDto: CommentDto,
  ): Promise<CommentDocument | null> {
    const updatedComment = await this.commentModel
      .findOneAndUpdate({ _id: commentId }, updateCommentDto, {
        new: true,
      })
      .populate('user', 'username email photoUrl')
      .exec();

    if (updatedComment) {
      await this.cache.del(`comment:${commentId}`);
      await this.invalidatePlanCommentsCache(updatedComment.planId.toString());
    }

    return updatedComment;
  }
}
