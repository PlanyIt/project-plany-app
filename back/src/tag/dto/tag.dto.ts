import { IsString, IsNotEmpty } from 'class-validator';

export class TagDto {
  @IsString()
  @IsNotEmpty()
  name: string;
}
