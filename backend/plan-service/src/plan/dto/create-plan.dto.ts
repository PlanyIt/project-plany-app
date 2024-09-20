import {
  IsString,
  IsNotEmpty,
  IsBoolean,
  IsOptional,
  IsArray,
  IsInt,
} from 'class-validator';

export class CreatePlanDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsBoolean()
  isPublic: boolean;

  @IsBoolean()
  isPremium: boolean;

  @IsOptional()
  @IsArray()
  tags: string[]; // IDs des tags

  @IsOptional()
  category: string; // ID de la catégorie

  @IsOptional()
  type: string; // ID du type

  @IsOptional()
  @IsInt()
  minPerson: number;

  @IsOptional()
  @IsInt()
  maxPerson: number;

  @IsOptional()
  image: string; // URL ou chemin de l'image
}
