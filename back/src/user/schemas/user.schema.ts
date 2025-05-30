import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type UserDocument = User & Document;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, unique: true })
  firebaseUid: string;

  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true })
  username: string;

  @Prop()
  photoUrl?: string;

  @Prop()
  description?: string;

  @Prop({ default: false })
  isPremium: boolean;

  @Prop()
  birthDate?: Date;

  @Prop()
  gender?: string;

  @Prop({ type: [String], default: [] })
  followers: string[];

  @Prop({ type: [String], default: [] })
  following: string[];
}

export const UserSchema = SchemaFactory.createForClass(User);
