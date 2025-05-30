import { IsString, IsNotEmpty, IsOptional, IsArray } from 'class-validator';

export class CommentDto {
  @IsString()
  content: string;

  @IsOptional()
  @IsString()
  userId: string;

  @IsString()
  @IsNotEmpty()
  planId: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  likes: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  responses?: string[];

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsOptional()
  @IsString()
  parentId: string;
}
