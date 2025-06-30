import { IsString, IsNotEmpty, IsOptional, IsArray } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CommentDto {
  @ApiProperty({
    description: 'The content of the comment',
    example: 'This is a great plan! Thanks for sharing.',
  })
  @IsString()
  content: string;

  @ApiProperty({
    description: 'The unique identifier of the user making the comment',
    example: '507f1f77bcf86cd799439012',
    required: false,
  })
  @IsOptional()
  @IsString()
  userId: string;

  @ApiProperty({
    description: 'The unique identifier of the plan being commented on',
    example: '507f1f77bcf86cd799439011',
  })
  @IsString()
  @IsNotEmpty()
  planId: string;

  @ApiProperty({
    description: 'Array of user IDs who liked the comment',
    type: [String],
    example: ['507f1f77bcf86cd799439013', '507f1f77bcf86cd799439014'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  likes: string[];

  @ApiProperty({
    description: 'Array of response comment IDs',
    type: [String],
    example: ['507f1f77bcf86cd799439015'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  responses?: string[];

  @ApiProperty({
    description: 'URL of an image attached to the comment',
    example: 'https://example.com/comment-image.jpg',
    required: false,
  })
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiProperty({
    description:
      'The unique identifier of the parent comment if this is a response',
    example: '507f1f77bcf86cd799439014',
    required: false,
  })
  @IsOptional()
  @IsString()
  parentId: string;
}
