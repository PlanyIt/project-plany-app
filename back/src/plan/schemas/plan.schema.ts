import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type PlanDocument = HydratedDocument<Plan>;

@Schema({ timestamps: true })
export class Plan {
  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  description: string;

  @Prop({ required: true })
  userId: string;

  @Prop({ default: true })
  isPublic: boolean;

  @Prop({ required: true })
  category: string;

  @Prop({ type: [String], default: [] })
  tags: string[];

  @Prop({ type: [String], default: [] })
  steps: string[];

  @Prop({ type: [String], default: [] })
  favorites: string[];
}

export const PlanSchema = SchemaFactory.createForClass(Plan);
