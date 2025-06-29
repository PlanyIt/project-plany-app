import { BaseException } from './base.exception';

export class AuthenticationException extends BaseException {
  readonly code = 'AUTH_ERROR';
  readonly statusCode = 401;

  constructor(message: string = 'Authentification requise', details?: any) {
    super(message, details);
  }
}

export class InvalidCredentialsException extends BaseException {
  readonly code = 'INVALID_CREDENTIALS';
  readonly statusCode = 401;

  constructor(message: string = 'Identifiants invalides', details?: any) {
    super(message, details);
  }
}

export class TokenExpiredException extends BaseException {
  readonly code = 'TOKEN_EXPIRED';
  readonly statusCode = 401;

  constructor(message: string = 'Token expiré', details?: any) {
    super(message, details);
  }
}

export class ForbiddenException extends BaseException {
  readonly code = 'FORBIDDEN';
  readonly statusCode = 403;

  constructor(message: string = 'Accès interdit', details?: any) {
    super(message, details);
  }
}
