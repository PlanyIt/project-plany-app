import { IsString, Matches, MinLength } from 'class-validator';

/**
 * Données nécessaires au changement de mot de passe.
 */
export class ChangePasswordDto {
  @IsString()
  currentPassword: string;

  @IsString()
  @MinLength(8, { message: 'Au moins 8 caractères' })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/, {
    message:
      'Doit contenir au moins une majuscule, une minuscule et un chiffre',
  })
  newPassword: string;
}
