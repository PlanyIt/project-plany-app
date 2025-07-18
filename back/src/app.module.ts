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

import { CacheModule } from '@nestjs/cache-manager';

@Module({
  imports: [
    CacheModule.register({
      isGlobal: true,
      ttl: 10,
      max: 100,
    }),
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: process.env.NODE_ENV === 'test' ? '.env.test' : '.env',
      cache: true,
      expandVariables: true,
      validate: (config) => {
        const requiredVars = ['MONGO_URI', 'JWT_SECRET_AT'];
        const missingVars = requiredVars.filter((varName) => !config[varName]);
        if (missingVars.length > 0) {
          console.error(
            `Missing required environment variables: ${missingVars.join(', ')}`,
          );
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
  providers: [AppService],
})
export class AppModule {}
