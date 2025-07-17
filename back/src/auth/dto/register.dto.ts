import { Transform } from 'class-transformer';
import {
  IsEmail,
  IsNotEmpty,
  IsString,
  MinLength,
  Matches,
  MaxLength,
  IsAlphanumeric,
} from 'class-validator';

export class RegisterDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(3, {
    message: "Le nom d'utilisateur doit contenir au moins 3 caractères",
  })
  @MaxLength(20, {
    message: "Le nom d'utilisateur ne peut pas dépasser 20 caractères",
  })
  @IsAlphanumeric('en-US', {
    message:
      "Le nom d'utilisateur ne peut contenir que des lettres et chiffres",
  })
  @Transform(({ value }) => value?.trim())
  username: string;

  @IsEmail({}, { message: "L'email doit être valide" })
  @IsNotEmpty()
  @MaxLength(100, { message: "L'email ne peut pas dépasser 100 caractères" })
  @Transform(({ value }) => value?.toLowerCase().trim())
  email: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(8, {
    message: 'Le mot de passe doit contenir au moins 8 caractères',
  })
  @MaxLength(128, {
    message: 'Le mot de passe ne peut pas dépasser 128 caractères',
  })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message:
      'Le mot de passe doit contenir au moins une lettre majuscule, une lettre minuscule et un chiffre',
  })
  password: string;
}
