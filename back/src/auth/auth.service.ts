import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PasswordService } from './password.service';
import { CreateUserDto } from '../user/dto/create-user.dto';
import { LoginDto } from './dto/login.dto';
import { UserService } from 'src/user/user.service';

/**
 * Service d'authentification et de gestion des utilisateurs
 *
 * Ce service gère l'authentification JWT, la validation des mots de passe
 * et les opérations de connexion/inscription sécurisées.
 * Utilise Argon2 pour le hachage des mots de passe.
 *
 * @author Équipe Plany
 * @version 1.0.0
 */
@Injectable()
export class AuthService {
  constructor(
    private usersService: UserService,
    private jwtService: JwtService,
    private passwordService: PasswordService,
  ) {}

  /**
   * Valide les informations d'identification d'un utilisateur
   *
   * Vérifie l'email et le mot de passe en utilisant Argon2.
   *
   * @param email - Email de l'utilisateur
   * @param password - Mot de passe en clair
   * @returns Objet utilisateur sans le mot de passe si validation réussie, null sinon
   * @throws {UnauthorizedException} Si l'utilisateur n'existe pas ou mot de passe incorrect
   */
  async validateUser(email: string, password: string): Promise<any> {
    const user = await this.usersService.findOneByEmail(email);

    if (!user) {
      return null;
    }

    let isPasswordValid = false;

    try {
      isPasswordValid = await this.passwordService.verifyPassword(
        password,
        user.password,
      );
    } catch (e) {
      throw new UnauthorizedException(
        'Erreur de validation du mot de passe : ' + e.message,
      );
    }

    if (isPasswordValid) {
      const { ...result } = user.toObject();
      return result;
    }

    return null;
  }

  /**
   * Connecte un utilisateur et génère un token JWT
   *
   * @param loginDto - Données de connexion (email, password)
   * @returns Object contenant le token JWT et les informations utilisateur
   * @throws {UnauthorizedException} Si les identifiants sont incorrects
   */
  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.email, loginDto.password);

    if (!user) {
      throw new UnauthorizedException('Email ou mot de passe incorrect');
    }

    const payload = {
      sub: user._id,
      email: user.email,
      username: user.username,
    };

    return {
      token: this.jwtService.sign(payload),
      currentUser: {
        id: user._id,
        email: user.email,
        username: user.username,
        description: user.description || null,
        isPremium: user.isPremium || false,
        photoUrl: user.photoUrl || null,
        birthDate: user.birthDate || null,
        gender: user.gender || null,
        followers: user.followers || [],
        following: user.following || [],
      },
    };
  }

  /**
   * Enregistre un nouvel utilisateur
   *
   * Vérifie l'unicité de l'email et du nom d'utilisateur,
   * hache le mot de passe avec Argon2 et génère un token JWT.
   *
   * @param createUserDto - Données d'inscription
   * @returns Object contenant le token JWT et les informations du nouvel utilisateur
   * @throws {BadRequestException} Si email/username déjà utilisé ou erreur de validation
   *
   * @example
   * ```typescript
   * const newUser = await authService.register({
   *   username: 'john_doe',
   *   email: 'john@example.com',
   *   password: 'SecurePass123!'
   * });
   * ```
   */
  async register(createUserDto: CreateUserDto) {
    // Vérifier si l'email existe déjà
    const existingUserByEmail = await this.usersService.findOneByEmail(
      createUserDto.email,
    );
    if (existingUserByEmail) {
      throw new BadRequestException('Cet email est déjà utilisé');
    }

    // Vérifier si le nom d'utilisateur existe déjà
    const existingUserByUsername = await this.usersService.findOneByUsername(
      createUserDto.username,
    );
    if (existingUserByUsername) {
      throw new BadRequestException("Ce nom d'utilisateur est déjà pris");
    }

    // Hacher le mot de passe avec notre service spécialisé
    const hashedPassword = await this.passwordService.hashPassword(
      createUserDto.password,
    );

    try {
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
        token: this.jwtService.sign(payload),
        currentUser: {
          id: newUser._id,
          email: newUser.email,
          username: newUser.username,
          description: newUser.description || null,
          isPremium: newUser.isPremium || false,
          photoUrl: newUser.photoUrl || null,
          birthDate: newUser.birthDate || null,
          gender: newUser.gender || null,
          followers: newUser.followers || [],
          following: newUser.following || [],
        },
      };
    } catch (error) {
      // Gérer les erreurs de duplication de MongoDB
      if (error.code === 11000) {
        const field = Object.keys(error.keyPattern)[0];
        throw new BadRequestException(
          `Ce ${field === 'email' ? 'email' : "nom d'utilisateur"} est déjà utilisé`,
        );
      }
      throw error;
    }
  }

  /**
   * Change le mot de passe d'un utilisateur
   *
   * Vérifie l'ancien mot de passe avant de le remplacer par le nouveau.
   * Applique les règles de sécurité pour le nouveau mot de passe.
   *
   * @param userId - ID de l'utilisateur
   * @param currentPassword - Mot de passe actuel
   * @param newPassword - Nouveau mot de passe
   * @throws {UnauthorizedException} Si l'utilisateur n'existe pas ou mot de passe actuel incorrect
   * @throws {BadRequestException} Si le nouveau mot de passe ne respecte pas les règles de sécurité
   */
  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string,
  ): Promise<void> {
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new UnauthorizedException('Utilisateur non trouvé');
    }

    // Vérifier le mot de passe actuel
    let isPasswordValid = false;
    try {
      isPasswordValid = await this.passwordService.verifyPassword(
        currentPassword,
        user.password,
      );
    } catch (e) {
      throw new UnauthorizedException(
        'Erreur de validation du mot de passe : ' + e.message,
      );
    }
    if (!isPasswordValid) {
      throw new UnauthorizedException('Mot de passe actuel incorrect');
    }

    // Vérifier la sécurité du nouveau mot de passe
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

    // Hacher et enregistrer le nouveau mot de passe
    const hashedPassword = await this.passwordService.hashPassword(newPassword);
    await this.usersService.updateById(userId, { password: hashedPassword });
  }
}
