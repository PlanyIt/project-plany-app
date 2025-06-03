import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import * as bcrypt from 'bcrypt';

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

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ type: Date, default: Date.now })
  registrationDate: Date;

  @Prop({ type: [String], default: [] })
  followers: string[];

  @Prop({ type: [String], default: [] })
  following: string[];
}

export const UserSchema = SchemaFactory.createForClass(User);

// Ajouter un middleware pre-save pour hacher les mots de passe
UserSchema.pre('save', async function (next) {
  // Ne hacher le mot de passe que s'il a été modifié ou est nouveau
  if (!this.isModified('password')) return next();

  try {
    // Générer un salt et hacher le mot de passe
    const salt = await bcrypt.genSalt(12);
    const hashedPassword = await bcrypt.hash(this.password, salt);

    // Remplacer le mot de passe en clair par le mot de passe haché
    this.password = hashedPassword;
    next();
  } catch (error) {
    next(error);
  }
});

// Ajouter une méthode pour vérifier les mots de passe
UserSchema.methods.comparePassword = async function (
  candidatePassword: string,
): Promise<boolean> {
  return bcrypt.compare(candidatePassword, this.password);
};
