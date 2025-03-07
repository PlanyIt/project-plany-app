import { IsString, IsNotEmpty, IsOptional, IsArray } from 'class-validator';

export class CommentDto {
  @IsString()
  @IsNotEmpty()
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
  photoUrl?: string;

  @IsOptional()
  @IsString()
  parentId: string;
}
