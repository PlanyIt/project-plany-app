import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import {
  applySecurity,
  validateEnvOrThrow,
} from './infrastructure/security.setup';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: false });
  const configService = app.get(ConfigService);

  validateEnvOrThrow(configService);

  // Applique toute la couche sécurité
  await applySecurity(app, configService);

  const port = configService.get<number>('PORT') ?? 3000;
  await app.listen(port);
  console.log(`🚀  API ready on ${await app.getUrl()}`);
}
bootstrap();
