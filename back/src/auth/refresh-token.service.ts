import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from '../user/user.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class RefreshTokenService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly userService: UserService,
  ) {}

  async generateRefreshToken(userId: string): Promise<string> {
    const payload = { sub: userId };
    const refreshToken = this.jwtService.sign(payload, {
      secret:
        this.configService.get('JWT_REFRESH_SECRET') || 'refreshSecretKey',
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN') || '7d',
    });

    // Hash et stocker le refresh token
    const hashedRefreshToken = await bcrypt.hash(refreshToken, 10);
    await this.userService.updateRefreshToken(userId, hashedRefreshToken);

    return refreshToken;
  }

  async refreshTokens(refreshToken: string) {
    try {
      // Vérifier et décoder le refresh token
      const payload = this.jwtService.verify(refreshToken, {
        secret:
          this.configService.get('JWT_REFRESH_SECRET') || 'refreshSecretKey',
      });

      // Trouver l'utilisateur
      const user = await this.userService.findById(payload.sub);
      if (!user || !user.refreshToken) {
        throw new UnauthorizedException('Refresh token invalide');
      }

      // Vérifier que le refresh token correspond
      const refreshTokenMatches = await bcrypt.compare(
        refreshToken,
        user.refreshToken,
      );
      if (!refreshTokenMatches) {
        throw new UnauthorizedException('Refresh token invalide');
      }

      // Générer de nouveaux tokens
      const newPayload = {
        sub: (user._id as any).toString(),
        username: user.username,
      };
      const accessToken = this.jwtService.sign(newPayload, {
        expiresIn: '15m',
      });
      const newRefreshToken = await this.generateRefreshToken(
        (user._id as any).toString(),
      );

      return {
        accessToken,
        refreshToken: newRefreshToken,
      };
    } catch (error) {
      throw new UnauthorizedException('Refresh token invalide');
    }
  }

  async revokeRefreshToken(userId: string): Promise<void> {
    await this.userService.updateRefreshToken(userId, null);
  }
}
