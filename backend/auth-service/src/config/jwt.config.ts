import { Injectable } from '@nestjs/common';
import { JwtOptionsFactory, JwtModuleOptions } from '@nestjs/jwt';

@Injectable()
export class JwtConfigService implements JwtOptionsFactory {
  createJwtOptions(): JwtModuleOptions {
    return {
      secret: process.env.JWT_SECRET, // Utilise le secret depuis le fichier .env
      signOptions: {
        expiresIn: process.env.JWT_EXPIRATION || '3600s', // Expiration du token
      },
    };
  }
}
