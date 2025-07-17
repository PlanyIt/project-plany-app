import {
  Body,
  Controller,
  Post,
  BadRequestException,
  HttpException,
  HttpStatus,
  Logger,
  UseGuards,
  Request,
  HttpCode,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { ChangePasswordDto } from './dto/change-password.dto';
import { RefreshDto } from './dto/refresh.dto';

/**
 * Routes d'authentification :
 *   • POST /api/auth/login            → access + refresh tokens
 *   • POST /api/auth/refresh          → rotation de refresh token
 *   • POST /api/auth/logout           → révocation du refresh token courant
 *   • POST /api/auth/register         → création de compte + tokens
 *   • POST /api/auth/change-password  → maj mot de passe + révocation globale
 */
@Controller('api/auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);
  constructor(private readonly auth: AuthService) {}

  /* ------------------------------------------------------------------ */
  /* ---------------------------- LOGIN ------------------------------- */
  /* ------------------------------------------------------------------ */
  @Post('login')
  async login(@Body() dto: LoginDto) {
    try {
      this.logger.log(`Login attempt «${dto.email}»`);
      const res = await this.auth.login(dto);
      this.logger.log(`Login success «${dto.email}»`);
      return res;
    } catch (err) {
      this.logger.error(`Login failed «${dto.email}»`, err.stack);
      if (err instanceof BadRequestException || err instanceof HttpException)
        throw err;
      throw new HttpException(
        'Erreur lors de la connexion',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  /* ------------------------------------------------------------------ */
  /* --------------------------- REGISTER ----------------------------- */
  /* ------------------------------------------------------------------ */
  @Post('register')
  @HttpCode(201)
  async register(@Body() dto: RegisterDto) {
    try {
      this.logger.log(`Register attempt «${dto.email}»`);
      const res = await this.auth.register(dto);
      this.logger.log(`Register success «${dto.email}»`);
      return res;
    } catch (err) {
      this.logger.error(`Register failed «${dto.email}»`, err.stack);
      if (err instanceof BadRequestException) throw err;
      throw new BadRequestException('Erreur lors de la création du compte');
    }
  }

  /* ------------------------------------------------------------------ */
  /* ---------------------------- REFRESH ----------------------------- */
  /* ------------------------------------------------------------------ */
  @Post('refresh')
  async refresh(@Body() dto: RefreshDto) {
    if (!dto.refreshToken)
      throw new BadRequestException('Refresh token manquant');
    return this.auth.refresh(dto.refreshToken);
  }

  /* ------------------------------------------------------------------ */
  /* ----------------------------- LOGOUT ----------------------------- */
  /* ------------------------------------------------------------------ */
  @Post('logout')
  @HttpCode(204)
  async logout(@Body('refreshToken') rt: string) {
    if (!rt) throw new BadRequestException('Refresh token manquant');
    await this.auth.logout(rt);
  }

  /* ------------------------------------------------------------------ */
  /* ------------------------ CHANGE PASSWORD ------------------------ */
  /* ------------------------------------------------------------------ */
  @UseGuards(JwtAuthGuard)
  @Post('change-password')
  async changePwd(@Body() dto: ChangePasswordDto, @Request() req) {
    const userId = req.user?.sub ?? req.user?._id;
    if (!userId)
      throw new HttpException(
        'Utilisateur non authentifié',
        HttpStatus.UNAUTHORIZED,
      );

    await this.auth.changePassword(
      userId,
      dto.currentPassword,
      dto.newPassword,
    );
    return { message: 'Mot de passe modifié avec succès' };
  }
}
