import { Type } from 'class-transformer';
import {
  IsString,
  IsBoolean,
  IsOptional,
  IsArray,
  IsNumber,
} from 'class-validator';

export class PlanDto {
  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;

  @IsBoolean()
  @IsOptional()
  isAccessible?: boolean;

  @IsString()
  category: string;

  @IsString()
  @IsOptional()
  user?: string;

  @IsArray()
  @Type(() => String)
  steps: string[];

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  favorites?: string[];

  @IsNumber()
  @IsOptional()
  totalCost?: number;

  @IsNumber()
  @IsOptional()
  totalDuration?: number;
}
