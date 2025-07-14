import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';

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

  // Sécurité: Appliquer des en-têtes HTTP sécurisés
  app.use(helmet());

  // Validation des données entrantes
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Supprime les champs inutiles
      forbidNonWhitelisted: true, // Retourne une erreur si un champ non autorisé est présent
      transform: true, // Transforme les paramètres de requête en objets DTO
    }),
  );

  // Configuration CORS
  app.enableCors({
    origin: configService.get<string>('CORS_ORIGIN') || '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });

  const port = configService.get<number>('PORT') || 3000;
  await app.listen(port);
  console.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();
