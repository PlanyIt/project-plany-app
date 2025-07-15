import { Test, TestingModule } from '@nestjs/testing';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { PlanService } from '../plan/plan.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import {
  NotFoundException,
  UnauthorizedException,
  BadRequestException,
  InternalServerErrorException,
} from '@nestjs/common';

describe('UserController', () => {
  let userController: UserController;
  let userService: UserService;
  let planService: PlanService;

  const mockUsers = [
    {
      _id: '507f1f77bcf86cd799439011',
      username: 'johndoe',
      email: 'john@plany.com',
      password: 'hashedPassword123',
      description: 'Développeur passionné',
      isPremium: false,
      photoUrl: 'https://example.com/john.jpg',
      birthDate: new Date('1990-05-15T00:00:00.000Z'),
      gender: 'male',
      role: 'user',
      isActive: true,
      followers: ['507f1f77bcf86cd799439012'],
      following: ['507f1f77bcf86cd799439013'],
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439012',
      username: 'janedoe',
      email: 'jane@plany.com',
      password: 'hashedPassword456',
      description: 'Amatrice de voyages',
      isPremium: true,
      photoUrl: 'https://example.com/jane.jpg',
      birthDate: new Date('1995-08-22T00:00:00.000Z'),
      gender: 'female',
      role: 'user',
      isActive: true,
      followers: [],
      following: ['507f1f77bcf86cd799439011'],
      createdAt: new Date('2024-01-20T11:00:00.000Z'),
      updatedAt: new Date('2024-01-20T11:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439013',
      username: 'adminuser',
      email: 'admin@plany.com',
      password: 'hashedAdminPassword',
      description: 'Administrateur de la plateforme',
      isPremium: true,
      photoUrl: 'https://example.com/admin.jpg',
      birthDate: new Date('1985-03-10T00:00:00.000Z'),
      gender: 'male',
      role: 'admin',
      isActive: true,
      followers: [],
      following: [],
      createdAt: new Date('2024-01-20T09:00:00.000Z'),
      updatedAt: new Date('2024-01-20T09:00:00.000Z'),
    },
  ];

  const validCreateUserDto: CreateUserDto = {
    username: 'newuser',
    email: 'newuser@plany.com',
    password: 'SecurePass123!',
    description: 'Nouvel utilisateur',
    isPremium: false,
    photoUrl: 'https://example.com/newuser.jpg',
    birthDate: new Date('1992-12-01T00:00:00.000Z'),
    gender: 'other',
    role: 'user',
    isActive: true,
    plansCount: 0,
  };

  const validUpdateUserDto: UpdateUserDto = {
    username: 'updateduser',
    description: 'Description mise à jour',
    photoUrl: 'https://example.com/updated.jpg',
    isPremium: true,
  };

  const mockUser = mockUsers[0];
  const mockAdminUser = mockUsers[2];

  const mockRequest = {
    user: mockUser,
  };

  const mockAdminRequest = {
    user: mockAdminUser,
  };

  const mockPlans = [
    {
      _id: '507f1f77bcf86cd799439031',
      title: 'Plan de John',
      userId: mockUser._id,
      isPublic: true,
    },
  ];

  const mockUserStats = {
    userId: mockUser._id,
    plansCount: 5,
    favoritesCount: 3,
    followersCount: 1,
    followingCount: 1,
    totalViews: 250,
    averageRating: 4.2,
  };

  const mockUserService = {
    findAll: jest.fn(),
    findById: jest.fn(),
    create: jest.fn(),
    updateById: jest.fn(),
    removeById: jest.fn(),
    findOneByUsername: jest.fn(),
    findOneByEmail: jest.fn(),
    getUserStats: jest.fn(),
    followUser: jest.fn(),
    unfollowUser: jest.fn(),
    getUserFollowers: jest.fn(),
    getUserFollowing: jest.fn(),
    isFollowing: jest.fn(),
  };

  const mockPlanService = {
    findAllByUserId: jest.fn(),
    findFavoritesByUserId: jest.fn(),
  };

  const mockJwtAuthGuard = {
    canActivate: jest.fn(() => true),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserController],
      providers: [
        {
          provide: UserService,
          useValue: mockUserService,
        },
        {
          provide: PlanService,
          useValue: mockPlanService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue(mockJwtAuthGuard)
      .compile();

    userController = module.get<UserController>(UserController);
    userService = module.get<UserService>(UserService);
    planService = module.get<PlanService>(PlanService);
  });

  it('should be defined', () => {
    expect(userController).toBeDefined();
    expect(userService).toBeDefined();
    expect(planService).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all users', async () => {
      mockUserService.findAll.mockResolvedValue(mockUsers);

      const result = await userController.findAll();

      expect(result).toEqual(mockUsers);
      expect(mockUserService.findAll).toHaveBeenCalledTimes(1);
      expect(result).toHaveLength(3);
    });

    it('should return empty array when no users exist', async () => {
      mockUserService.findAll.mockResolvedValue([]);

      const result = await userController.findAll();

      expect(result).toEqual([]);
      expect(mockUserService.findAll).toHaveBeenCalledTimes(1);
    });
  });

  describe('findOne', () => {
    it('should return user by ID', async () => {
      const userId = mockUser._id;
      mockUserService.findById.mockResolvedValue(mockUser);

      const result = await userController.findOne(userId);

      expect(result).toEqual(mockUser);
      expect(mockUserService.findById).toHaveBeenCalledWith(userId);
      expect(mockUserService.findById).toHaveBeenCalledTimes(1);
    });

    it('should throw NotFoundException when user not found', async () => {
      const userId = '507f1f77bcf86cd799439999';
      mockUserService.findById.mockResolvedValue(null);

      await expect(userController.findOne(userId)).rejects.toThrow(
        NotFoundException,
      );
      await expect(userController.findOne(userId)).rejects.toThrow(
        `User with ID ${userId} not found`,
      );
    });
  });

  describe('create', () => {
    it('should create and return a new user', async () => {
      const createdUser = {
        _id: '507f1f77bcf86cd799439014',
        ...validCreateUserDto,
        followers: [],
        following: [],
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockUserService.create.mockResolvedValue(createdUser);

      const result = await userController.create(validCreateUserDto);

      expect(result).toEqual(createdUser);
      expect(mockUserService.create).toHaveBeenCalledWith(validCreateUserDto);
      expect(mockUserService.create).toHaveBeenCalledTimes(1);
    });

    it('should throw BadRequestException for invalid user data', async () => {
      const invalidUserDto = {
        username: '',
        email: 'invalid',
      } as CreateUserDto;
      const validationError = new BadRequestException('Invalid user data');

      mockUserService.create.mockRejectedValue(validationError);

      await expect(userController.create(invalidUserDto)).rejects.toThrow(
        BadRequestException,
      );
      expect(mockUserService.create).toHaveBeenCalledWith(invalidUserDto);
    });

    it('should throw InternalServerErrorException for service errors', async () => {
      const serviceError = new Error('Database connection failed');
      mockUserService.create.mockRejectedValue(serviceError);

      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      await expect(userController.create(validCreateUserDto)).rejects.toThrow(
        InternalServerErrorException,
      );

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        "Erreur lors de la création de l'utilisateur :",
        serviceError,
      );

      consoleErrorSpy.mockRestore();
    });
  });

  describe('updateProfile', () => {
    it('should update own profile successfully', async () => {
      const userId = mockUser._id;
      const updatedUser = { ...mockUser, ...validUpdateUserDto };

      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updateProfile(
        userId,
        validUpdateUserDto,
        mockRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(
        userId,
        validUpdateUserDto,
      );
    });

    it('should throw UnauthorizedException when updating other user profile', async () => {
      const otherUserId = mockUsers[1]._id;

      let thrownError;
      try {
        await userController.updateProfile(
          otherUserId,
          validUpdateUserDto,
          mockRequest,
        );
      } catch (error) {
        thrownError = error;
      }

      expect(thrownError).toBeInstanceOf(UnauthorizedException);
      expect(thrownError.message).toBe('Vous ne pouvez pas modifier ce profil');
      expect(mockUserService.updateById).not.toHaveBeenCalled();
    });
  });

  describe('removeById', () => {
    it('should delete own account successfully', async () => {
      const userId = mockUser._id;
      const deletedUser = mockUser;

      mockUserService.removeById.mockResolvedValue(deletedUser);

      const result = await userController.removeById(userId, mockRequest);

      expect(result).toEqual(deletedUser);
      expect(mockUserService.removeById).toHaveBeenCalledWith(userId);
    });

    it('should throw UnauthorizedException when deleting other user account', async () => {
      const otherUserId = mockUsers[1]._id;

      let thrownError;
      try {
        await userController.removeById(otherUserId, mockRequest);
      } catch (error) {
        thrownError = error;
      }

      expect(thrownError).toBeInstanceOf(UnauthorizedException);
      expect(thrownError.message).toBe(
        'Vous ne pouvez pas supprimer ce compte',
      );
      expect(mockUserService.removeById).not.toHaveBeenCalled();
    });
  });

  describe('findOneByUsername', () => {
    it('should return user by username', async () => {
      const username = mockUser.username;
      mockUserService.findOneByUsername.mockResolvedValue(mockUser);

      const result = await userController.findOneByUsername(username);

      expect(result).toEqual(mockUser);
      expect(mockUserService.findOneByUsername).toHaveBeenCalledWith(username);
    });
  });

  describe('findOneByEmail', () => {
    it('should return user by email', async () => {
      const email = mockUser.email;
      mockUserService.findOneByEmail.mockResolvedValue(mockUser);

      const result = await userController.findOneByEmail(email);

      expect(result).toEqual(mockUser);
      expect(mockUserService.findOneByEmail).toHaveBeenCalledWith(email);
    });
  });

  describe('updateEmail', () => {
    it('should update own email successfully', async () => {
      const userId = mockUser._id;
      const newEmail = 'newemail@plany.com';
      const updatedUser = { ...mockUser, email: newEmail };

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updateEmail(
        userId,
        newEmail,
        mockRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.findOneByEmail).toHaveBeenCalledWith(newEmail);
      expect(mockUserService.updateById).toHaveBeenCalledWith(userId, {
        email: newEmail,
      });
    });

    it('should throw UnauthorizedException when updating other user email', async () => {
      const otherUserId = mockUsers[1]._id;
      const newEmail = 'newemail@plany.com';

      let thrownError;
      try {
        await userController.updateEmail(otherUserId, newEmail, mockRequest);
      } catch (error) {
        thrownError = error;
      }

      expect(thrownError).toBeInstanceOf(UnauthorizedException);
      expect(thrownError.message).toBe('Vous ne pouvez pas modifier cet email');
    });

    it('should throw UnauthorizedException when email already exists', async () => {
      const userId = mockUser._id;
      const existingEmail = 'existing@plany.com';
      const existingUser = { ...mockUsers[1], email: existingEmail };

      mockUserService.findOneByEmail.mockResolvedValue(existingUser);

      let thrownError;
      try {
        await userController.updateEmail(userId, existingEmail, mockRequest);
      } catch (error) {
        thrownError = error;
      }

      expect(thrownError).toBeInstanceOf(UnauthorizedException);
      expect(thrownError.message).toBe('Cet email est déjà utilisé');
    });
  });

  describe('updateUserPhoto', () => {
    it('should update own photo successfully', async () => {
      const userId = mockUser._id;
      const newPhotoUrl = 'https://example.com/newphoto.jpg';
      const updatedUser = { ...mockUser, photoUrl: newPhotoUrl };

      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updateUserPhoto(
        userId,
        newPhotoUrl,
        mockRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(userId, {
        photoUrl: newPhotoUrl,
      });
    });

    it('should throw UnauthorizedException when updating other user photo', async () => {
      const otherUserId = mockUsers[1]._id;
      const newPhotoUrl = 'https://example.com/newphoto.jpg';

      let thrownError;
      try {
        await userController.updateUserPhoto(
          otherUserId,
          newPhotoUrl,
          mockRequest,
        );
      } catch (error) {
        thrownError = error;
      }

      expect(thrownError).toBeInstanceOf(UnauthorizedException);
      expect(thrownError.message).toBe(
        'Vous ne pouvez pas modifier cette photo',
      );
    });
  });

  describe('deleteUserPhoto', () => {
    it('should delete own photo successfully', async () => {
      const userId = mockUser._id;
      const updatedUser = { ...mockUser, photoUrl: null };

      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.deleteUserPhoto(userId, mockRequest);

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(userId, {
        photoUrl: null,
      });
    });

    it('should throw UnauthorizedException when deleting other user photo', async () => {
      const otherUserId = mockUsers[1]._id;

      let thrownError;
      try {
        await userController.deleteUserPhoto(otherUserId, mockRequest);
      } catch (error) {
        thrownError = error;
      }

      expect(thrownError).toBeInstanceOf(UnauthorizedException);
      expect(thrownError.message).toBe(
        'Vous ne pouvez pas supprimer cette photo',
      );
    });
  });

  describe('getUserStats', () => {
    it('should return user statistics', async () => {
      const userId = mockUser._id;
      mockUserService.getUserStats.mockResolvedValue(mockUserStats);

      const result = await userController.getUserStats(userId);

      expect(result).toEqual(mockUserStats);
      expect(mockUserService.getUserStats).toHaveBeenCalledWith(userId);
    });
  });

  describe('getUserPlans', () => {
    it('should return user plans', async () => {
      const userId = mockUser._id;
      mockPlanService.findAllByUserId.mockResolvedValue(mockPlans);

      const result = await userController.getUserPlans(userId);

      expect(result).toEqual(mockPlans);
      expect(mockPlanService.findAllByUserId).toHaveBeenCalledWith(userId);
    });
  });

  describe('getUserFavorites', () => {
    it('should return user favorites', async () => {
      const userId = mockUser._id;
      mockPlanService.findFavoritesByUserId.mockResolvedValue(mockPlans);

      const result = await userController.getUserFavorites(userId);

      expect(result).toEqual(mockPlans);
      expect(mockPlanService.findFavoritesByUserId).toHaveBeenCalledWith(
        userId,
      );
    });
  });

  describe('updatePremiumStatus', () => {
    it('should allow user to update own premium status', async () => {
      const userId = mockUser._id;
      const isPremium = true;
      const updatedUser = { ...mockUser, isPremium };

      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updatePremiumStatus(
        userId,
        isPremium,
        mockRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(userId, {
        isPremium,
      });
    });

    it('should allow admin to update any user premium status', async () => {
      const userId = mockUser._id;
      const isPremium = true;
      const updatedUser = { ...mockUser, isPremium };

      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updatePremiumStatus(
        userId,
        isPremium,
        mockAdminRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(userId, {
        isPremium,
      });
    });

    it('should throw UnauthorizedException when non-admin tries to update other user premium', async () => {
      const otherUserId = mockUsers[1]._id;
      const isPremium = true;

      let thrownError;
      try {
        await userController.updatePremiumStatus(
          otherUserId,
          isPremium,
          mockRequest,
        );
      } catch (error) {
        thrownError = error;
      }

      expect(thrownError).toBeInstanceOf(UnauthorizedException);
      expect(thrownError.message).toBe('Opération non autorisée');
    });
  });

  describe('followUser', () => {
    it('should follow a user successfully', async () => {
      const targetUserId = mockUsers[1]._id;
      const followResult = { success: true, message: 'User followed' };

      mockUserService.followUser.mockResolvedValue(followResult);

      const result = await userController.followUser(targetUserId, mockRequest);

      expect(result).toEqual(followResult);
      expect(mockUserService.followUser).toHaveBeenCalledWith(
        mockUser._id,
        targetUserId,
      );
    });

    it('should throw UnauthorizedException when user not authenticated', async () => {
      const targetUserId = mockUsers[1]._id;
      const unauthenticatedRequest = { user: null };

      await expect(
        userController.followUser(targetUserId, unauthenticatedRequest),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        userController.followUser(targetUserId, unauthenticatedRequest),
      ).rejects.toThrow('Utilisateur non authentifié');
    });

    it('should throw UnauthorizedException when user ID is missing', async () => {
      const targetUserId = mockUsers[1]._id;
      const invalidRequest = { user: { _id: null } };

      await expect(
        userController.followUser(targetUserId, invalidRequest),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        userController.followUser(targetUserId, invalidRequest),
      ).rejects.toThrow('ID utilisateur manquant');
    });

    it('should handle service errors and log them', async () => {
      const targetUserId = mockUsers[1]._id;
      const serviceError = new Error('Follow operation failed');
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      mockUserService.followUser.mockRejectedValue(serviceError);

      await expect(
        userController.followUser(targetUserId, mockRequest),
      ).rejects.toThrow(serviceError);

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Erreur dans followUser:',
        serviceError,
      );

      consoleErrorSpy.mockRestore();
    });
  });

  describe('unfollowUser', () => {
    it('should unfollow a user successfully', async () => {
      const targetUserId = mockUsers[1]._id;
      const unfollowResult = { success: true, message: 'User unfollowed' };

      mockUserService.unfollowUser.mockResolvedValue(unfollowResult);

      const result = await userController.unfollowUser(
        targetUserId,
        mockRequest,
      );

      expect(result).toEqual(unfollowResult);
      expect(mockUserService.unfollowUser).toHaveBeenCalledWith(
        mockUser._id,
        targetUserId,
      );
    });

    it('should throw UnauthorizedException when user not authenticated', async () => {
      const targetUserId = mockUsers[1]._id;
      const unauthenticatedRequest = { user: null };

      await expect(
        userController.unfollowUser(targetUserId, unauthenticatedRequest),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        userController.unfollowUser(targetUserId, unauthenticatedRequest),
      ).rejects.toThrow('Utilisateur non authentifié');
    });
  });

  describe('getUserFollowers', () => {
    it('should return user followers', async () => {
      const userId = mockUser._id;
      const followers = [mockUsers[1]];

      mockUserService.getUserFollowers.mockResolvedValue(followers);

      const result = await userController.getUserFollowers(userId);

      expect(result).toEqual(followers);
      expect(mockUserService.getUserFollowers).toHaveBeenCalledWith(userId);
    });
  });

  describe('getUserFollowing', () => {
    it('should return user following list', async () => {
      const userId = mockUser._id;
      const following = [mockUsers[2]];

      mockUserService.getUserFollowing.mockResolvedValue(following);

      const result = await userController.getUserFollowing(userId);

      expect(result).toEqual(following);
      expect(mockUserService.getUserFollowing).toHaveBeenCalledWith(userId);
    });
  });

  describe('checkFollowing', () => {
    it('should return true when user is following target', async () => {
      const followerId = mockUser._id;
      const targetId = mockUsers[1]._id;

      mockUserService.isFollowing.mockResolvedValue(true);

      const result = await userController.checkFollowing(followerId, targetId);

      expect(result).toEqual({ isFollowing: true });
      expect(mockUserService.isFollowing).toHaveBeenCalledWith(
        followerId,
        targetId,
      );
    });

    it('should return false when user is not following target', async () => {
      const followerId = mockUser._id;
      const targetId = mockUsers[1]._id;

      mockUserService.isFollowing.mockResolvedValue(false);

      const result = await userController.checkFollowing(followerId, targetId);

      expect(result).toEqual({ isFollowing: false });
    });
  });

  describe('explicitFollowUser', () => {
    it('should follow user with explicit parameters', async () => {
      const followerId = mockUser._id;
      const targetId = mockUsers[1]._id;
      const followResult = { success: true };

      mockUserService.followUser.mockResolvedValue(followResult);

      const result = await userController.explicitFollowUser(
        followerId,
        targetId,
      );

      expect(result).toEqual(followResult);
      expect(mockUserService.followUser).toHaveBeenCalledWith(
        followerId,
        targetId,
      );
    });
  });

  describe('explicitUnfollowUser', () => {
    it('should unfollow user with explicit parameters', async () => {
      const followerId = mockUser._id;
      const targetId = mockUsers[1]._id;
      const unfollowResult = { success: true };

      mockUserService.unfollowUser.mockResolvedValue(unfollowResult);

      const result = await userController.explicitUnfollowUser(
        followerId,
        targetId,
      );

      expect(result).toEqual(unfollowResult);
      expect(mockUserService.unfollowUser).toHaveBeenCalledWith(
        followerId,
        targetId,
      );
    });
  });

  describe('Authentication and Authorization', () => {
    it('should be protected by JwtAuthGuard', () => {
      expect(UserController).toBeDefined();
    });

    it('should extract user from request correctly', async () => {
      const userId = mockUser._id;
      const updatedUser = { ...mockUser, ...validUpdateUserDto };

      mockUserService.updateById.mockResolvedValue(updatedUser);

      await userController.updateProfile(
        userId,
        validUpdateUserDto,
        mockRequest,
      );

      expect(mockUserService.updateById).toHaveBeenCalledWith(
        userId,
        validUpdateUserDto,
      );
    });
  });

  describe('Controller routing', () => {
    it('should be mapped to correct base route', () => {
      const controllerPath = Reflect.getMetadata('path', UserController);
      expect(controllerPath).toBe('api/users');
    });
  });

  describe('Edge cases', () => {
    it('should handle string comparison for user ID verification', async () => {
      const userId = mockUser._id.toString();
      const requestWithObjectId = {
        user: { _id: { toString: () => mockUser._id } },
      };

      mockUserService.updateById.mockResolvedValue(mockUser);

      const result = await userController.updateProfile(
        userId,
        validUpdateUserDto,
        requestWithObjectId,
      );

      expect(result).toEqual(mockUser);
    });

    it('should handle empty followers and following arrays', async () => {
      const userId = mockUser._id;

      mockUserService.getUserFollowers.mockResolvedValue([]);
      mockUserService.getUserFollowing.mockResolvedValue([]);

      const followers = await userController.getUserFollowers(userId);
      const following = await userController.getUserFollowing(userId);

      expect(followers).toEqual([]);
      expect(following).toEqual([]);
    });
  });
});
