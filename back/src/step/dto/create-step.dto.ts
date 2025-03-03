import {
  IsDate,
  IsNumber,
  IsPositive,
  IsString,
  IsUrl,
  IsOptional,
  IsLatitude,
  IsLongitude,
  IsNotEmpty
} from 'class-validator';

export class CreateStepDto {
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

  @IsString()
  @IsNotEmpty()
  planId: string;

  @IsString()
  @IsNotEmpty()
  userId: string;
}

