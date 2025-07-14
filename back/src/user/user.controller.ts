import {
  Controller,
  Get,
  Body,
  Patch,
  Param,
  Delete,
  InternalServerErrorException,
  UseGuards,
  Inject,
  forwardRef,
  NotFoundException,
  Request,
  UnauthorizedException,
  Post,
  BadRequestException,
} from '@nestjs/common';
import { UserService } from './user.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PlanService } from 'src/plan/plan.service';
import { CreateUserDto } from './dto/create-user.dto';
import { AuthService } from '../auth/auth.service';
@UseGuards(JwtAuthGuard)
@Controller('api/users')
export class UserController {
  constructor(
    private readonly userService: UserService,
    @Inject(forwardRef(() => PlanService))
    private readonly planService: PlanService,
    private readonly authService: AuthService,
  ) {}

  @Get()
  findAll() {
    return this.userService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string, @Request() req) {
    const userId = id === 'me' ? req.user._id : id;
    const user = await this.userService.findById(userId);
    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }
    return user;
  }

  @Post()
  async create(@Body() createUserDto: CreateUserDto) {
    try {
      return await this.userService.create(createUserDto);
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw error;
      }
      console.error("Erreur lors de la création de l'utilisateur :", error);
      throw new InternalServerErrorException();
    }
  }

  @Patch(':id/profile')
  updateProfile(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
    @Request() req,
  ) {
    const userId = id === 'me' ? req.user._id : id;
    if (req.user._id.toString() !== userId.toString()) {
      throw new UnauthorizedException('Vous ne pouvez pas modifier ce profil');
    }
    return this.userService.updateById(userId, updateUserDto);
  }

  @Delete(':id')
  removeById(@Param('id') id: string, @Request() req) {
    const userId = id === 'me' ? req.user._id : id;
    if (req.user._id.toString() !== userId.toString()) {
      throw new UnauthorizedException('Vous ne pouvez pas supprimer ce compte');
    }
    return this.userService.removeById(userId);
  }

  @Get('username/:username')
  findOneByUsername(@Param('username') username: string) {
    return this.userService.findOneByUsername(username);
  }

  @Get('email/:email')
  findOneByEmail(@Param('email') email: string) {
    return this.userService.findOneByEmail(email);
  }

  @Patch(':id/email')
  async updateEmail(
    @Param('id') id: string,
    @Body('email') email: string,
    @Body('password') password: string,
    @Request() req,
  ) {
    const userId = id === 'me' ? req.user._id : id;
    if (req.user._id.toString() !== userId.toString()) {
      throw new UnauthorizedException('Vous ne pouvez pas modifier cet email');
    }
    const existingUser = await this.userService.findOneByEmail(email);
    if (existingUser && existingUser._id.toString() !== userId.toString()) {
      throw new UnauthorizedException('Cet email est déjà utilisé');
    }
    const user = await this.authService.validateUser(req.user.email, password);
    if (!user) {
      throw new UnauthorizedException('Mot de passe incorrect');
    }
    return this.userService.updateById(userId, { email });
  }

  @Patch(':id/photo')
  updateUserPhoto(
    @Param('id') id: string,
    @Body('photoUrl') photoUrl: string,
    @Request() req,
  ) {
    const userId = id === 'me' ? req.user._id : id;
    if (req.user._id.toString() !== userId.toString()) {
      throw new UnauthorizedException(
        'Vous ne pouvez pas modifier cette photo',
      );
    }
    return this.userService.updateById(userId, { photoUrl });
  }

  @Delete(':id/photo')
  deleteUserPhoto(@Param('id') id: string, @Request() req) {
    const userId = id === 'me' ? req.user._id : id;
    if (req.user._id.toString() !== userId.toString()) {
      throw new UnauthorizedException(
        'Vous ne pouvez pas supprimer cette photo',
      );
    }
    return this.userService.updateById(userId, { photoUrl: null });
  }

  @Get(':id/stats')
  async getUserStats(@Param('id') id: string, @Request() req) {
    const userId = id === 'me' ? req.user._id : id;
    try {
      return await this.userService.getUserStats(userId);
    } catch (error) {
      console.error('Erreur dans getUserStats:', error);
      throw error;
    }
  }

  @Get(':id/plans')
  async getUserPlans(@Param('id') id: string, @Request() req) {
    const userId = id === 'me' ? req.user._id : id;
    try {
      const plans = await this.planService.findAllByUserId(userId);
      return plans;
    } catch (error) {
      console.error(`Error getting plans: ${error.message}`);
      throw error;
    }
  }

  @Get(':id/favorites')
  async getUserFavorites(@Param('id') id: string, @Request() req) {
    const userId = id === 'me' ? req.user._id : id;
    try {
      const favorites = await this.planService.findFavoritesByUserId(userId);
      return favorites;
    } catch (error) {
      console.error(`Error getting favorites: ${error.message}`);
      throw error;
    }
  }

  @Patch(':id/premium')
  async updatePremiumStatus(
    @Param('id') id: string,
    @Body('isPremium') isPremium: boolean,
    @Request() req,
  ) {
    const userId = id === 'me' ? req.user._id : id;
    if (
      req.user._id.toString() !== userId.toString() &&
      req.user.role !== 'admin'
    ) {
      throw new UnauthorizedException('Opération non autorisée');
    }
    return this.userService.updateById(userId, { isPremium });
  }

  // Suivre un utilisateur
  @Post(':id/follow')
  async followUser(@Param('id') id: string, @Request() req) {
    const targetUserId = id === 'me' ? req.user._id : id;
    if (!req.user) {
      throw new UnauthorizedException('Utilisateur non authentifié');
    }
    const followerId = req.user._id;
    if (!followerId) {
      throw new UnauthorizedException('ID utilisateur manquant');
    }
    try {
      return await this.userService.followUser(followerId, targetUserId);
    } catch (error) {
      console.error('Erreur dans followUser:', error);
      throw error;
    }
  }

  // Ne plus suivre un utilisateur
  @Delete(':id/follow')
  async unfollowUser(@Param('id') id: string, @Request() req) {
    const targetUserId = id === 'me' ? req.user._id : id;
    if (!req.user) {
      throw new UnauthorizedException('Utilisateur non authentifié');
    }
    const followerId = req.user._id;
    return this.userService.unfollowUser(followerId, targetUserId);
  }

  // Récupérer les abonnés d'un utilisateur
  @Get(':id/followers')
  async getUserFollowers(@Param('id') id: string, @Request() req) {
    const userId = id === 'me' ? req.user._id : id;
    return this.userService.getUserFollowers(userId);
  }

  // Récupérer les abonnements d'un utilisateur
  @Get(':id/following')
  async getUserFollowing(@Param('id') id: string, @Request() req) {
    const userId = id === 'me' ? req.user._id : id;
    try {
      return await this.userService.getUserFollowing(userId);
    } catch (error) {
      console.error('Erreur dans getUserFollowing:', error);
      throw error;
    }
  }

  // Vérifier si un utilisateur suit un autre utilisateur
  @Get(':id/following/:targetId')
  async checkFollowing(
    @Param('id') id: string,
    @Param('targetId') targetId: string,
    @Request() req,
  ) {
    const followerId = id === 'me' ? req.user._id : id;
    const isFollowing = await this.userService.isFollowing(
      followerId,
      targetId,
    );
    return { isFollowing };
  }

  @Post(':followerId/follow/:targetId')
  async explicitFollowUser(
    @Param('followerId') followerId: string,
    @Param('targetId') targetId: string,
    @Request() req,
  ) {
    const resolvedFollowerId = followerId === 'me' ? req.user._id : followerId;
    return this.userService.followUser(resolvedFollowerId, targetId);
  }

  @Delete(':followerId/unfollow/:targetId')
  async explicitUnfollowUser(
    @Param('followerId') followerId: string,
    @Param('targetId') targetId: string,
    @Request() req,
  ) {
    const resolvedFollowerId = followerId === 'me' ? req.user._id : followerId;
    return this.userService.unfollowUser(resolvedFollowerId, targetId);
  }
}
