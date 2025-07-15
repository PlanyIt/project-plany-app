import {
  IsString,
  IsNotEmpty,
  MinLength,
  MaxLength,
  IsHexColor,
} from 'class-validator';

export class CategoryDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(50, { message: 'Le nom ne peut pas dépasser 50 caractères' })
  name: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(50, { message: "L'icône ne peut pas dépasser 50 caractères" })
  icon: string;

  @IsString()
  @IsNotEmpty()
  @IsHexColor({
    message: 'La couleur doit être un code hexadécimal valide (ex: #FF0000)',
  })
  color: string;
}
