import { Module, MiddlewareConsumer } from '@nestjs/common';
import { UserModule } from './user/user.module';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PlanModule } from './plan/plan.module';
import { AuthModule } from './auth/auth.module';
import { CommentModule } from './comment/comment.module';
import { StepModule } from './step/step.module';
import { CategoryModule } from './category/category.module';
import { HealthModule } from './health/health.module';
import { MetricsModule } from './metrics/metrics.module';
import { LoggingModule } from './common/logging/logging.module';
import { APP_GUARD, APP_FILTER } from '@nestjs/core';
import { ThrottleGuard } from './common/guards/throttle.guard';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { CacheModule } from '@nestjs/cache-manager';
import { LoggerModule } from 'nestjs-pino';
import { AuditModule } from './audit/audit.module';
import { ScheduleModule } from '@nestjs/schedule';
import { MetricsMiddleware } from './common/middleware/metrics.middleware';

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
          throw new Error(
            `Missing required environment variables: ${missingVars.join(', ')}`,
          );
        }

        return config;
      },
    }),
    // Configuration Cache en mémoire
    CacheModule.register({
      isGlobal: true,
      ttl: 600, // 10 minutes
    }),
    // Configuration du logging structuré
    LoggerModule.forRoot({
      pinoHttp: {
        transport: {
          target: 'pino-pretty',
          options: {
            singleLine: true,
          },
        },
      },
    }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        uri: configService.get<string>('MONGO_URI'),
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 5000,
        socketTimeoutMS: 45000,
      }),
    }),
    ScheduleModule.forRoot(),
    LoggingModule,
    HealthModule,
    MetricsModule,
    AuditModule,
    UserModule,
    PlanModule,
    AuthModule,
    CommentModule,
    StepModule,
    CategoryModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottleGuard,
    },
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },
  ],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(MetricsMiddleware).forRoutes('*');
  }
}
