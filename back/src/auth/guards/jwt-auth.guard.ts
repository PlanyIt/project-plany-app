import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * Guard JWT : protège les routes avec la stratégie « jwt ».
 * - Laisse Passport valider le token (signature, expiration…).
 * - Lève 401 si le token est absent / non valide.
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  /**
   * Fournit un type de retour conforme à IAuthGuard
   */
  canActivate(context: ExecutionContext): boolean | Promise<boolean> {
    return super.canActivate(context) as boolean | Promise<boolean>;
  }

  /**
   * Personnalise la gestion d'erreur et respecte la signature générique
   */
  handleRequest<TUser = any>(err: any, user: TUser, info: any): TUser {
    if (err || !user) {
      // info est fourni par Passport ; on en extrait le message si présent
      const message = info?.message ?? 'Authentification requise';
      throw err || new UnauthorizedException(message);
    }
    return user;
  }
}
