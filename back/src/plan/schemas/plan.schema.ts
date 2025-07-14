import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type PlanDocument = HydratedDocument<Plan>;

@Schema({ timestamps: true })
export class Plan {
  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  description: string;

  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
  })
  user: Types.ObjectId;

  @Prop({ default: true })
  isPublic: boolean;

  @Prop({ default: false })
  isAccessible: boolean;

  @Prop({
    type: Types.ObjectId,
    ref: 'Category',
    required: true,
  })
  category: string;

  @Prop({
    type: [{ type: Types.ObjectId, ref: 'Step', required: true }],
    default: [],
  })
  steps: Types.ObjectId[];

  @Prop({ type: [String], default: [] })
  favorites: string[];

  @Prop({ default: 0 })
  totalCost: number;

  @Prop({ default: 0 })
  totalDuration: number;
}

export const PlanSchema = SchemaFactory.createForClass(Plan);
