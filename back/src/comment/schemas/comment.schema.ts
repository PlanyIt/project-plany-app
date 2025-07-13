import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CommentDocument = Comment & Document;

@Schema({ timestamps: true })
export class Comment {
  @Prop({ required: true })
  content: string;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  user: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Plan', required: true })
  planId: Types.ObjectId;

  @Prop({ type: [String], default: [] })
  likes?: string[];

  @Prop({ type: [{ type: Types.ObjectId, ref: 'Comment' }], default: [] })
  responses?: Types.ObjectId[];

  @Prop({ type: Types.ObjectId, ref: 'Comment', required: false })
  parentId?: Types.ObjectId;

  @Prop({ required: false })
  imageUrl?: string;
}

export const CommentSchema = SchemaFactory.createForClass(Comment);
