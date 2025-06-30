import { BaseException } from './base.exception';

export class ValidationException extends BaseException {
  readonly code = 'VALIDATION_ERROR';
  readonly statusCode = 400;

  constructor(message: string = 'Données invalides', details?: any) {
    super(message, details);
  }
}

export class NotFoundResourceException extends BaseException {
  readonly code = 'RESOURCE_NOT_FOUND';
  readonly statusCode = 404;

  constructor(resource: string, id?: string) {
    const message = id
      ? `${resource} avec l'ID ${id} non trouvé`
      : `${resource} non trouvé`;
    super(message, { resource, id });
  }
}

export class ConflictException extends BaseException {
  readonly code = 'CONFLICT';
  readonly statusCode = 409;

  constructor(message: string = 'Conflit de données', details?: any) {
    super(message, details);
  }
}

export class BadRequestException extends BaseException {
  readonly code = 'BAD_REQUEST';
  readonly statusCode = 400;

  constructor(message: string = 'Requête invalide', details?: any) {
    super(message, details);
  }
}
