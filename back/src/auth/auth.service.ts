import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserService } from '../user/user.service';
import * as bcrypt from 'bcrypt';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
  ) {}

  async validateUser(email: string, password: string): Promise<any> {
    const user = await this.userService.findOneByEmail(email);
    if (!user) {
      throw new UnauthorizedException('Identifiants invalides');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Identifiants invalides');
    }

    return user;
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
        isPremium: user.isPremium || false,
        photoUrl: user.photoUrl || null,
      },
    };
  }

  async register(registerDto: RegisterDto) {
    // Vérifier si l'email est déjà utilisé
    const existingEmail = await this.userService.findOneByEmail(
      registerDto.email,
    );
    if (existingEmail) {
      throw new BadRequestException('Cet email est déjà utilisé');
    }

    // Vérifier si le nom d'utilisateur est déjà utilisé
    const existingUsername = await this.userService.findOneByUsername(
      registerDto.username,
    );
    if (existingUsername) {
      throw new BadRequestException("Ce nom d'utilisateur est déjà utilisé");
    }

    // Hacher le mot de passe
    const hashedPassword = await bcrypt.hash(registerDto.password, 12);

    // Créer l'utilisateur
    const newUser = await this.userService.create({
      ...registerDto,
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
        isPremium: newUser.isPremium || false,
        photoUrl: newUser.photoUrl || null,
      },
    };
  }

  async refreshToken(userId: string) {
    const user = await this.userService.findById(userId);
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
