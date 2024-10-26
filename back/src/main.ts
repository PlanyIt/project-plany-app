import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Supprime les champs inutiles
      forbidNonWhitelisted: true, // Retourne une erreur si un champ non autorisé est présent
      transform: true, // Transforme les paramètres de requête en objets DTO
    }),
  );

  app.enableCors();

  await app.listen(3000);
}
bootstrap();
