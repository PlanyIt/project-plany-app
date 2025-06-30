import {
  Controller,
  Get,
  Body,
  Patch,
  Param,
  Delete,
  InternalServerErrorException,
  UseGuards,
  NotFoundException,
  Request,
  UnauthorizedException,
  Post,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { UserService } from './user.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateUserDto } from './dto/create-user.dto';

@ApiTags('Users')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard)
@Controller('api/users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  @ApiOperation({
    summary: 'Get all users',
    description: 'Retrieve all users in the system (admin only)',
  })
  @ApiResponse({
    status: 200,
    description: 'Users retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', example: '507f1f77bcf86cd799439012' },
          username: { type: 'string', example: 'john_doe' },
          email: { type: 'string', example: 'john@example.com' },
          description: { type: 'string', example: 'Hello, I am John!' },
          isPremium: { type: 'boolean', example: false },
          photoUrl: {
            type: 'string',
            example: 'https://example.com/photo.jpg',
          },
          role: { type: 'string', example: 'user' },
          isActive: { type: 'boolean', example: true },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  findAll() {
    return this.userService.findAll();
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get user by ID',
    description: 'Retrieve a specific user by their unique identifier',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'User retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', example: '507f1f77bcf86cd799439012' },
        username: { type: 'string', example: 'john_doe' },
        email: { type: 'string', example: 'john@example.com' },
        description: { type: 'string', example: 'Hello, I am John!' },
        isPremium: { type: 'boolean', example: false },
        photoUrl: { type: 'string', example: 'https://example.com/photo.jpg' },
        birthDate: { type: 'string', example: '1990-01-01T00:00:00.000Z' },
        gender: { type: 'string', example: 'male' },
        role: { type: 'string', example: 'user' },
        isActive: { type: 'boolean', example: true },
        followers: { type: 'array', items: { type: 'string' } },
        following: { type: 'array', items: { type: 'string' } },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'User not found',
  })
  async findOne(@Param('id') id: string) {
    const user = await this.userService.findById(id);
    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }
    return {
      id: (user._id as any).toString(),
      username: user.username,
      email: user.email,
      description: user.description,
      isPremium: user.isPremium,
      photoUrl: user.photoUrl,
      birthDate: user.birthDate,
      gender: user.gender,
      role: user.role,
      isActive: user.isActive,
      followers: user.followers,
      following: user.following,
    };
  }

  @Post()
  @ApiOperation({
    summary: 'Create a new user',
    description: 'Create a new user account (admin only)',
  })
  @ApiBody({
    type: CreateUserDto,
    description: 'User data',
    examples: {
      'Create User': {
        value: {
          username: 'john_doe',
          email: 'john@example.com',
          password: 'StrongPassword123',
          description: 'Hello, I am John!',
          photoUrl: 'https://example.com/photo.jpg',
          birthDate: '1990-01-01',
          gender: 'male',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'User created successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid user data',
  })
  async create(@Body() createUserDto: CreateUserDto) {
    return this.userService.create(createUserDto).catch((error) => {
      console.error("Erreur lors de la création de l'utilisateur :", error);
      throw new InternalServerErrorException();
    });
  }

  @Patch(':id/profile')
  @ApiOperation({
    summary: 'Update user profile',
    description: 'Update the profile of the authenticated user',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiBody({
    type: UpdateUserDto,
    description: 'Updated user data',
    examples: {
      'Update Profile': {
        value: {
          username: 'john_doe_updated',
          description: 'Updated description',
          photoUrl: 'https://example.com/new-photo.jpg',
          birthDate: '1990-01-01',
          gender: 'male',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Profile updated successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', example: '507f1f77bcf86cd799439012' },
        username: { type: 'string', example: 'john_doe_updated' },
        email: { type: 'string', example: 'john@example.com' },
        description: { type: 'string', example: 'Updated description' },
        isPremium: { type: 'boolean', example: false },
        photoUrl: {
          type: 'string',
          example: 'https://example.com/new-photo.jpg',
        },
        followersCount: { type: 'number', example: 5 },
        followingCount: { type: 'number', example: 10 },
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Cannot modify another user profile',
  })
  @ApiResponse({
    status: 404,
    description: 'User not found',
  })
  async updateProfile(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
    @Request() req: any,
  ) {
    // Vérifier que l'utilisateur est authentifié
    if (!req.user) {
      throw new UnauthorizedException('Utilisateur non authentifié');
    }

    // Vérifier que l'utilisateur ne modifie que son propre profil
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException('Vous ne pouvez pas modifier ce profil');
    }

    const updatedUser = await this.userService.updateById(id, updateUserDto);
    if (!updatedUser) {
      throw new NotFoundException('Utilisateur non trouvé');
    }
    return {
      id: (updatedUser._id as any).toString(),
      username: updatedUser.username,
      email: updatedUser.email,
      description: updatedUser.description,
      isPremium: updatedUser.isPremium,
      photoUrl: updatedUser.photoUrl,
      birthDate: updatedUser.birthDate,
      gender: updatedUser.gender,
      role: updatedUser.role,
      isActive: updatedUser.isActive,
      followers: updatedUser.followers,
      following: updatedUser.following,
      followersCount: updatedUser.followers?.length ?? 0,
      followingCount: updatedUser.following?.length ?? 0,
    };
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Delete user account',
    description: 'Delete the user account (only owner can delete)',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user to delete',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'User deleted successfully',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Cannot delete another user account',
  })
  async removeById(@Param('id') id: string, @Request() req: any) {
    // Vérifier que l'utilisateur ne supprime que son propre compte
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException('Vous ne pouvez pas supprimer ce compte');
    }
    return this.userService.removeById(id);
  }

  @Get('username/:username')
  @ApiOperation({
    summary: 'Get user by username',
    description: 'Retrieve a user by their username',
  })
  @ApiParam({
    name: 'username',
    description: 'The username of the user',
    example: 'john_doe',
  })
  @ApiResponse({
    status: 200,
    description: 'User retrieved successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'User not found',
  })
  findOneByUsername(@Param('username') username: string) {
    return this.userService.findByUsername(username);
  }

  @Get('email/:email')
  @ApiOperation({
    summary: 'Get user by email',
    description: 'Retrieve a user by their email address',
  })
  @ApiParam({
    name: 'email',
    description: 'The email address of the user',
    example: 'john@example.com',
  })
  @ApiResponse({
    status: 200,
    description: 'User retrieved successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'User not found',
  })
  findOneByEmail(@Param('email') email: string) {
    return this.userService.findByEmail(email);
  }

  @Patch(':id/email')
  @ApiOperation({
    summary: 'Update user email',
    description: 'Update the email address of the user (only owner can update)',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiBody({
    description: 'New email address',
    schema: {
      type: 'object',
      properties: {
        email: { type: 'string', example: 'newemail@example.com' },
      },
      required: ['email'],
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Email updated successfully',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized or email already exists',
  })
  async updateEmail(
    @Param('id') id: string,
    @Body('email') email: string,
    @Request() req: any,
  ) {
    // Vérifier que l'utilisateur ne modifie que son propre email
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException('Vous ne pouvez pas modifier cet email');
    }

    // Vérifier si l'email est déjà utilisé
    const existingUser = await this.userService.findByEmail(email);
    if (existingUser && (existingUser._id as any).toString() !== id) {
      throw new UnauthorizedException('Cet email est déjà utilisé');
    }

    return this.userService.updateById(id, { email });
  }

  @Patch(':id/photo')
  @ApiOperation({
    summary: 'Update user photo',
    description: 'Update the profile photo of the user (only owner can update)',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiBody({
    description: 'New photo URL',
    schema: {
      type: 'object',
      properties: {
        photoUrl: {
          type: 'string',
          example: 'https://example.com/new-photo.jpg',
        },
      },
      required: ['photoUrl'],
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Photo updated successfully',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized',
  })
  async updateUserPhoto(
    @Param('id') id: string,
    @Body('photoUrl') photoUrl: string,
    @Request() req: any,
  ) {
    // Vérifier que l'utilisateur ne modifie que sa propre photo
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException(
        'Vous ne pouvez pas modifier cette photo',
      );
    }
    return this.userService.updateById(id, { photoUrl });
  }

  @Delete(':id/photo')
  @ApiOperation({
    summary: 'Delete user photo',
    description: 'Remove the profile photo of the user (only owner can delete)',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'Photo deleted successfully',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized',
  })
  async deleteUserPhoto(@Param('id') id: string, @Request() req: any) {
    // Vérifier que l'utilisateur ne supprime que sa propre photo
    if (req.user._id.toString() !== id) {
      throw new UnauthorizedException(
        'Vous ne pouvez pas supprimer cette photo',
      );
    }
    return this.userService.updateById(id, { photoUrl: null });
  }

  @Get(':id/stats')
  @ApiOperation({
    summary: 'Get user statistics',
    description:
      'Retrieve statistics for a specific user (plans count, favorites, etc.)',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'User statistics retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        plansCount: { type: 'number', example: 15 },
        favoritesCount: { type: 'number', example: 8 },
        followersCount: { type: 'number', example: 25 },
        followingCount: { type: 'number', example: 12 },
        commentsCount: { type: 'number', example: 42 },
      },
    },
  })
  async getUserStats(@Param('id') userId: string) {
    try {
      return await this.userService.getUserStats(userId);
    } catch (error) {
      console.error('Erreur dans getUserStats:', error);
      throw error;
    }
  }

  @Get(':id/plans')
  @ApiOperation({
    summary: 'Get user plans',
    description: 'Retrieve all plans created by a specific user',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'User plans retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
          title: { type: 'string', example: 'Trip to Paris' },
          description: { type: 'string', example: 'A wonderful trip to Paris' },
          category: { type: 'string', example: 'Travel' },
          isPublic: { type: 'boolean', example: true },
          steps: { type: 'array', items: { type: 'string' } },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  async getUserPlans(@Param('id') userId: string) {
    try {
      const plans = await this.userService.getUserPlans(userId);
      return plans;
    } catch (error) {
      console.error(`Error getting plans: ${error.message}`);
      throw error;
    }
  }

  @Get(':id/favorites')
  @ApiOperation({
    summary: 'Get user favorite plans',
    description: 'Retrieve all plans marked as favorites by a specific user',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'User favorite plans retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
          title: { type: 'string', example: 'Trip to Paris' },
          description: { type: 'string', example: 'A wonderful trip to Paris' },
          category: { type: 'string', example: 'Travel' },
          userId: { type: 'string', example: '507f1f77bcf86cd799439013' },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  async getUserFavorites(@Param('id') userId: string) {
    try {
      const favorites = await this.userService.getUserFavorites(userId);
      return favorites;
    } catch (error) {
      console.error(`Error getting favorites: ${error.message}`);
      throw error;
    }
  }

  @Patch(':id/premium')
  @ApiOperation({
    summary: 'Update premium status',
    description: 'Update the premium status of a user (admin only or self)',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiBody({
    description: 'Premium status',
    schema: {
      type: 'object',
      properties: {
        isPremium: { type: 'boolean', example: true },
      },
      required: ['isPremium'],
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Premium status updated successfully',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized',
  })
  async updatePremiumStatus(
    @Param('id') id: string,
    @Body('isPremium') isPremium: boolean,
    @Request() req: any,
  ) {
    // Vérifier si l'utilisateur est admin ou modifie son propre statut
    if (req.user._id.toString() !== id && req.user.role !== 'admin') {
      throw new UnauthorizedException('Opération non autorisée');
    }
    return this.userService.updateById(id, { isPremium });
  }

  @Post(':id/follow')
  @ApiOperation({
    summary: 'Follow a user',
    description: 'Follow another user to see their activity',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user to follow',
    example: '507f1f77bcf86cd799439013',
  })
  @ApiResponse({
    status: 200,
    description: 'User followed successfully',
    schema: {
      example: {
        message: 'User followed successfully',
        following: true,
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Cannot follow yourself or already following',
  })
  async followUser(@Param('id') targetUserId: string, @Request() req: any) {
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

  @Delete(':id/follow')
  @ApiOperation({
    summary: 'Unfollow a user',
    description: 'Stop following a user',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user to unfollow',
    example: '507f1f77bcf86cd799439013',
  })
  @ApiResponse({
    status: 200,
    description: 'User unfollowed successfully',
    schema: {
      example: {
        message: 'User unfollowed successfully',
        following: false,
      },
    },
  })
  async unfollowUser(@Param('id') targetUserId: string, @Request() req: any) {
    if (!req.user) {
      throw new UnauthorizedException('Utilisateur non authentifié');
    }

    const followerId = req.user._id;
    return this.userService.unfollowUser(followerId, targetUserId);
  }

  @Get(':id/followers')
  @ApiOperation({
    summary: 'Get user followers',
    description: 'Retrieve all followers of a specific user',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'Followers retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439013' },
          username: { type: 'string', example: 'jane_doe' },
          email: { type: 'string', example: 'jane@example.com' },
          photoUrl: { type: 'string', example: 'https://example.com/jane.jpg' },
        },
      },
    },
  })
  async getUserFollowers(@Param('id') userId: string) {
    return this.userService.getUserFollowers(userId);
  }

  @Get(':id/following')
  @ApiOperation({
    summary: 'Get users followed by user',
    description: 'Retrieve all users that a specific user is following',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'Following list retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439013' },
          username: { type: 'string', example: 'jane_doe' },
          email: { type: 'string', example: 'jane@example.com' },
          photoUrl: { type: 'string', example: 'https://example.com/jane.jpg' },
        },
      },
    },
  })
  async getUserFollowing(@Param('id') userId: string) {
    try {
      return await this.userService.getUserFollowing(userId);
    } catch (error) {
      console.error('Erreur dans getUserFollowing:', error);
      throw error;
    }
  }

  @Get(':id/following/:targetId')
  @ApiOperation({
    summary: 'Check if user is following another user',
    description: 'Check if a user is following another specific user',
  })
  @ApiParam({
    name: 'id',
    description: 'The unique identifier of the follower user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiParam({
    name: 'targetId',
    description: 'The unique identifier of the target user',
    example: '507f1f77bcf86cd799439013',
  })
  @ApiResponse({
    status: 200,
    description: 'Following status retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        isFollowing: { type: 'boolean', example: true },
      },
    },
  })
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
  @ApiOperation({
    summary: 'Follow user (explicit)',
    description:
      'Explicit endpoint to follow a user by providing both user IDs',
  })
  @ApiParam({
    name: 'followerId',
    description: 'The unique identifier of the follower',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiParam({
    name: 'targetId',
    description: 'The unique identifier of the user to follow',
    example: '507f1f77bcf86cd799439013',
  })
  @ApiResponse({
    status: 200,
    description: 'User followed successfully',
  })
  async explicitFollowUser(
    @Param('followerId') followerId: string,
    @Param('targetId') targetId: string,
  ) {
    return this.userService.followUser(followerId, targetId);
  }

  @Delete(':followerId/unfollow/:targetId')
  @ApiOperation({
    summary: 'Unfollow user (explicit)',
    description:
      'Explicit endpoint to unfollow a user by providing both user IDs',
  })
  @ApiParam({
    name: 'followerId',
    description: 'The unique identifier of the follower',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiParam({
    name: 'targetId',
    description: 'The unique identifier of the user to unfollow',
    example: '507f1f77bcf86cd799439013',
  })
  @ApiResponse({
    status: 200,
    description: 'User unfollowed successfully',
  })
  async explicitUnfollowUser(
    @Param('followerId') followerId: string,
    @Param('targetId') targetId: string,
  ) {
    return this.userService.unfollowUser(followerId, targetId);
  }
}
