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
  @Type(() => String)
  steps: string[];
}
