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

  //je met categoryId required false: on a pas de categoryId, on ne peut pas mettre une catégorie 
  //TODO après la crétion du module Catégorie
  @IsOptional()
  @IsString()
  categoryId: string;
}

