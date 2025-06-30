import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  TokenBlacklist,
  TokenBlacklistDocument,
} from './schemas/token-blacklist.schema';
import { v4 as uuidv4 } from 'uuid';

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  accessTokenId: string;
  refreshTokenId: string;
  expiresAt: Date;
}

@Injectable()
export class TokenService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    @InjectModel(TokenBlacklist.name)
    private tokenBlacklistModel: Model<TokenBlacklistDocument>,
  ) {}

  async generateTokenPair(
    userId: string,
    sessionId?: string,
  ): Promise<TokenPair> {
    const accessTokenId = uuidv4();
    const refreshTokenId = uuidv4();
    const now = new Date();

    const accessTokenExpiry = new Date(
      now.getTime() + this.getAccessTokenTTL(),
    );
    const refreshTokenExpiry = new Date(
      now.getTime() + this.getRefreshTokenTTL(),
    );

    const accessPayload = {
      sub: userId,
      tokenId: accessTokenId,
      type: 'access',
      sessionId: sessionId || uuidv4(),
      iat: Math.floor(now.getTime() / 1000),
    };

    const refreshPayload = {
      sub: userId,
      tokenId: refreshTokenId,
      type: 'refresh',
      sessionId: sessionId || accessPayload.sessionId,
      iat: Math.floor(now.getTime() / 1000),
    };

    const accessToken = this.jwtService.sign(accessPayload, {
      expiresIn: this.configService.get<string>('JWT_EXPIRES_IN') || '15m',
      secret: this.configService.get<string>('JWT_SECRET'),
    });

    const refreshToken = this.jwtService.sign(refreshPayload, {
      expiresIn:
        this.configService.get<string>('JWT_REFRESH_EXPIRES_IN') || '7d',
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
    });

    return {
      accessToken,
      refreshToken,
      accessTokenId,
      refreshTokenId,
      expiresAt: accessTokenExpiry,
    };
  }

  async rotateTokens(refreshToken: string): Promise<TokenPair> {
    try {
      // Vérifier le refresh token
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      // Vérifier que le token n'est pas blacklisté
      const isBlacklisted = await this.isTokenBlacklisted(payload.tokenId);
      if (isBlacklisted) {
        throw new Error('Token is blacklisted');
      }

      // Blacklister l'ancien refresh token
      await this.blacklistToken(payload.tokenId, payload.sub, 'refresh');

      // Générer de nouveaux tokens
      return this.generateTokenPair(payload.sub, payload.sessionId);
    } catch (error) {
      throw new Error('Invalid refresh token');
    }
  }

  async blacklistToken(
    tokenId: string,
    userId: string,
    tokenType: 'access' | 'refresh',
    reason = 'manual_revocation',
  ): Promise<void> {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30); // Garder en blacklist 30 jours

    await this.tokenBlacklistModel.create({
      tokenId,
      userId,
      tokenType,
      reason,
      expiresAt,
    });
  }

  async isTokenBlacklisted(tokenId: string): Promise<boolean> {
    const blacklistedToken = await this.tokenBlacklistModel.findOne({
      tokenId,
      expiresAt: { $gt: new Date() },
    });

    return !!blacklistedToken;
  }

  async blacklistAllUserTokens(
    userId: string,
    reason = 'security_breach',
  ): Promise<void> {
    // Cette méthode nécessiterait de stocker tous les tokens actifs
    // Pour l'instant, on peut implémenter une logique de session ID
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    await this.tokenBlacklistModel.create({
      tokenId: `user_${userId}_${Date.now()}`,
      userId,
      tokenType: 'all',
      reason,
      expiresAt,
    });
  }

  async cleanupExpiredBlacklistedTokens(): Promise<number> {
    const result = await this.tokenBlacklistModel.deleteMany({
      expiresAt: { $lt: new Date() },
    });

    return result.deletedCount;
  }

  private getAccessTokenTTL(): number {
    const ttl = this.configService.get<string>('JWT_EXPIRES_IN') || '15m';
    return this.parseTTL(ttl);
  }

  private getRefreshTokenTTL(): number {
    const ttl =
      this.configService.get<string>('JWT_REFRESH_EXPIRES_IN') || '7d';
    return this.parseTTL(ttl);
  }

  private parseTTL(ttl: string): number {
    const unit = ttl.slice(-1);
    const value = parseInt(ttl.slice(0, -1));

    switch (unit) {
      case 's':
        return value * 1000;
      case 'm':
        return value * 60 * 1000;
      case 'h':
        return value * 60 * 60 * 1000;
      case 'd':
        return value * 24 * 60 * 60 * 1000;
      default:
        return value;
    }
  }
}
