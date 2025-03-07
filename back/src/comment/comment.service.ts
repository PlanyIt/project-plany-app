import { Injectable } from '@nestjs/common';
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

  async findAllByPlanId(planId: string): Promise<CommentDocument[]> {
    return this.commentModel.find({ planId }).exec();
  }

  async findAllByUserId(userId: string): Promise<CommentDocument[]> {
    return this.commentModel.find({ userId }).exec();
  }

  async findById(commentId: string): Promise<CommentDocument | undefined> {
    return this.commentModel.findOne({ _id: commentId }).exec();
  }

  async removeById(commentId: string): Promise<CommentDocument | null> {
    return this.commentModel.findOneAndDelete({ _id: commentId }).exec();
  }

  async updateById(
    commentId: string,
    updateCommentDto: CommentDto,
    userId: string,
    planId: string,
  ): Promise<CommentDocument | null> {
    return this.commentModel
      .findOneAndUpdate({ _id: commentId, userId, planId }, updateCommentDto, {
        new: true,
      })
      .exec();
  }
}
