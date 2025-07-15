import {
  IsString,
  IsBoolean,
  IsOptional,
  IsArray,
  IsNumber,
  IsNotEmpty,
  MinLength,
  MaxLength,
  IsMongoId,
  ArrayMinSize,
  ArrayMaxSize,
  Min,
} from 'class-validator';

export class PlanDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(50, { message: 'Le titre ne peut pas dépasser 50 caractères' })
  title: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(1000, {
    message: 'La description ne peut pas dépasser 1000 caractères',
  })
  description: string;

  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;

  @IsBoolean()
  @IsOptional()
  isAccessible?: boolean;

  @IsString()
  @IsNotEmpty()
  @IsMongoId({
    message: "L'ID de catégorie doit être un ObjectId MongoDB valide",
  })
  category: string;

  @IsOptional()
  @IsString()
  @IsMongoId({
    message: "L'ID utilisateur doit être un ObjectId MongoDB valide",
  })
  user?: string;

  @IsArray()
  @ArrayMinSize(1, { message: 'Un plan doit contenir au moins une étape' })
  @ArrayMaxSize(20, {
    message: 'Un plan ne peut pas contenir plus de 20 étapes',
  })
  @IsMongoId({
    each: true,
    message: 'Chaque étape doit être un ObjectId MongoDB valide',
  })
  steps: string[];

  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  @IsMongoId({
    each: true,
    message: 'Chaque favori doit être un ObjectId MongoDB valide',
  })
  favorites?: string[];

  @IsNumber()
  @IsOptional()
  @Min(0, { message: 'Le coût total ne peut pas être négatif' })
  totalCost?: number;

  @IsNumber()
  @IsOptional()
  @Min(0, { message: 'La durée totale ne peut pas être négative' })
  totalDuration?: number;
}
