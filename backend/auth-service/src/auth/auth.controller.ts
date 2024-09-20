import { Controller, Get, Req, Res, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('login')
  @UseGuards(AuthGuard('auth0'))
  login() {
    // Redirige vers Auth0 pour l'authentification
  }

  @Get('callback')
  @UseGuards(AuthGuard('auth0'))
  async callback(@Req() req, @Res() res) {
    // Gère le callback après Auth0
    const token = await this.authService.generateJwt(req.user);
    return res.json(token);
  }

  @Get('protected')
  @UseGuards(AuthGuard('jwt'))
  protectedRoute(@Req() req) {
    // Exemple de route protégée
    return `Hello ${req.user.email}, this is a protected route`;
  }
}
