import {
  IsNumber,
  IsPositive,
  IsString,
  IsUrl,
  IsOptional,
  IsLatitude,
  IsLongitude,
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

  @IsPositive()
  @IsNumber()
  duration: number;

  @IsNumber()
  cost: number;
}
