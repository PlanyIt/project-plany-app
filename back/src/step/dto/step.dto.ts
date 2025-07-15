import {
  IsNumber,
  IsPositive,
  IsString,
  IsUrl,
  IsOptional,
  IsLatitude,
  IsLongitude,
  IsNotEmpty,
  MinLength,
  MaxLength,
  Min,
  Max,
} from 'class-validator';

export class StepDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100, { message: 'Le titre ne peut pas dépasser 100 caractères' })
  title: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(500, {
    message: 'La description ne peut pas dépasser 500 caractères',
  })
  description: string;

  @IsOptional()
  @IsLatitude({ message: 'La latitude doit être comprise entre -90 et 90' })
  latitude?: number;

  @IsOptional()
  @IsLongitude({ message: 'La longitude doit être comprise entre -180 et 180' })
  longitude?: number;

  @IsNumber()
  @IsPositive({ message: "L'ordre doit être un nombre positif" })
  @Min(1, { message: "L'ordre doit être au minimum 1" })
  @Max(100, { message: "L'ordre ne peut pas dépasser 100" })
  order: number;

  @IsUrl({}, { message: "L'image doit être une URL valide" })
  @MaxLength(255, {
    message: "L'URL de l'image ne peut pas dépasser 255 caractères",
  })
  image: string;

  @IsPositive({ message: 'La durée doit être positive' })
  @IsNumber()
  @Min(1, { message: 'La durée doit être au minimum 1 minute' })
  duration: number;

  @IsNumber()
  @Min(0, { message: 'Le coût ne peut pas être négatif' })
  cost: number;
}
