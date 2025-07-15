import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { PasswordService } from './password.service';
import { LoginDto } from './dto/login.dto';
import { UserService } from 'src/user/user.service';
import { RegisterDto } from './dto/register.dto';
import { TokenService } from './token.service';
import { UserDocument } from 'src/user/schemas/user.schema';

/**
 * Service d'authentification et de gestion des utilisateurs
 * ---------------------------------------------------------
 * - Hash des mots de passe avec Argon2 (via PasswordService)
 * - Génération d'un couple access / refresh token via TokenService
 * - Rotation automatique du refresh token
 * - Validation stricte des entrées et gestion fine des exceptions
 */
@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UserService,
    private readonly passwordService: PasswordService,
    private readonly tokenService: TokenService,
  ) {}

  /* ------------------------------------------------------------------
     Helpers privés
  ------------------------------------------------------------------ */
  /**
   * Construit et retourne un couple { accessToken, refreshToken }
   * @param user Document Mongoose de l'utilisateur
   */
  private async issueTokens(user: UserDocument) {
    const payload = {
      sub: user._id.toString(),
      email: user.email,
      username: user.username,
    };

    return {
      accessToken: this.tokenService.signAccess(payload),
      refreshToken: await this.tokenService.signRefresh(user._id.toString()),
    };
  }

  /**
   * Retire le hash du mot de passe avant de retourner l'objet au client
   */
  private publicUser(u: UserDocument) {
    const { password, __v, ...rest } = u.toObject();
    return rest;
  }

  /* ------------------------------------------------------------------
     Authentification / validation
  ------------------------------------------------------------------ */
  async validateUser(
    email: string,
    password: string,
  ): Promise<UserDocument | null> {
    const user = await this.usersService.findOneByEmail(email);
    if (!user) return null;

    const isPasswordValid = await this.passwordService.verifyPassword(
      password,
      user.password,
    );
    return isPasswordValid ? user : null;
  }

  /* ------------------------------------------------------------------
     Login → retourne tokens + infos utilisateur
  ------------------------------------------------------------------ */
  async login(dto: LoginDto) {
    const user = await this.validateUser(dto.email, dto.password);
    if (!user)
      throw new UnauthorizedException('Email ou mot de passe incorrect');

    const { accessToken, refreshToken } = await this.issueTokens(user);

    return {
      accessToken,
      refreshToken,
      currentUser: this.publicUser(user),
    };
  }

  /* ------------------------------------------------------------------
     Register → crée utilisateur + retourne tokens
  ------------------------------------------------------------------ */
  async register(dto: RegisterDto) {
    // 1. Unicité email / username
    if (await this.usersService.findOneByEmail(dto.email)) {
      throw new BadRequestException('Cet email est déjà utilisé');
    }
    if (await this.usersService.findOneByUsername(dto.username)) {
      throw new BadRequestException("Ce nom d'utilisateur est déjà pris");
    }

    // 2. Hash du mot de passe
    const hashedPassword = await this.passwordService.hashPassword(
      dto.password,
    );

    // 3. Persistance de l'utilisateur
    const newUser = await this.usersService.create({
      ...dto,
      password: hashedPassword,
    });

    // 4. Émission des tokens
    const { accessToken, refreshToken } = await this.issueTokens(newUser);

    return {
      accessToken,
      refreshToken,
      currentUser: this.publicUser(newUser),
    };
  }

  /* ------------------------------------------------------------------
     Changement de mot de passe (révoque tous les refresh existentes)
  ------------------------------------------------------------------ */
  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string,
  ): Promise<void> {
    const user = await this.usersService.findById(userId);
    if (!user) throw new UnauthorizedException('Utilisateur non trouvé');

    const passwordValid = await this.passwordService.verifyPassword(
      currentPassword,
      user.password,
    );
    if (!passwordValid)
      throw new UnauthorizedException('Mot de passe actuel incorrect');

    // Validation basique de robustesse
    if (
      newPassword.length < 8 ||
      !/[A-Z]/.test(newPassword) ||
      !/[a-z]/.test(newPassword) ||
      !/\d/.test(newPassword)
    ) {
      throw new BadRequestException(
        'Le nouveau mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule et un chiffre',
      );
    }

    // Mise à jour et révocation des refresh tokens existants
    const hashedPassword = await this.passwordService.hashPassword(newPassword);
    await this.usersService.updateById(userId, { password: hashedPassword });
    await this.tokenService.revokeAllForUser(userId); // méthode à implémenter dans TokenService
  }

  /* ------------------------------------------------------------------
     Refresh et Logout (optionnel : exposés via AuthController)
  ------------------------------------------------------------------ */
  async refresh(rt: string) {
    const payload = await this.tokenService.verifyRefresh(rt);
    const user = await this.usersService.findById(payload.sub);
    const { accessToken, refreshToken } = await this.issueTokens(user);
    return { accessToken, refreshToken };
  }

  async logout(rt: string) {
    await this.tokenService.revokeFromJwt(rt);
  }
}
