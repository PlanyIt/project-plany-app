import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
  Matches,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({
    description: "Nom d'utilisateur unique",
    example: 'john_doe',
    minLength: 3,
  })
  @IsString()
  @IsNotEmpty()
  username: string;

  @ApiProperty({
    description: "Adresse email de l'utilisateur",
    example: 'john.doe@example.com',
    format: 'email',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({
    description: 'Mot de passe sécurisé',
    example: 'StrongPassword123',
    minLength: 8,
    format: 'password',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(8, {
    message: 'Le mot de passe doit contenir au moins 8 caractères',
  })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message:
      'Le mot de passe doit contenir au moins une lettre majuscule, une lettre minuscule et un chiffre',
  })
  password: string;

  @ApiProperty({
    description: "Description personnelle de l'utilisateur",
    example: 'Passionné de voyage et de photographie',
    required: false,
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'URL de la photo de profil',
    example: 'https://example.com/profile-photo.jpg',
    required: false,
  })
  @IsString()
  @IsOptional()
  photoUrl?: string;
}
