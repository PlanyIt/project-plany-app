import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type TokenBlacklistDocument = TokenBlacklist & Document;

@Schema({ timestamps: true })
export class TokenBlacklist {
  @Prop({ required: true, unique: true, index: true })
  tokenId: string;

  @Prop({ required: true, index: true })
  userId: string;

  @Prop({ required: true, enum: ['access', 'refresh', 'all'] })
  tokenType: string;

  @Prop({ required: true })
  reason: string; // Raison de la blacklist

  @Prop({ required: true, index: true })
  expiresAt: Date; // Date d'expiration de la blacklist

  @Prop()
  sessionId?: string;

  @Prop({ type: Object })
  metadata?: Record<string, any>;
}

export const TokenBlacklistSchema =
  SchemaFactory.createForClass(TokenBlacklist);

// TTL index pour auto-suppression
TokenBlacklistSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
