import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UserService } from '../../user/user.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private userService: UserService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'secretKey',
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
    };
  }
}
