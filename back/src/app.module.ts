import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UserModule } from './user/user.module';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PlanModule } from './plan/plan.module';
import { AuthModule } from './auth/auth.module';
import { CommentModule } from './comment/comment.module';
import { StepModule } from './step/step.module';
import { CategoryModule } from './category/category.module';
import { APP_GUARD } from '@nestjs/core';
import { ThrottleGuard } from './common/guards/throttle.guard';
import * as path from 'path';
import * as fs from 'fs';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
      cache: true,
      expandVariables: true,
      validate: (config) => {
        const requiredVars = ['MONGO_URI', 'JWT_SECRET'];
        const missingVars = requiredVars.filter((varName) => !config[varName]);

        if (missingVars.length > 0) {
          console.error(
            `Missing required environment variables: ${missingVars.join(', ')}`,
          );

          // Vérifier si le fichier .env existe
          const envPath = path.resolve(process.cwd(), '.env');
          if (!fs.existsSync(envPath)) {
            console.error(`The .env file doesn't exist at ${envPath}`);
          } else {
            console.log(`The .env file exists at ${envPath}`);
          }
        }

        return config;
      },
    }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const uri = configService.get<string>('MONGO_URI');
        if (!uri) {
          throw new Error('MONGO_URI is not defined in environment variables');
        }
        return { uri };
      },
    }),
    UserModule,
    PlanModule,
    AuthModule,
    CommentModule,
    StepModule,
    CategoryModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: ThrottleGuard,
    },
  ],
})
export class AppModule {}
