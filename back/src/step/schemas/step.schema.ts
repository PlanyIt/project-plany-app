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

  @Prop({ type: String, required: true })
  image: string;

  @Prop({ type: String, required: false })
  duration?: string;

  @Prop({ type: Number, required: false })
  cost?: number;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: string;
}

export const StepSchema = SchemaFactory.createForClass(Step);
