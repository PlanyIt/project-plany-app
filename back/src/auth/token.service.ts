// src/auth/token.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { randomUUID } from 'node:crypto';
import { add } from 'date-fns';

import {
  RefreshToken,
  RefreshTokenDocument,
} from './schemas/refresh-token.schema';

export interface JwtPayload {
  sub: string;
  email?: string;
  username?: string;
  tokenVersion?: number;
  iat?: number;
  exp?: number;
  jti?: string;
}

@Injectable()
export class TokenService {
  constructor(
    private readonly jwt: JwtService,
    private readonly cfg: ConfigService,
    @InjectModel(RefreshToken.name)
    private readonly refreshModel: Model<RefreshTokenDocument>,
  ) {}

  /* ------------------------------------------------------------------
     ACCESS TOKEN : durée courte (15 min)
  ------------------------------------------------------------------ */
  signAccess(payload: JwtPayload): string {
    return this.jwt.sign(payload, {
      secret: this.cfg.get<string>('JWT_SECRET_AT'),
      expiresIn: this.cfg.get<string>('JWT_AT_EXPIRES_IN') ?? '15m',
      algorithm: 'HS512',
    });
  }

  /* ------------------------------------------------------------------
     REFRESH TOKEN : durée longue (30 jours) + jti persistant
  ------------------------------------------------------------------ */
  async signRefresh(userId: string, tokenVersion = 0): Promise<string> {
    const jti = randomUUID(); // identifiant unique du RT
    const expiresAt = add(new Date(), { days: 30 });

    // 1. on stocke la trace en BDD
    await this.refreshModel.create({ jti, userId, expiresAt });

    // 2. on signe le JWT
    return this.jwt.sign(
      { sub: userId, jti, tokenVersion },
      {
        secret: this.cfg.get<string>('JWT_SECRET_RT'),
        expiresIn: this.cfg.get<string>('JWT_RT_EXPIRES_IN') ?? '30d',
        algorithm: 'HS512',
      },
    );
  }

  /* ------------------------------------------------------------------
     RÉVOCATION (logout ou rotation)
  ------------------------------------------------------------------ */
  async revoke(jti: string): Promise<void> {
    await this.refreshModel.updateOne({ jti }, { revoked: true }).exec();
  }

  /* ------------------------------------------------------------------
     VÉRIFICATION D’UN REFRESH TOKEN
     (→ lève 401 si signature invalide / expiré / jti révoqué)
  ------------------------------------------------------------------ */
  async verifyRefresh(rt: string): Promise<JwtPayload> {
    try {
      const payload = this.jwt.verify<JwtPayload>(rt, {
        secret: this.cfg.get<string>('JWT_SECRET_RT'),
      });

      const record = await this.refreshModel
        .findOne({ jti: payload.jti })
        .lean();

      if (!record || record.revoked) {
        throw new UnauthorizedException('Refresh token révoqué');
      }
      return payload;
    } catch {
      throw new UnauthorizedException('Refresh token invalide ou expiré');
    }
  }

  /** Révoque **tous** les refresh-tokens d’un utilisateur (après changement de mdp, par ex.) */
  async revokeAllForUser(userId: string): Promise<void> {
    await this.refreshModel.updateMany(
      { userId, revoked: false },
      { revoked: true },
    );
  }

  /** Utilitaire : extraire le jti d’un refresh JWT et le révoquer en base */
  async revokeFromJwt(rt: string): Promise<void> {
    try {
      const { jti } = this.jwt.verify<{ jti: string }>(rt, {
        secret: this.cfg.get('JWT_SECRET_RT'),
        ignoreExpiration: true,
      });
      await this.revoke(jti);
    } catch {}
  }
}
