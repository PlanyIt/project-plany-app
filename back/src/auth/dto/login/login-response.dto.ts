import { ApiProperty } from '@nestjs/swagger';

export class LoginResponseDto {
  @ApiProperty({
    description: 'The access token to be used for authentication',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  accessToken: string;

  @ApiProperty({
    description: 'The refresh token to be used for token renewal',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  refreshToken: string;

  @ApiProperty({
    description: 'The user ID',
    example: '507f1f77bcf86cd799439011',
  })
  user_id: string;

  @ApiProperty({
    description: 'The user information',
    type: 'object',
    properties: {
      id: {
        type: 'string',
        description: 'The unique identifier of the user',
        example: '507f1f77bcf86cd799439011',
      },
      username: {
        type: 'string',
        description: 'The username of the user',
        example: 'john_doe',
      },
      email: {
        type: 'string',
        description: 'The email address of the user',
        example: 'user@example.com',
      },
    },
  })
  user: {
    id: string;
    username: string;
    email: string;
  };
}
