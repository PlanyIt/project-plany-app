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
    const savedComment = await newComment.save();

    // Populate user information
    return this.commentModel
      .findById(savedComment._id)
      .populate('user', 'username email password photoUrl ')
      .exec();
  }

  async likeComment(
    commentId: string,
    userId: string,
  ): Promise<CommentDocument | null> {
    return this.commentModel
      .findOneAndUpdate(
        { _id: commentId },
        { $push: { likes: userId } },
        { new: true },
      )
      .populate('user', 'username email password photoUrl ')
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
      .populate('user', 'username email password photoUrl ')
      .exec();
  }

  async addResponse(
    commentId: string,
    responseDtro: CommentDto,
  ): Promise<Comment> {
    const comment = await this.commentModel.findById(commentId).exec();
    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }
    const newResponse = new this.commentModel({
      ...responseDtro,
      parentId: commentId,
    });
    const savedResponse = await newResponse.save();

    await this.commentModel.updateOne(
      { _id: commentId },
      { $push: { responses: savedResponse.id } },
    );

    // Populate user information before returning
    return this.commentModel
      .findById(savedResponse._id)
      .populate('user', 'username email password photoUrl')
      .exec();
  }

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
      .populate('user', 'username email password photoUrl ')
      .populate({
        path: 'responses',
        populate: {
          path: 'user',
          select: 'username email password photoUrl',
        },
      })
      .exec();
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

    return { comment, response };
  }

  async countByPlanId(planId: string): Promise<number> {
    return this.commentModel
      .countDocuments({
        planId,
        $or: [{ parentId: { $exists: false } }, { parentId: null }],
      })
      .exec();
  }
  async findAllResponses(commentId: string): Promise<Comment[]> {
    return this.commentModel
      .find({ parentId: commentId })
      .populate('user', 'username email password photoUrl')
      .exec();
  }

  async findAllByUserId(userId: string): Promise<CommentDocument[]> {
    return this.commentModel
      .find({ user: userId })
      .populate('user', 'username email password photoUrl')
      .exec();
  }

  async findById(commentId: string): Promise<CommentDocument | undefined> {
    const comment = await this.commentModel
      .findOne({ _id: commentId })
      .populate('user', 'username email password photoUrl')
      .populate({
        path: 'responses',
        populate: {
          path: 'user',
          select: 'username email password photoUrl',
        },
      })
      .exec();
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

    return this.commentModel
      .findByIdAndDelete(commentId)
      .populate('user', 'username email password photoUrl')
      .exec();
  }

  async updateById(
    commentId: string,
    updateCommentDto: CommentDto,
  ): Promise<CommentDocument | null> {
    return this.commentModel
      .findOneAndUpdate({ _id: commentId }, updateCommentDto, {
        new: true,
      })
      .populate('user', 'username email password photoUrl')
      .exec();
  }
}
