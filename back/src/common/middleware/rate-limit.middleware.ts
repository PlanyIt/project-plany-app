import {
  Injectable,
  NestMiddleware,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { RATE_LIMIT_CONFIG } from '../config/rate-limit.config';

interface RequestWithRateLimit extends Request {
  rateLimit?: {
    limit: number;
    remaining: number;
    resetTime: Date;
  };
}

@Injectable()
export class RateLimitMiddleware implements NestMiddleware {
  private readonly store = new Map<
    string,
    { count: number; resetTime: number }
  >();

  use(req: RequestWithRateLimit, res: Response, next: NextFunction) {
    const ip = this.getClientIp(req);
    const key = `${ip}:${req.path}`;
    const now = Date.now();

    // Utiliser la configuration globale par défaut
    const config = RATE_LIMIT_CONFIG.global;
    const windowMs = config.windowMs;
    const maxRequests = config.maxRequests;

    let record = this.store.get(key);

    // Si pas d'enregistrement ou fenêtre expirée, créer un nouveau
    if (!record || now > record.resetTime) {
      record = {
        count: 1,
        resetTime: now + windowMs,
      };
      this.store.set(key, record);
    } else {
      record.count++;
    }

    // Ajouter les headers de rate limiting
    const resetTime = new Date(record.resetTime);
    req.rateLimit = {
      limit: maxRequests,
      remaining: Math.max(0, maxRequests - record.count),
      resetTime,
    };

    res.setHeader('X-RateLimit-Limit', maxRequests);
    res.setHeader('X-RateLimit-Remaining', req.rateLimit.remaining);
    res.setHeader('X-RateLimit-Reset', resetTime.toISOString());

    // Vérifier si la limite est dépassée
    if (record.count > maxRequests) {
      res.setHeader('Retry-After', Math.ceil((record.resetTime - now) / 1000));
      throw new HttpException(
        {
          statusCode: HttpStatus.TOO_MANY_REQUESTS,
          message: RATE_LIMIT_CONFIG.messages.tooManyRequests,
          retryAfter: Math.ceil((record.resetTime - now) / 1000),
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    next();
  }

  private getClientIp(req: Request): string {
    return (
      (req.headers['x-forwarded-for'] as string) ||
      (req.headers['x-real-ip'] as string) ||
      req.socket.remoteAddress ||
      'unknown'
    );
  }
}
