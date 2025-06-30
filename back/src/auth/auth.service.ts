import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from '../user/user.service';
import { LoginRequestDto } from './dto/login/login-request.dto';
import { LoginResponseDto } from './dto/login/login-response.dto';
import { RegisterDto } from './dto/register.dto';
import { RefreshTokenService } from './refresh-token.service';
import { PasswordService } from './password.service';
import {
  InvalidCredentialsException,
  ConflictException,
} from '../common/exceptions';
import { MetricsService } from '../metrics/metrics.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly passwordService: PasswordService,
    private readonly refreshTokenService: RefreshTokenService,
    private readonly metricsService: MetricsService,
  ) {}

  async login(loginRequestDto: LoginRequestDto): Promise<LoginResponseDto> {
    const { email, password } = loginRequestDto;

    this.metricsService.incrementLoginAttempts();

    // Trouver l'utilisateur par email
    const user = await this.userService.findByEmail(email);

    if (!user) {
      this.metricsService.incrementLoginFailed();
      throw new InvalidCredentialsException('Identifiants invalides');
    }

    // Vérifier le mot de passe
    const isPasswordValid = await this.passwordService.verifyPassword(
      password,
      user.password,
    );

    if (!isPasswordValid) {
      this.metricsService.incrementLoginFailed();
      throw new InvalidCredentialsException('Identifiants invalides');
    }

    // Générer les tokens
    const userId = (user._id as any).toString();
    const payload = {
      sub: userId,
      username: user.username,
      role: user.role, // Include user role in JWT payload
    };
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get<string>('JWT_EXPIRES_IN') || '15m',
    });
    const refreshToken =
      await this.refreshTokenService.generateRefreshToken(userId);

    this.metricsService.incrementLoginSuccess();

    return {
      accessToken,
      refreshToken,
      user_id: userId,
      user: {
        id: userId,
        username: user.username,
        email: user.email,
      },
    };
  }

  async register(registerDto: RegisterDto) {
    const { username, email, password } = registerDto;

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await this.userService.findByEmail(email);
    if (existingUser) {
      throw new ConflictException('Cet email est déjà utilisé');
    }

    const existingUsername = await this.userService.findByUsername(username);
    if (existingUsername) {
      throw new ConflictException("Ce nom d'utilisateur est déjà utilisé");
    }

    // Hasher le mot de passe
    const hashedPassword = await this.passwordService.hashPassword(password);

    // Créer l'utilisateur
    const user = await this.userService.create({
      username,
      email,
      password: hashedPassword,
    });

    // Générer les tokens
    const userId = (user._id as any).toString();
    const payload = {
      sub: userId,
      username: user.username,
      role: user.role, // Include user role in JWT payload
    };
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get<string>('JWT_EXPIRES_IN') || '15m',
    });
    const refreshToken =
      await this.refreshTokenService.generateRefreshToken(userId);

    return {
      accessToken,
      refreshToken,
      user_id: userId,
      user: {
        id: userId,
        username: user.username,
        email: user.email,
      },
    };
  }
}
