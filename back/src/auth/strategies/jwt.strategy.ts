import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from '../../user/user.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    cfg: ConfigService,
    private readonly userService: UserService,
  ) {
    // 1. récupère le secret access-token
    const secret = cfg.get<string>('JWT_SECRET_AT') ?? cfg.get('JWT_SECRET');
    if (!secret) {
      throw new Error('JWT_SECRET_AT (ou JWT_SECRET) manquant');
    }

    // 2. configure la stratégie
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: secret,
    });
  }

  async validate(payload: any) {
    // payload.sub contient l’ID du user
    const user = await this.userService.findById(payload.sub);
    if (!user) throw new UnauthorizedException('Utilisateur non trouvé');
    return user;
  }
}
