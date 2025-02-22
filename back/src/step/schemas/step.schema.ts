import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type StepDocument = HydratedDocument<Step>;

@Schema({ timestamps: true })
export class Step {
  @Prop({ required: true, type: String })
  title: string;

  @Prop({ required: true, type: String })
  description: string;

  @Prop({ type: Number, required: false })
  latitude?: number;

  @Prop({ type: Number, required: false })
  longitude?: number;

  @Prop({ required: true, type: Number })
  order: number;

  @Prop({ type: String, required: false })
  image?: string;

  @Prop({ type: Date, required: false })
  start?: Date;

  @Prop({ type: Date, required: false })
  end?: Date;

  @Prop({ type: Number, required: false })
  duration?: number;

  @Prop({ type: Number, required: false })
  cost?: number;

  @Prop({ type: Date, required: false })
  createdAt?: Date;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: string;

  @Prop({ type: Types.ObjectId, ref: 'Plan', required: true })
  planId: string;
  //je met categoryId required false: on a pas de categoryId, on ne peut pas mettre une catégorie
  //TODO après la crétion du module Catégorie
  @Prop({ type: Types.ObjectId, ref: 'Category', required: false })
  categoryId: string;
}

export const StepSchema = SchemaFactory.createForClass(Step);
