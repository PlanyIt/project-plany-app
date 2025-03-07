import { IsString, IsBoolean, IsOptional } from 'class-validator';

export class CreatePlanDto {
  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;

  @IsString()
  photo: string;
}
