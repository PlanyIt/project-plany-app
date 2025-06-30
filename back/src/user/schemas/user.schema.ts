import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type UserDocument = User & Document;

export enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
}

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true })
  username: string;

  @Prop({ required: true })
  password: string;

  @Prop({ enum: UserRole, default: UserRole.USER })
  role: UserRole;

  @Prop({ default: true })
  isActive: boolean;

  @Prop()
  lastLoginAt: Date;

  @Prop()
  refreshToken: string;

  @Prop()
  description: string;

  @Prop({ default: false })
  isPremium: boolean;

  @Prop()
  photoUrl: string;

  @Prop()
  birthDate: Date;

  @Prop()
  gender: string;

  @Prop([{ type: Types.ObjectId, ref: 'User' }])
  followers: Types.ObjectId[];

  @Prop([{ type: Types.ObjectId, ref: 'User' }])
  following: Types.ObjectId[];
}

export const UserSchema = SchemaFactory.createForClass(User);
