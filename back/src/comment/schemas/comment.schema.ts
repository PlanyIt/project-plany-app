import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CommentDocument = Comment & Document;

@Schema({ timestamps: true })
export class Comment {
  @Prop({ required: true })
  content: string;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  userId: string;

  @Prop({ type: Types.ObjectId, ref: 'Plan', required: true })
  planId: string;

  @Prop({ type: [String], required: false })
  likes?: string[];

  @Prop({ type: [{ type: Types.ObjectId, ref: 'Comment' }], required: false })
  responses?: Types.ObjectId[];

  @Prop({ type: Types.ObjectId, ref: 'Comment', required: false })
  parentId?: Types.ObjectId;

  @Prop({ required: false })
  photoUrl?: string;
}

export const CommentSchema = SchemaFactory.createForClass(Comment);
