import { Type } from 'class-transformer';
import {
  IsString,
  IsBoolean,
  IsOptional,
  IsArray,
  ArrayNotEmpty,
  IsNotEmpty,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class PlanDto {
  @ApiProperty({
    description: 'The title of the plan',
    example: 'Trip to Paris',
  })
  @IsString()
  title: string;

  @ApiProperty({
    description: 'The description of the plan',
    example: 'A wonderful trip to the city of lights',
  })
  @IsString()
  description: string;

  @ApiProperty({
    description: 'Whether the plan is public or private',
    example: true,
    required: false,
  })
  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;

  @ApiProperty({
    description: 'The category of the plan',
    example: 'Travel',
  })
  @IsString()
  category: string;

  @ApiProperty({
    description: 'The unique identifier of the user who created the plan',
    example: '507f1f77bcf86cd799439012',
  })
  @IsString()
  userId: string;

  @ApiProperty({
    description: 'Array of steps for the plan',
    type: [String],
    example: [
      'Book flight tickets',
      'Reserve hotel',
      'Visit Eiffel Tower',
      'Go to Louvre Museum',
    ],
  })
  @IsArray()
  @Type(() => String)
  @IsString({ each: true })
  @IsArray({ message: 'Les étapes doivent être un tableau' })
  @ArrayNotEmpty({ message: 'Un plan doit contenir au moins une étape' })
  @IsNotEmpty({ each: true, message: 'Chaque étape doit contenir du texte' })
  steps: string[];

  @ApiProperty({
    description: 'Array of user IDs who favorited this plan',
    type: [String],
    example: ['507f1f77bcf86cd799439013'],
    required: false,
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  favorites?: string[];
}
