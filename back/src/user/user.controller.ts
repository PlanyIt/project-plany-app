import {
  Controller,
  Get,
  Post,
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
} from '@nestjs/common';
import { UserService as UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { PlanService } from 'src/plan/plan.service';
import { isValidObjectId } from 'mongoose';

@Controller('api/users')
export class UserController {
  userModel: any;
  constructor(
    private readonly userService: UserService,
    @Inject(forwardRef(() => PlanService))
    private readonly planService: PlanService,
  ) {}

  @Get()
  findAll() {
    return this.userService.findAll();
  }

  @Get(':firebaseUid')
  findOneByFirebaseUid(@Param('firebaseUid') firebaseUid: string) {
    return this.userService.findOneByFirebaseUid(firebaseUid);
  }

  @Post()
  async create(@Body() createUserDto: CreateUserDto) {
    return this.userService.create(createUserDto).catch((error) => {
      console.error("Erreur lors de la création de l'utilisateur :", error);
      throw new InternalServerErrorException();
    });
  }

  @Patch(':firebaseUid/profile')
  updateByFirebaseUid(
    @Param('firebaseUid') firebaseUid: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.userService.updateByFirebaseUid(firebaseUid, updateUserDto);
  }

  @Delete(':firebaseUid')
  removeByFirebaseUid(@Param('firebaseUid') firebaseUid: string) {
    return this.userService.removeByFirebaseUid(firebaseUid);
  }

  @Get('username/:username')
  findOneByUsername(@Param('username') username: string) {
    return this.userService.findOneByUsername(username);
  }

  @Get('email/:email')
  findOneByEmail(@Param('email') email: string) {
    return this.userService.findOneByEmail(email);
  }

  @UseGuards(FirebaseAuthGuard)
  @Patch(':firebaseUid/photo')
  updateUserPhoto(
    @Param('firebaseUid') firebaseUid: string,
    @Body('photoUrl') photoUrl: string,
  ) {
    return this.userService.updateByFirebaseUid(firebaseUid, { photoUrl });
  }

  @Get(':firebaseUid/stats')
  async getUserStats(@Param('firebaseUid') userId: string) {
    try {
      return await this.userService.getUserStats(userId);
    } catch (error) {
      console.error('Erreur dans getUserStats:', error);
      throw error;
    }
  }

  @Get(':firebaseUid/plans')
  async getUserPlans(@Param('firebaseUid') firebaseUid: string) {
    try {
      const plans = await this.planService.findAllByUserId(firebaseUid);
      return plans;
    } catch (error) {
      console.error(`Error getting plans: ${error.message}`);
      throw error;
    }
  }

  @Get(':firebaseUid/favorites')
  async getUserFavorites(@Param('firebaseUid') firebaseUid: string) {
    try {
      const favorites =
        await this.planService.findFavoritesByUserId(firebaseUid);
      return favorites;
    } catch (error) {
      console.error(`Error getting favorites: ${error.message}`);
      throw error;
    }
  }

  @UseGuards(FirebaseAuthGuard)
  @Patch(':firebaseUid/premium')
  async updatePremiumStatus(
    @Param('firebaseUid') firebaseUid: string,
    @Body('isPremium') isPremium: boolean,
  ) {
    return this.userService.updateByFirebaseUid(firebaseUid, { isPremium });
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    let user;

    if (isValidObjectId(id)) {
      user = await this.userService.findById(id);
    }

    if (!user) {
      user = await this.userService.findOneByFirebaseUid(id);
    }

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return user;
  }

  // Suivre un utilisateur
  @UseGuards(FirebaseAuthGuard)
  @Post(':id/follow')
  async followUser(@Param('id') targetUserId: string, @Request() req) {
    if (!req.user) {
      throw new UnauthorizedException('Utilisateur non authentifié');
    }

    const followerId = req.user.uid || req.user.id;

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
  @UseGuards(FirebaseAuthGuard)
  @Delete(':id/follow')
  async unfollowUser(@Param('id') targetUserId: string, @Request() req) {
    if (!req.user) {
      throw new UnauthorizedException('Utilisateur non authentifié');
    }

    const followerId = req.user.uid;
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
