import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { RateLimitMiddleware } from './common/middleware/rate-limit.middleware';
import helmet from 'helmet';
import { Request, Response, NextFunction } from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Vérifier que les variables d'environnement essentielles sont définies
  const jwtSecret = configService.get<string>('JWT_SECRET');
  if (!jwtSecret) {
    console.error(
      'JWT_SECRET is not defined in environment variables. Application may not work properly.',
    );
  } else {
    console.log('JWT_SECRET is properly configured.');
  }

  // Sécurité
  app.use(helmet());

  // Rate limiting global
  const rateLimitMiddleware = new RateLimitMiddleware();
  app.use((req: Request, res: Response, next: NextFunction) =>
    rateLimitMiddleware.use(req, res, next),
  );

  // Validation des données entrantes
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Supprime les champs inutiles
      forbidNonWhitelisted: true, // Retourne une erreur si un champ non autorisé est présent
      transform: true, // Transforme les paramètres de requête en objets DTO
    }),
  );

  // Configuration CORS
  const corsOrigin = configService.get<string>('CORS_ORIGIN');
  const corsCredentials =
    configService.get<string>('CORS_CREDENTIALS') === 'true';
  const corsMethods = configService.get<string>('CORS_METHODS')?.split(',') || [
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'PATCH',
    'OPTIONS',
  ];
  const corsHeaders = configService
    .get<string>('CORS_ALLOWED_HEADERS')
    ?.split(',') || ['Content-Type', 'Authorization'];

  app.enableCors({
    origin: corsOrigin || ['http://localhost:3000', 'http://localhost:5173'],
    credentials: corsCredentials,
    methods: corsMethods,
    allowedHeaders: corsHeaders,
  });

  const port = configService.get<number>('PORT') || 3000;
  await app.listen(port);
  console.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();
