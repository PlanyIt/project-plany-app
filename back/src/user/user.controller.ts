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

@Controller('api/users')
export class UserController {
  constructor(
    private readonly userService: UserService,
    @Inject(forwardRef(() => PlanService))
    private readonly planService: PlanService,
  ) {}

  @Get()
  findAll() {
    return this.userService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const user = await this.userService.findById(id);
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
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

  @UseGuards(JwtAuthGuard)
  @Patch(':id/profile')
  updateProfile(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
    @Request() req,
  ) {
    // Vérifier que l'utilisateur ne modifie que son propre profil
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException('Vous ne pouvez pas modifier ce profil');
    }
    return this.userService.updateById(id, updateUserDto);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  removeById(@Param('id') id: string, @Request() req) {
    // Vérifier que l'utilisateur ne supprime que son propre compte
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException('Vous ne pouvez pas supprimer ce compte');
    }
    return this.userService.removeById(id);
  }

  @Get('username/:username')
  findOneByUsername(@Param('username') username: string) {
    return this.userService.findOneByUsername(username);
  }

  @Get('email/:email')
  findOneByEmail(@Param('email') email: string) {
    return this.userService.findOneByEmail(email);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id/email')
  async updateEmail(
    @Param('id') id: string,
    @Body('email') email: string,
    @Request() req,
  ) {
    // Vérifier que l'utilisateur ne modifie que son propre email
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException('Vous ne pouvez pas modifier cet email');
    }

    // Vérifier si l'email est déjà utilisé
    const existingUser = await this.userService.findOneByEmail(email);
    if (existingUser && existingUser._id.toString() !== id) {
      throw new UnauthorizedException('Cet email est déjà utilisé');
    }

    return this.userService.updateById(id, { email });
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id/photo')
  updateUserPhoto(
    @Param('id') id: string,
    @Body('photoUrl') photoUrl: string,
    @Request() req,
  ) {
    // Vérifier que l'utilisateur ne modifie que sa propre photo
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException(
        'Vous ne pouvez pas modifier cette photo',
      );
    }
    return this.userService.updateById(id, { photoUrl });
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id/photo')
  deleteUserPhoto(@Param('id') id: string, @Request() req) {
    // Vérifier que l'utilisateur ne supprime que sa propre photo
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException(
        'Vous ne pouvez pas supprimer cette photo',
      );
    }
    return this.userService.updateById(id, { photoUrl: null });
  }

  @Get(':id/stats')
  async getUserStats(@Param('id') userId: string) {
    try {
      return await this.userService.getUserStats(userId);
    } catch (error) {
      console.error('Erreur dans getUserStats:', error);
      throw error;
    }
  }

  @Get(':id/plans')
  async getUserPlans(@Param('id') userId: string) {
    try {
      const plans = await this.planService.findAllByUserId(userId);
      return plans;
    } catch (error) {
      console.error(`Error getting plans: ${error.message}`);
      throw error;
    }
  }

  @Get(':id/favorites')
  async getUserFavorites(@Param('id') userId: string) {
    try {
      const favorites = await this.planService.findFavoritesByUserId(userId);
      return favorites;
    } catch (error) {
      console.error(`Error getting favorites: ${error.message}`);
      throw error;
    }
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id/premium')
  async updatePremiumStatus(
    @Param('id') id: string,
    @Body('isPremium') isPremium: boolean,
    @Request() req,
  ) {
    // Vérifier si l'utilisateur est admin ou modifie son propre statut
    if (req.user._id.toString() !== id && req.user.role !== 'admin') {
      throw new UnauthorizedException('Opération non autorisée');
    }
    return this.userService.updateById(id, { isPremium });
  }

  // Suivre un utilisateur
  @UseGuards(JwtAuthGuard)
  @Post(':id/follow')
  async followUser(@Param('id') targetUserId: string, @Request() req) {
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
  @UseGuards(JwtAuthGuard)
  @Delete(':id/follow')
  async unfollowUser(@Param('id') targetUserId: string, @Request() req) {
    if (!req.user) {
      throw new UnauthorizedException('Utilisateur non authentifié');
    }

    const followerId = req.user._id;
    return this.userService.unfollowUser(followerId, targetUserId);
  }

  // Récupérer les abonnés d'un utilisateur
  @Get(':id/followers')
  async getUserFollowers(@Param('id') userId: string) {
    return this.userService.getUserFollowers(userId);
  }

  // Récupérer les abonnements d'un utilisateur
  @Get(':id/following')
  async getUserFollowing(@Param('id') userId: string) {
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
    @Param('id') followerId: string,
    @Param('targetId') targetId: string,
  ) {
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
  ) {
    return this.userService.followUser(followerId, targetId);
  }

  @Delete(':followerId/unfollow/:targetId')
  async explicitUnfollowUser(
    @Param('followerId') followerId: string,
    @Param('targetId') targetId: string,
  ) {
    return this.userService.unfollowUser(followerId, targetId);
  }
}
