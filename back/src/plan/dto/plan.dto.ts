import { Type } from 'class-transformer';
import {
  IsString,
  IsBoolean,
  IsOptional,
  IsArray,
  ArrayNotEmpty,
  IsNotEmpty,
} from 'class-validator';

export class PlanDto {
  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;

  @IsString()
  category: string;

  @IsString()
  userId: string;

  @IsArray()
  @Type(() => String)
  @IsString({ each: true })
  @IsArray({ message: 'Les étapes doivent être un tableau' })
  @ArrayNotEmpty({ message: 'Un plan doit contenir au moins une étape' })
  @IsNotEmpty({ each: true, message: 'Chaque étape doit contenir du texte' })
  steps: string[];

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  favorites?: string[];
}
