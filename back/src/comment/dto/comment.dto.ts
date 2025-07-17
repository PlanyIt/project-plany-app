import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsArray,
  MinLength,
  MaxLength,
  IsMongoId,
  IsUrl,
} from 'class-validator';

export class CommentDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(1, { message: 'Le commentaire ne peut pas être vide' })
  @MaxLength(500, {
    message: 'Le commentaire ne peut pas dépasser 500 caractères',
  })
  content: string;

  @IsOptional()
  @IsString()
  @IsMongoId({
    message: "L'ID utilisateur doit être un ObjectId MongoDB valide",
  })
  user?: string;

  @IsString()
  @IsNotEmpty()
  @IsMongoId({ message: "L'ID du plan doit être un ObjectId MongoDB valide" })
  planId: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @IsMongoId({
    each: true,
    message: 'Chaque like doit être un ObjectId MongoDB valide',
  })
  likes?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @IsMongoId({
    each: true,
    message: 'Chaque réponse doit être un ObjectId MongoDB valide',
  })
  responses?: string[];

  @IsOptional()
  @IsUrl({}, { message: "L'URL de l'image doit être valide" })
  @MaxLength(255)
  imageUrl?: string;

  @IsOptional()
  @IsString()
  @IsMongoId({ message: "L'ID parent doit être un ObjectId MongoDB valide" })
  parentId?: string;
}
