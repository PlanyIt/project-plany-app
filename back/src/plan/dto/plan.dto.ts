import { Type } from 'class-transformer';
import { IsString, IsBoolean, IsOptional, IsArray } from 'class-validator';

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
  @IsString({ each: true })
  tags: string[];

  @IsArray()
  @Type(() => String)
  steps: string[];

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  favorites?: string[];
}
