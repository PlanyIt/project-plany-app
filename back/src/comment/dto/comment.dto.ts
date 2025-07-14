import { IsString, IsNotEmpty, IsOptional, IsArray } from 'class-validator';

export class CommentDto {
  @IsString()
  @IsNotEmpty()
  content: string;

  @IsOptional()
  @IsString()
  user?: string;

  @IsString()
  @IsNotEmpty()
  planId: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  likes?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  responses?: string[];

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsOptional()
  @IsString()
  parentId?: string;
}
