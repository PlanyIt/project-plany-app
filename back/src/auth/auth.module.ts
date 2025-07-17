import { Module, forwardRef } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';

import { AuthService } from './auth.service';
import { PasswordService } from './password.service';
import { TokenService } from './token.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AuthController } from './auth.controller';

import { UserModule } from '../user/user.module';

import {
  RefreshToken,
  RefreshTokenSchema,
} from './schemas/refresh-token.schema';

@Module({
  imports: [
    forwardRef(() => UserModule),

    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => {
        const secret = cfg.get<string>('JWT_SECRET_AT');
        if (!secret) throw new Error('JWT_SECRET_AT variable missing');

        return {
          secret,
          signOptions: { expiresIn: cfg.get('JWT_AT_EXPIRES_IN') || '15m' },
        };
      },
    }),

    MongooseModule.forFeature([
      { name: RefreshToken.name, schema: RefreshTokenSchema },
    ]),
  ],

  controllers: [AuthController],

  providers: [AuthService, PasswordService, JwtStrategy, TokenService],

  exports: [AuthService, PasswordService, TokenService, JwtModule],
})
export class AuthModule {}
