import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginRequestDto } from './dto/login/login-request.dto';
import { RegisterDto } from './dto/register.dto';
import { LoginResponseDto } from './dto/login/login-response.dto';
import { RefreshTokenService } from './refresh-token.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthThrottle } from '../common/decorators/throttle.decorator';

@Controller('api/auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly refreshTokenService: RefreshTokenService,
  ) {}

  @Post('login')
  @AuthThrottle() // 5 tentatives par minute
  async login(
    @Body() loginRequestDto: LoginRequestDto,
  ): Promise<LoginResponseDto> {
    return this.authService.login(loginRequestDto);
  }

  @Post('register')
  @AuthThrottle() // 5 tentatives par minute
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('refresh')
  async refresh(@Body() body: { refreshToken: string }) {
    return this.refreshTokenService.refreshTokens(body.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  async logout() {
    // Optionnel: invalider le refresh token côté serveur
    return { message: 'Déconnexion réussie' };
  }
}
