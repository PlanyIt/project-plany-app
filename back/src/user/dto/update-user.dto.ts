import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';
import {
  IsString,
  IsBoolean,
  IsOptional,
  IsDate,
  IsUrl,
  MaxLength,
  IsIn,
  IsNotEmpty,
  MinLength,
  IsEmail,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';

export class UpdateUserDto extends PartialType(CreateUserDto) {
  // Tous les champs sont optionnels pour une mise à jour
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(20)
  @Transform(({ value }) => value?.trim())
  username?: string;

  @IsEmail()
  @IsNotEmpty()
  @MaxLength(100)
  @Transform(({ value }) => value?.toLowerCase().trim())
  email?: string;

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
}
