import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';

export type UserDocument = User & Document;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, unique: true })
  username: string;

  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true })
  password: string;

  @Prop()
  description: string;

  @Prop({ default: false })
  isPremium: boolean;

  @Prop()
  photoUrl: string;

  @Prop({ type: Date })
  birthDate: Date;

  @Prop()
  gender: string;

  @Prop({ default: 'user' })
  role: string;

  @Prop({
    type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    default: [],
  })
  followers: mongoose.Types.ObjectId[];

  @Prop({
    type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    default: [],
  })
  following: mongoose.Types.ObjectId[];
}

export const UserSchema = SchemaFactory.createForClass(User);
