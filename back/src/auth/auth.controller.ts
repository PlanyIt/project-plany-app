import {
  Body,
  Controller,
  Post,
  UseGuards,
  Get,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBody,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginRequestDto } from './dto/login/login-request.dto';
import { RegisterDto } from './dto/register.dto';
import { LoginResponseDto } from './dto/login/login-response.dto';
import { RefreshTokenService } from './refresh-token.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthThrottle } from '../common/decorators/throttle.decorator';

@ApiTags('Authentication')
@Controller('api/auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly refreshTokenService: RefreshTokenService,
  ) {}

  @Post('login')
  @AuthThrottle() // 5 tentatives par minute
  @ApiOperation({
    summary: 'User login',
    description:
      'Authenticate a user with email and password to get access and refresh tokens',
  })
  @ApiBody({
    type: LoginRequestDto,
    description: 'User credentials',
    examples: {
      'Login Example': {
        value: {
          email: 'user@example.com',
          password: 'password123',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'User authenticated successfully',
    type: LoginResponseDto,
    example: {
      accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      refreshToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      user_id: '507f1f77bcf86cd799439011',
      user: {
        id: '507f1f77bcf86cd799439011',
        username: 'john_doe',
        email: 'user@example.com',
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid credentials',
    schema: {
      example: {
        statusCode: 401,
        message: 'Invalid credentials',
        error: 'Unauthorized',
      },
    },
  })
  @ApiResponse({
    status: 429,
    description: 'Too many requests',
    schema: {
      example: {
        statusCode: 429,
        message: 'Too many requests',
        error: 'Throttler',
      },
    },
  })
  async login(
    @Body() loginRequestDto: LoginRequestDto,
  ): Promise<LoginResponseDto> {
    return this.authService.login(loginRequestDto);
  }

  @Post('register')
  @AuthThrottle() // 5 tentatives par minute
  @ApiOperation({
    summary: 'User registration',
    description: 'Create a new user account with username, email and password',
  })
  @ApiBody({
    type: RegisterDto,
    description: 'User registration data',
    examples: {
      'Registration Example': {
        value: {
          username: 'john_doe',
          email: 'john.doe@example.com',
          password: 'StrongPassword123',
          description: 'Hello, I am John!',
          photoUrl: 'https://example.com/photo.jpg',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'User registered successfully',
    schema: {
      example: {
        message: 'User registered successfully',
        user: {
          id: '507f1f77bcf86cd799439011',
          username: 'john_doe',
          email: 'john.doe@example.com',
          role: 'user',
          isActive: true,
        },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid data or user already exists',
    schema: {
      example: {
        statusCode: 400,
        message: ['Email already exists', 'Password too weak'],
        error: 'Bad Request',
      },
    },
  })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('refresh')
  @ApiOperation({
    summary: 'Refresh access token',
    description: 'Generate a new access token using a valid refresh token',
  })
  @ApiBody({
    description: 'Refresh token',
    schema: {
      type: 'object',
      properties: {
        refreshToken: {
          type: 'string',
          example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        },
      },
      required: ['refreshToken'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Token refreshed successfully',
    schema: {
      example: {
        accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        refreshToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid or expired refresh token',
    schema: {
      example: {
        statusCode: 401,
        message: 'Invalid refresh token',
        error: 'Unauthorized',
      },
    },
  })
  async refresh(@Body() body: { refreshToken: string }) {
    return this.refreshTokenService.refreshTokens(body.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'User logout',
    description: 'Logout the current user and invalidate the session',
  })
  @ApiResponse({
    status: 201,
    description: 'Logout successful',
    schema: {
      example: {
        message: 'Déconnexion réussie',
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid token',
    schema: {
      example: {
        statusCode: 401,
        message: 'Unauthorized',
        error: 'Unauthorized',
      },
    },
  })
  async logout() {
    // Optionnel: invalider le refresh token côté serveur
    return { message: 'Déconnexion réussie' };
  }

  @UseGuards(JwtAuthGuard)
  @Get('test')
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Test authentication',
    description: 'Test endpoint to verify JWT token authentication is working',
  })
  @ApiResponse({
    status: 200,
    description: 'Authentication successful',
    schema: {
      example: {
        message: 'Authentication successful',
        user: {
          userId: '507f1f77bcf86cd799439011',
          email: 'user@example.com',
        },
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  async testAuth(@Request() req: any) {
    return {
      message: 'Authentication successful',
      user: {
        userId: req.user.userId,
        email: req.user.email,
      },
    };
  }
}
