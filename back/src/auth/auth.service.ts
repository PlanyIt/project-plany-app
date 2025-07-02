import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PasswordService } from './password.service';
import { CreateUserDto } from '../user/dto/create-user.dto';
import { LoginDto } from './dto/login.dto';
import { UserService } from 'src/user/user.service';

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

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.email, loginDto.password);

    const payload = {
      sub: user._id,
      email: user.email,
      username: user.username,
    };

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user._id,
        email: user.email,
        username: user.username,
        description: user.description || null,
        isPremium: user.isPremium || false,
        photoUrl: user.photoUrl || null,
        birthdate: user.birthdate || null,
        gender: user.gender || null,
        followers: user.followers || [],
        following: user.following || [],
      },
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
      access_token: this.jwtService.sign(payload),
      user: {
        id: newUser._id,
        email: newUser.email,
        username: newUser.username,
      },
    };
  }

  async refreshToken(userId: string) {
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new UnauthorizedException('Utilisateur non trouvé');
    }

    const payload = {
      sub: user._id,
      email: user.email,
      username: user.username,
    };

    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
