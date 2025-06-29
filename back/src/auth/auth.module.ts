import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { RefreshTokenService } from './refresh-token.service';
import { PasswordService } from './password.service';
import { UserModule } from '../user/user.module';
import { JwtStrategy } from './strategies/jwt.strategy';
import { RefreshTokenStrategy } from './strategies/refresh-token.strategy';

@Module({
  imports: [
    ConfigModule,
    UserModule,
    PassportModule,
    JwtModule.registerAsync({
      global: true,
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<string>('JWT_EXPIRES_IN') || '15m',
        },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    RefreshTokenService,
    PasswordService,
    JwtStrategy,
    RefreshTokenStrategy,
  ],
  exports: [AuthService, RefreshTokenService, PasswordService],
})
export class AuthModule {}
