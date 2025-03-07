import {
  IsNumber,
  IsPositive,
  IsString,
  IsUrl,
  IsOptional,
  IsLatitude,
  IsLongitude,
  IsNotEmpty,
} from 'class-validator';

export class StepDto {
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

  @IsUrl()
  image: string;

  @IsOptional()
  @IsString()
  duration?: string;

  @IsOptional()
  @IsNumber()
  cost?: number;

  @IsString()
  @IsNotEmpty()
  userId: string;
}
