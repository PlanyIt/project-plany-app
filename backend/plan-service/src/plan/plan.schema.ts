import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class Plan extends Document {
  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  description: string;

  @Prop({ default: false })
  isPublic: boolean;

  @Prop({ default: 0 })
  likes: number;

  @Prop({ default: false })
  isPremium: boolean;

  @Prop({ type: [String] }) // Les tags sont une liste d'ID de tags
  tags: string[];

  @Prop({ type: String }) // ID de la catégorie
  category: string;

  @Prop({ type: String }) // ID du type
  type: string;

  @Prop({ type: String, required: false })
  image: string;

  @Prop({ type: Number, required: false })
  minPerson: number;

  @Prop({ type: Number, required: false })
  maxPerson: number;

  @Prop({ type: [String], default: [] }) // Collaborateurs (IDs des utilisateurs)
  collaborators: string[];

  @Prop({ default: Date.now })
  createdAt: Date;

  @Prop({ default: Date.now })
  updatedAt: Date;
}

export const PlanSchema = SchemaFactory.createForClass(Plan);
