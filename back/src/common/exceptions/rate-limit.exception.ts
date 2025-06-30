import { BaseException } from './base.exception';

export class RateLimitException extends BaseException {
  readonly code = 'RATE_LIMIT_EXCEEDED';
  readonly statusCode = 429;

  constructor(
    message: string = 'Trop de requêtes, veuillez réessayer plus tard',
    public readonly retryAfter?: number,
  ) {
    super(message, { retryAfter });
  }
}

export class ThrottleException extends BaseException {
  readonly code = 'THROTTLE_LIMIT_EXCEEDED';
  readonly statusCode = 429;

  constructor(limit: number, windowMs: number, retryAfter: number) {
    const message = `Limite de ${limit} requêtes dépassée. Réessayez dans ${retryAfter} secondes.`;
    super(message, { limit, windowMs, retryAfter });
  }
}
