import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { Auth0Strategy } from './auth0.strategy';
import { JwtAuthGuard } from 'src/common/guards/jwt-auth-guard';
import { JwtConfigService } from 'src/config/jwt.config';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      useClass: JwtConfigService,
    }),
  ],
  providers: [AuthService, Auth0Strategy, JwtAuthGuard],
  controllers: [AuthController],
})
export class AuthModule {}
