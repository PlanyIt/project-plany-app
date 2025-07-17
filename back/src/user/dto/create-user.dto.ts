import {
  IsBoolean,
  IsDate,
  IsEmail,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUrl,
  MaxLength,
  MinLength,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(20)
  @Transform(({ value }) => value?.trim())
  username: string;

  @IsEmail()
  @IsNotEmpty()
  @MaxLength(100)
  @Transform(({ value }) => value?.toLowerCase().trim())
  email: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  @MaxLength(128)
  password: string;

  @IsOptional()
  @IsString()
  @MaxLength(500, {
    message: 'La description ne peut pas dépasser 500 caractères',
  })
  description?: string;

  @IsOptional()
  @IsBoolean()
  isPremium?: boolean;

  @IsOptional()
  @IsUrl({}, { message: "L'URL de la photo doit être valide" })
  @MaxLength(255)
  photoUrl?: string;

  @IsOptional()
  @IsDate()
  @Type(() => Date)
  birthDate?: Date;

  @IsOptional()
  @IsString()
  @IsIn(['Homme', 'Femme', 'Non-binaire', 'Préfère ne pas préciser'], {
    message: 'Le genre doit être: homme, femme, autre ou non-specifie',
  })
  gender?: string;

  @IsOptional()
  @IsString()
  @IsIn(['user', 'admin'], { message: 'Le rôle doit être user ou admin' })
  role?: string;
}
