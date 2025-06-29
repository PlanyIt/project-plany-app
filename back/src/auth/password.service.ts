import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

@Injectable()
export class PasswordService {
  private readonly saltRounds = 10;

  /**
   * Hache un mot de passe en utilisant bcrypt
   */
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, this.saltRounds);
  }

  /**
   * Vérifie si un mot de passe correspond à un hash
   */
  async comparePassword(
    password: string,
    hashedPassword: string,
  ): Promise<boolean> {
    return bcrypt.compare(password, hashedPassword);
  }

  async verifyPassword(
    password: string,
    hashedPassword: string,
  ): Promise<boolean> {
    return bcrypt.compare(password, hashedPassword);
  }

  async verifyLegacyPassword(
    password: string,
    hashedPassword: string,
  ): Promise<boolean> {
    // Pour les anciens mots de passe qui peuvent utiliser un autre algorithme
    // ou pour la rétrocompatibilité
    return bcrypt.compare(password, hashedPassword);
  }
}
