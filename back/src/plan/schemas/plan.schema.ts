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

  @Prop({ required: true })
  category: string;

  @Prop({ type: [{ type: Types.ObjectId, ref: 'Step' }], default: [] })
  steps: Types.ObjectId[];

  @Prop({ type: [String], default: [] })
  favorites: string[];
}

export const PlanSchema = SchemaFactory.createForClass(Plan);
