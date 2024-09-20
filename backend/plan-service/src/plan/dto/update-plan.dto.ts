import {
  IsArray,
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';

export class UpdatePlanDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;

  @IsOptional()
  @IsBoolean()
  isPremium?: boolean;

  @IsOptional()
  @IsArray()
  tags?: string[];

  @IsOptional()
  category?: string;

  @IsOptional()
  type?: string;

  @IsOptional()
  @IsInt()
  minPerson?: number;

  @IsOptional()
  @IsInt()
  maxPerson?: number;

  @IsOptional()
  image?: string;
}
