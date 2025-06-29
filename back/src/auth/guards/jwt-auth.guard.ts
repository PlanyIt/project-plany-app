import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  private readonly logger = new Logger(JwtAuthGuard.name);

  constructor(private jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request>();

    try {
      const token = this.extractTokenFromHeader(request);

      if (!token) {
        this.logger.warn('No token provided in authorization header');
        throw new UnauthorizedException("Token d'authentification requis");
      }

      const payload = await this.jwtService.verifyAsync(token, {
        secret: process.env.JWT_SECRET,
      });

      if (!payload.userId) {
        this.logger.warn('Invalid token payload - missing userId');
        throw new UnauthorizedException('Token invalide');
      }

      // Attach user info to request
      request['user'] = payload;

      return true;
    } catch (error) {
      this.logger.error('JWT verification failed', error);

      if (error.name === 'TokenExpiredError') {
        throw new UnauthorizedException('Token expiré');
      } else if (error.name === 'JsonWebTokenError') {
        throw new UnauthorizedException('Token invalide');
      } else if (error instanceof UnauthorizedException) {
        throw error;
      }

      throw new UnauthorizedException("Erreur d'authentification");
    }
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const authHeader = request.headers.authorization;

    if (!authHeader) {
      return undefined;
    }

    const [type, token] = authHeader.split(' ') ?? [];

    if (type !== 'Bearer' || !token) {
      return undefined;
    }

    return token;
  }
}
