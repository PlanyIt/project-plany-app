import {
  IsString,
  IsBoolean,
  IsOptional,
  IsDate,
  IsArray,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateUserDto {
  @IsString()
  firebaseUid: string;

  @IsString()
  username: string;

  @IsString()
  email: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsBoolean()
  isPremium?: boolean;

  @IsOptional()
  @IsString()
  photoUrl?: string;

  @IsOptional()
  @IsDate()
  @Type(() => Date)
  birthDate?: Date;

  @IsOptional()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  followers?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  following?: string[];
}
