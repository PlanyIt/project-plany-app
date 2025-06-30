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
import { ApiProperty } from '@nestjs/swagger';

export class StepDto {
  @ApiProperty({
    description: 'The title of the step',
    example: 'Visit Eiffel Tower',
  })
  @IsString()
  title: string;

  @ApiProperty({
    description: 'The detailed description of the step',
    example: 'Go to the iconic Eiffel Tower and take amazing photos',
  })
  @IsString()
  description: string;

  @ApiProperty({
    description: 'The latitude coordinate of the step location',
    example: 48.8584,
    required: false,
  })
  @IsOptional()
  @IsLatitude()
  latitude?: number;

  @ApiProperty({
    description: 'The longitude coordinate of the step location',
    example: 2.2945,
    required: false,
  })
  @IsOptional()
  @IsLongitude()
  longitude?: number;

  @ApiProperty({
    description: 'The order position of this step in the plan',
    example: 1,
  })
  @IsNumber()
  @IsPositive()
  order: number;

  @ApiProperty({
    description: 'URL of an image representing this step',
    example: 'https://example.com/eiffel-tower.jpg',
  })
  @IsUrl()
  image: string;

  @ApiProperty({
    description: 'Estimated duration for this step',
    example: '2 hours',
    required: false,
  })
  @IsOptional()
  @IsString()
  duration?: string;

  @ApiProperty({
    description: 'Estimated cost for this step in euros',
    example: 25.5,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  cost?: number;

  @ApiProperty({
    description: 'The unique identifier of the user who created this step',
    example: '507f1f77bcf86cd799439012',
  })
  @IsString()
  @IsNotEmpty()
  userId: string;
}
