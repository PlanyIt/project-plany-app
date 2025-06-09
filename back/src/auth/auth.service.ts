import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PasswordService } from './password.service';
import { CreateUserDto } from '../user/dto/create-user.dto';
import { LoginRequestDto } from './dto/login/login-request.dto';
import { UserService } from 'src/user/user.service';
import { LoginResponseDto } from './dto/login/login-response.dto';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UserService,
    private jwtService: JwtService,
    private passwordService: PasswordService,
  ) {}

  async validateUser(email: string, password: string): Promise<any> {
    const user = await this.usersService.findOneByEmail(email);

    if (!user) {
      return null;
    }

    // Tenter avec Argon2 d'abord, puis avec bcrypt si nécessaire
    let isPasswordValid = false;

    try {
      isPasswordValid = await this.passwordService.verifyPassword(
        password,
        user.password,
      );
    } catch (e) {
      isPasswordValid = await this.passwordService.verifyLegacyPassword(
        password,
        user.password,
      );

      if (!isPasswordValid) {
        throw new UnauthorizedException('Mot de passe incorrect', e.message);
      }
    }

    if (isPasswordValid) {
      const { password, ...result } = user.toObject();
      return result;
    }

    return null;
  }

  async login(loginRequestDto: LoginRequestDto): Promise<LoginResponseDto> {
    const user = await this.validateUser(
      loginRequestDto.email,
      loginRequestDto.password,
    );

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = {
      sub: user._id,
      email: user.email,
      username: user.username,
    };

    return {
      token: this.jwtService.sign(payload, { expiresIn: '10m' }),
      userId: user._id.toString(),
    };
  }

  async register(createUserDto: CreateUserDto) {
    // Hacher le mot de passe avec notre service spécialisé
    const hashedPassword = await this.passwordService.hashPassword(
      createUserDto.password,
    );

    // Créer l'utilisateur avec le mot de passe déjà haché
    const newUser = await this.usersService.create({
      ...createUserDto,
      password: hashedPassword,
      isActive: true,
    });

    // Générer un token JWT
    const payload = {
      sub: newUser._id,
      email: newUser.email,
      username: newUser.username,
    };

    return {
      access_token: this.jwtService.sign(payload, { expiresIn: '10m' }),
      user: {
        id: newUser._id,
        email: newUser.email,
        username: newUser.username,
        isPremium: newUser.isPremium || false,
        photoUrl: newUser.photoUrl || null,
      },
    };
  }

  async validateToken(token: string): Promise<boolean> {
    try {
      const decoded = this.jwtService.verify(token);
      return !!decoded;
    } catch (e) {
      throw new UnauthorizedException('Token invalide ou expiré');
    }
  }
}
