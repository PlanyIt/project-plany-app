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
      // Log headers for debugging
      this.logger.debug('Authorization header:', request.headers.authorization);
      this.logger.debug(
        'All headers:',
        JSON.stringify(request.headers, null, 2),
      );

      const token = this.extractTokenFromHeader(request);

      if (!token) {
        this.logger.warn('No token provided in authorization header');
        this.logger.warn('Available headers:', Object.keys(request.headers));
        throw new UnauthorizedException("Token d'authentification requis");
      }

      this.logger.debug('Token extracted successfully, length:', token.length);

      const payload = await this.jwtService.verifyAsync(token, {
        secret: process.env.JWT_SECRET,
      });

      this.logger.debug('Token verified successfully, payload:', payload);

      if (!payload.sub) {
        this.logger.warn('Invalid token payload - missing sub');
        throw new UnauthorizedException('Token invalide');
      }

      // Attach user info to request
      request['user'] = {
        userId: payload.sub,
        username: payload.username,
        role: payload.role || 'user', // Include role from token or default to 'user'
        _id: payload.sub,
        sub: payload.sub,
      };

      this.logger.debug('User attached to request:', request['user']);
      return true;
    } catch (error) {
      this.logger.error('JWT verification failed');
      this.logger.error('Error details:', error.message);
      this.logger.error('Error name:', error.name);

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
