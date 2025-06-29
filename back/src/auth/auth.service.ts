import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UserService } from '../user/user.service';
import { LoginRequestDto } from './dto/login/login-request.dto';
import { LoginResponseDto } from './dto/login/login-response.dto';
import { RegisterDto } from './dto/register.dto';
import { RefreshTokenService } from './refresh-token.service';
import { PasswordService } from './password.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly passwordService: PasswordService,
    private readonly refreshTokenService: RefreshTokenService,
  ) {}

  async login(loginRequestDto: LoginRequestDto): Promise<LoginResponseDto> {
    const { email, password } = loginRequestDto;

    // Trouver l'utilisateur par email
    const user = await this.userService.findByEmail(email);

    if (!user) {
      throw new UnauthorizedException('Identifiants invalides');
    }

    // Vérifier le mot de passe
    const isPasswordValid = await this.passwordService.verifyPassword(
      password,
      user.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Identifiants invalides');
    }

    // Générer les tokens
    const payload = {
      sub: (user._id as any).toString(),
      username: user.username,
    };
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get<string>('JWT_EXPIRES_IN') || '15m',
    });
    const refreshToken = await this.refreshTokenService.generateRefreshToken(
      (user._id as any).toString(),
    );

    return {
      accessToken: accessToken,
      refreshToken: refreshToken,
      user_id: (user._id as any).toString(),
      user: {
        id: (user._id as any).toString(),
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
      throw new UnauthorizedException('Cet email est déjà utilisé');
    }

    const existingUsername = await this.userService.findByUsername(username);
    if (existingUsername) {
      throw new UnauthorizedException("Ce nom d'utilisateur est déjà utilisé");
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
    const payload = {
      sub: (user._id as any).toString(),
      username: user.username,
    };
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get<string>('JWT_EXPIRES_IN') || '15m',
    });
    const refreshToken = await this.refreshTokenService.generateRefreshToken(
      (user._id as any).toString(),
    );

    return {
      accessToken: accessToken,
      refreshToken: refreshToken,
      user_id: (user._id as any).toString(),
      user: {
        id: (user._id as any).toString(),
        username: user.username,
        email: user.email,
      },
    };
  }
}
