import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { applySecurity, validateEnvOrThrow } from './common/security.setup';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);

  validateEnvOrThrow(configService);

  await applySecurity(app, configService);

  const port = configService.get<number>('PORT') ?? 3000;
  await app.listen(port);
  console.log(`🚀  API ready on ${await app.getUrl()}`);
}
bootstrap();
