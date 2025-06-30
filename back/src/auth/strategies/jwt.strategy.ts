import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from '../../user/user.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private userService: UserService,
    private configService: ConfigService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
    });
  }

  async validate(payload: any) {
    console.log('JWT Payload reçu:', payload);

    if (!payload.sub) {
      console.error('Payload JWT invalide: sub manquant');
      throw new UnauthorizedException('Token JWT invalide');
    }

    const user = await this.userService.findById(payload.sub);
    if (!user) {
      console.error('Utilisateur non trouvé pour ID:', payload.sub);
      throw new UnauthorizedException('Utilisateur non trouvé');
    }

    console.log('Utilisateur validé:', user.username);
    return {
      userId: payload.sub,
      username: payload.username,
      _id: payload.sub,
      sub: payload.sub,
    };
  }
}
