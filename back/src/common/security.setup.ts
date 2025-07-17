import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { ValidationPipe, INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as mongoSanitizeNS from 'express-mongo-sanitize';
import { RequestHandler } from 'express';

export async function applySecurity(app: INestApplication, cfg: ConfigService) {
  /* -------- Validation DTO -------- */
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      disableErrorMessages: cfg.get('NODE_ENV') === 'production',
    }),
  );

  /* -------- Helmet -------- */
  app.use(helmet());
  app.use(
    helmet.contentSecurityPolicy({
      directives: {
        defaultSrc: ["'self'"],
        imgSrc: ["'self'", 'data:'],
        objectSrc: ["'none'"],
        upgradeInsecureRequests: [],
      },
    }),
  );
  app.use(helmet.hsts({ maxAge: 15552000 })); // 180 jours
  app.use(helmet.crossOriginResourcePolicy({ policy: 'same-origin' }));

  /* -------- Sanitisation NoSQL -------- */
  const mongoSanitize =
    (mongoSanitizeNS as any).default ??
    (mongoSanitizeNS as unknown as (opts?: any) => RequestHandler);
  app.use(mongoSanitize());

  /* -------- Rate-limit -------- */
  app.use(
    rateLimit({
      windowMs: 15 * 60 * 1000,
      max: 1000, // 1000 req / 15 min / IP
    }),
  );

  /* -------- CORS -------- */
  const origins = cfg.get<string>('CORS_ORIGIN')?.split(',') ?? [
    'https://plany.app',
    'https://admin.plany.app',
  ];
  app.enableCors({ origin: origins, credentials: true });
}

/* -------- Validation env -------- */
export function validateEnvOrThrow(cfg: ConfigService) {
  if (!cfg.get<string>('JWT_SECRET_AT')) {
    throw new Error('JWT_SECRET_AT missing – aborting startup.');
  }
}
