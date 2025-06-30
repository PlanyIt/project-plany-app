import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CategoryDto {
  @ApiProperty({
    description: 'The name of the category',
    example: 'Travel',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'The icon emoji for the category',
    example: '✈️',
  })
  @IsString()
  @IsNotEmpty()
  icon: string;

  @ApiProperty({
    description: 'The color code for the category (hexadecimal)',
    example: '#4CAF50',
  })
  @IsString()
  @IsNotEmpty()
  color: string;
}
