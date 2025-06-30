import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';
import { IsString, IsBoolean, IsOptional, IsDate } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateUserDto extends PartialType(CreateUserDto) {
  @ApiProperty({
    description: 'Updated username',
    example: 'john_doe_updated',
    required: false,
  })
  @IsOptional()
  @IsString()
  username?: string;

  @ApiProperty({
    description: 'Updated email address',
    example: 'newemail@example.com',
    required: false,
  })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiProperty({
    description: 'Updated user description',
    example: 'Updated bio description',
    required: false,
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    description: 'Updated premium status',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  isPremium?: boolean;

  @ApiProperty({
    description: 'Updated profile photo URL',
    example: 'https://example.com/new-photo.jpg',
    required: false,
  })
  @IsOptional()
  @IsString()
  photoUrl?: string | null;

  @ApiProperty({
    description: 'Updated birth date',
    example: '1990-01-01',
    type: 'string',
    format: 'date',
    required: false,
  })
  @IsOptional()
  @IsDate()
  @Type(() => Date)
  birthDate?: Date;

  @ApiProperty({
    description: 'Updated gender',
    example: 'female',
    enum: ['male', 'female', 'other'],
    required: false,
  })
  @IsOptional()
  @IsString()
  gender?: string;
}
