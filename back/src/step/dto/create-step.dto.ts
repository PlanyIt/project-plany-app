import {
  IsDate,
  IsNumber,
  IsPositive,
  IsString,
  IsUUID,
  IsUrl,
  IsOptional,
  IsLatitude,
  IsLongitude,
} from 'class-validator';

export class CreateStepDto {
  @IsUUID()
  stepId: string;

  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsOptional()
  @IsLatitude()
  latitude?: number;

  @IsOptional()
  @IsLongitude()
  longitude?: number;

  @IsNumber()
  @IsPositive()
  order: number;

  @IsUUID()
  planId: string;

  @IsOptional()
  @IsUrl()
  image?: string;

  @IsOptional()
  @IsDate()
  start?: Date;

  @IsOptional()
  @IsDate()
  end?: Date;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  duration?: number;

  @IsOptional()
  @IsNumber()
  cost?: number;

  @IsOptional()
  @IsDate()
  createdAt?: Date;

  @IsUUID()
  categoryId: string;
}
