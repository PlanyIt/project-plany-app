import { IsJWT, IsNotEmpty } from 'class-validator';

export class RefreshDto {
  @IsNotEmpty()
  @IsJWT({ message: 'Le refreshToken doit être un JWT valide' })
  refreshToken: string;
}
