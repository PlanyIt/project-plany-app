import { Injectable } from '@nestjs/common';
import * as argon2 from 'argon2';

@Injectable()
export class PasswordService {
  /**
   * Hache un mot de passe en utilisant Argon2id (plus sécurisé que bcrypt en 2025)
   */
  async hashPassword(plainPassword: string): Promise<string> {
    return argon2.hash(plainPassword, {
      type: argon2.argon2id,
      memoryCost: 65536, // 64 MiB
      timeCost: 3, // 3 itérations
      parallelism: 4, // 4 threads
    });
  }

  /**
   * Vérifie si un mot de passe correspond à un hash
   */
  async verifyPassword(
    plainPassword: string,
    hashedPassword: string,
  ): Promise<boolean> {
    return argon2.verify(hashedPassword, plainPassword);
  }

  /**
   * Pour la compatibilité avec les mots de passe existants hashés avec bcrypt
   */
  async verifyLegacyPassword(
    plainPassword: string,
    hashedPassword: string,
  ): Promise<boolean> {
    const bcrypt = await import('bcrypt');
    return bcrypt.compare(plainPassword, hashedPassword);
  }
}
