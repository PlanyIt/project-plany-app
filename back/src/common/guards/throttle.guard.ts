import {
  Injectable,
  CanActivate,
  ExecutionContext,
  HttpStatus,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import {
  THROTTLE_KEY,
  ThrottleOptions,
} from '../decorators/throttle.decorator';
import { ThrottleException } from '../exceptions';

@Injectable()
export class ThrottleGuard implements CanActivate {
  private readonly cache = new Map<
    string,
    { count: number; resetTime: number }
  >();

  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const throttleOptions = this.reflector.get<ThrottleOptions>(
      THROTTLE_KEY,
      context.getHandler(),
    );

    if (!throttleOptions) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const key = this.generateKey(request, context);
    const now = Date.now();

    const record = this.cache.get(key);

    if (!record || now > record.resetTime) {
      // Nouvelle fenêtre de temps
      this.cache.set(key, {
        count: 1,
        resetTime: now + throttleOptions.ttl,
      });
      return true;
    }
    if (record.count >= throttleOptions.limit) {
      const response = context.switchToHttp().getResponse();
      const retryAfter = Math.ceil((record.resetTime - now) / 1000);

      // Ajouter les headers de rate limiting
      response.setHeader('X-RateLimit-Limit', throttleOptions.limit);
      response.setHeader('X-RateLimit-Remaining', 0);
      response.setHeader(
        'X-RateLimit-Reset',
        new Date(record.resetTime).toISOString(),
      );
      response.setHeader('Retry-After', retryAfter);

      throw new ThrottleException(
        throttleOptions.limit,
        throttleOptions.ttl,
        retryAfter,
      );
    }

    // Ajouter les headers de rate limiting pour les requêtes autorisées
    const response = context.switchToHttp().getResponse();
    response.setHeader('X-RateLimit-Limit', throttleOptions.limit);
    response.setHeader(
      'X-RateLimit-Remaining',
      throttleOptions.limit - record.count,
    );
    response.setHeader(
      'X-RateLimit-Reset',
      new Date(record.resetTime).toISOString(),
    );

    record.count++;
    this.cache.set(key, record);
    return true;
  }

  private generateKey(request: any, context: ExecutionContext): string {
    const ip = request.ip || request.connection.remoteAddress;
    const route = context.getHandler().name;
    return `${ip}:${route}`;
  }
}
