import { Test, TestingModule } from '@nestjs/testing';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { PlanService } from '../plan/plan.service';
import { AuthService } from '../auth/auth.service';
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
  let authService: AuthService;

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
  };

  const validUpdateUserDto: UpdateUserDto = {
    username: 'updateduser',
    description: 'Description mise à jour',
    photoUrl: 'https://example.com/updated.jpg',
    isPremium: true,
  };

  const mockUser = mockUsers[0];

  const mockRequest = {
    user: mockUser,
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

  const mockAuthService = {
    validateUser: jest.fn(),
    login: jest.fn(),
    register: jest.fn(),
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
        {
          provide: AuthService,
          useValue: mockAuthService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue(mockJwtAuthGuard)
      .compile();

    userController = module.get<UserController>(UserController);
    userService = module.get<UserService>(UserService);
    planService = module.get<PlanService>(PlanService);
    authService = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(userController).toBeDefined();
    expect(userService).toBeDefined();
    expect(planService).toBeDefined();
    expect(authService).toBeDefined();
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

      const result = await userController.findOne(userId, mockRequest);

      expect(result).toEqual(mockUser);
      expect(mockUserService.findById).toHaveBeenCalledWith(userId);
      expect(mockUserService.findById).toHaveBeenCalledTimes(1);
    });

    it('should return current user when id is "me"', async () => {
      mockUserService.findById.mockResolvedValue(mockUser);

      const result = await userController.findOne('me', mockRequest);

      expect(result).toEqual(mockUser);
      expect(mockUserService.findById).toHaveBeenCalledWith(mockUser._id);
    });

    it('should throw NotFoundException when user not found', async () => {
      const userId = '507f1f77bcf86cd799439999';
      mockUserService.findById.mockResolvedValue(null);

      await expect(userController.findOne(userId, mockRequest)).rejects.toThrow(
        NotFoundException,
      );
      await expect(userController.findOne(userId, mockRequest)).rejects.toThrow(
        `User with ID ${userId} not found`,
      );
    });

    it('should throw NotFoundException when current user not found with "me"', async () => {
      mockUserService.findById.mockResolvedValue(null);

      await expect(userController.findOne('me', mockRequest)).rejects.toThrow(
        NotFoundException,
      );
      await expect(userController.findOne('me', mockRequest)).rejects.toThrow(
        `User with ID ${mockUser._id} not found`,
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
    it('should update own email successfully with correct password', async () => {
      const userId = mockUser._id;
      const newEmail = 'newemail@plany.com';
      const password = 'correctPassword123';
      const updatedUser = { ...mockUser, email: newEmail };

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockAuthService.validateUser.mockResolvedValue(mockUser);
      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updateEmail(
        userId,
        newEmail,
        password,
        mockRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.findOneByEmail).toHaveBeenCalledWith(newEmail);
      expect(mockAuthService.validateUser).toHaveBeenCalledWith(
        mockUser.email,
        password,
      );
      expect(mockUserService.updateById).toHaveBeenCalledWith(userId, {
        email: newEmail,
      });
    });

    it('should throw UnauthorizedException for incorrect password', async () => {
      const userId = mockUser._id;
      const newEmail = 'newemail@plany.com';
      const wrongPassword = 'wrongPassword';

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockAuthService.validateUser.mockResolvedValue(null);

      await expect(
        userController.updateEmail(
          userId,
          newEmail,
          wrongPassword,
          mockRequest,
        ),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        userController.updateEmail(
          userId,
          newEmail,
          wrongPassword,
          mockRequest,
        ),
      ).rejects.toThrow('Mot de passe incorrect');
    });

    it('should throw UnauthorizedException when updating other user email', async () => {
      const otherUserId = mockUsers[1]._id;
      const newEmail = 'newemail@plany.com';
      const password = 'password123';

      await expect(
        userController.updateEmail(
          otherUserId,
          newEmail,
          password,
          mockRequest,
        ),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        userController.updateEmail(
          otherUserId,
          newEmail,
          password,
          mockRequest,
        ),
      ).rejects.toThrow('Vous ne pouvez pas modifier cet email');
    });

    it('should throw UnauthorizedException when email already exists', async () => {
      const userId = mockUser._id;
      const existingEmail = 'existing@plany.com';
      const password = 'password123';
      const existingUser = {
        ...mockUsers[1],
        email: existingEmail,
        _id: mockUsers[1]._id,
      };

      mockUserService.findOneByEmail.mockResolvedValue(existingUser);

      await expect(
        userController.updateEmail(
          userId,
          existingEmail,
          password,
          mockRequest,
        ),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        userController.updateEmail(
          userId,
          existingEmail,
          password,
          mockRequest,
        ),
      ).rejects.toThrow('Cet email est déjà utilisé');
    });

    it('should update email when id is "me"', async () => {
      const newEmail = 'newemail@plany.com';
      const password = 'correctPassword123';
      const updatedUser = { ...mockUser, email: newEmail };

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockAuthService.validateUser.mockResolvedValue(mockUser);
      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updateEmail(
        'me',
        newEmail,
        password,
        mockRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(mockUser._id, {
        email: newEmail,
      });
    });
  });

  describe('getUserPlans', () => {
    it('should return user plans', async () => {
      const userId = mockUser._id;
      mockPlanService.findAllByUserId.mockResolvedValue(mockPlans);

      const result = await userController.getUserPlans(userId, mockRequest);

      expect(result).toEqual(mockPlans);
      expect(mockPlanService.findAllByUserId).toHaveBeenCalledWith(userId);
    });

    it('should return current user plans when id is "me"', async () => {
      mockPlanService.findAllByUserId.mockResolvedValue(mockPlans);

      const result = await userController.getUserPlans('me', mockRequest);

      expect(result).toEqual(mockPlans);
      expect(mockPlanService.findAllByUserId).toHaveBeenCalledWith(
        mockUser._id,
      );
    });

    it('should handle and log errors in getUserPlans', async () => {
      const userId = mockUser._id;
      const error = new Error('Plans fetch failed');
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      mockPlanService.findAllByUserId.mockRejectedValue(error);

      await expect(
        userController.getUserPlans(userId, mockRequest),
      ).rejects.toThrow(error);

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        `Error getting plans: ${error.message}`,
      );

      consoleErrorSpy.mockRestore();
    });
  });

  describe('getUserFavorites', () => {
    it('should return user favorites', async () => {
      const userId = mockUser._id;
      mockPlanService.findFavoritesByUserId.mockResolvedValue(mockPlans);

      const result = await userController.getUserFavorites(userId, mockRequest);

      expect(result).toEqual(mockPlans);
      expect(mockPlanService.findFavoritesByUserId).toHaveBeenCalledWith(
        userId,
      );
    });

    it('should return current user favorites when id is "me"', async () => {
      mockPlanService.findFavoritesByUserId.mockResolvedValue(mockPlans);

      const result = await userController.getUserFavorites('me', mockRequest);

      expect(result).toEqual(mockPlans);
      expect(mockPlanService.findFavoritesByUserId).toHaveBeenCalledWith(
        mockUser._id,
      );
    });

    it('should handle and log errors in getUserFavorites', async () => {
      const userId = mockUser._id;
      const error = new Error('Favorites fetch failed');
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      mockPlanService.findFavoritesByUserId.mockRejectedValue(error);

      await expect(
        userController.getUserFavorites(userId, mockRequest),
      ).rejects.toThrow(error);

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        `Error getting favorites: ${error.message}`,
      );

      consoleErrorSpy.mockRestore();
    });
  });

  describe('getUserStats', () => {
    it('should return user statistics', async () => {
      const userId = mockUser._id;
      mockUserService.getUserStats.mockResolvedValue(mockUserStats);

      const result = await userController.getUserStats(userId, mockRequest);

      expect(result).toEqual(mockUserStats);
      expect(mockUserService.getUserStats).toHaveBeenCalledWith(userId);
    });

    it('should return current user stats when id is "me"', async () => {
      mockUserService.getUserStats.mockResolvedValue(mockUserStats);

      const result = await userController.getUserStats('me', mockRequest);

      expect(result).toEqual(mockUserStats);
      expect(mockUserService.getUserStats).toHaveBeenCalledWith(mockUser._id);
    });

    it('should handle and log errors in getUserStats', async () => {
      const userId = mockUser._id;
      const error = new Error('Stats fetch failed');
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      mockUserService.getUserStats.mockRejectedValue(error);

      await expect(
        userController.getUserStats(userId, mockRequest),
      ).rejects.toThrow(error);

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Erreur dans getUserStats:',
        error,
      );

      consoleErrorSpy.mockRestore();
    });
  });

  describe('checkFollowing', () => {
    it('should return true when user is following target', async () => {
      const followerId = mockUser._id;
      const targetId = mockUsers[1]._id;

      mockUserService.isFollowing.mockResolvedValue(true);

      const result = await userController.checkFollowing(
        followerId,
        targetId,
        mockRequest,
      );

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

      const result = await userController.checkFollowing(
        followerId,
        targetId,
        mockRequest,
      );

      expect(result).toEqual({ isFollowing: false });
    });

    it('should check following status when followerId is "me"', async () => {
      const targetId = mockUsers[1]._id;

      mockUserService.isFollowing.mockResolvedValue(true);

      const result = await userController.checkFollowing(
        'me',
        targetId,
        mockRequest,
      );

      expect(result).toEqual({ isFollowing: true });
      expect(mockUserService.isFollowing).toHaveBeenCalledWith(
        mockUser._id,
        targetId,
      );
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
        mockRequest,
      );

      expect(result).toEqual(followResult);
      expect(mockUserService.followUser).toHaveBeenCalledWith(
        followerId,
        targetId,
      );
    });

    it('should follow user when followerId is "me"', async () => {
      const targetId = mockUsers[1]._id;
      const followResult = { success: true };

      mockUserService.followUser.mockResolvedValue(followResult);

      const result = await userController.explicitFollowUser(
        'me',
        targetId,
        mockRequest,
      );

      expect(result).toEqual(followResult);
      expect(mockUserService.followUser).toHaveBeenCalledWith(
        mockUser._id,
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
        mockRequest,
      );

      expect(result).toEqual(unfollowResult);
      expect(mockUserService.unfollowUser).toHaveBeenCalledWith(
        followerId,
        targetId,
      );
    });

    it('should unfollow user when followerId is "me"', async () => {
      const targetId = mockUsers[1]._id;
      const unfollowResult = { success: true };

      mockUserService.unfollowUser.mockResolvedValue(unfollowResult);

      const result = await userController.explicitUnfollowUser(
        'me',
        targetId,
        mockRequest,
      );

      expect(result).toEqual(unfollowResult);
      expect(mockUserService.unfollowUser).toHaveBeenCalledWith(
        mockUser._id,
        targetId,
      );
    });
  });

  describe('Parameter "me" handling', () => {
    it('should handle "me" parameter in updateProfile', async () => {
      const updatedUser = { ...mockUser, ...validUpdateUserDto };
      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updateProfile(
        'me',
        validUpdateUserDto,
        mockRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(
        mockUser._id,
        validUpdateUserDto,
      );
    });

    it('should handle "me" parameter in removeById', async () => {
      mockUserService.removeById.mockResolvedValue(mockUser);

      const result = await userController.removeById('me', mockRequest);

      expect(result).toEqual(mockUser);
      expect(mockUserService.removeById).toHaveBeenCalledWith(mockUser._id);
    });

    it('should handle "me" parameter in updateUserPhoto', async () => {
      const newPhotoUrl = 'https://example.com/newphoto.jpg';
      const updatedUser = { ...mockUser, photoUrl: newPhotoUrl };

      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updateUserPhoto(
        'me',
        newPhotoUrl,
        mockRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(mockUser._id, {
        photoUrl: newPhotoUrl,
      });
    });

    it('should handle "me" parameter in deleteUserPhoto', async () => {
      const updatedUser = { ...mockUser, photoUrl: null };
      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.deleteUserPhoto('me', mockRequest);

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(mockUser._id, {
        photoUrl: null,
      });
    });

    it('should handle "me" parameter in updatePremiumStatus', async () => {
      const isPremium = true;
      const updatedUser = { ...mockUser, isPremium };
      mockUserService.updateById.mockResolvedValue(updatedUser);

      const result = await userController.updatePremiumStatus(
        'me',
        isPremium,
        mockRequest,
      );

      expect(result).toEqual(updatedUser);
      expect(mockUserService.updateById).toHaveBeenCalledWith(mockUser._id, {
        isPremium,
      });
    });

    it('should handle "me" parameter in followUser', async () => {
      const followResult = { success: true, message: 'User followed' };
      mockUserService.followUser.mockResolvedValue(followResult);

      const result = await userController.followUser('me', mockRequest);

      expect(result).toEqual(followResult);
      expect(mockUserService.followUser).toHaveBeenCalledWith(
        mockUser._id,
        mockUser._id,
      );
    });

    it('should handle "me" parameter in unfollowUser', async () => {
      const unfollowResult = { success: true, message: 'User unfollowed' };
      mockUserService.unfollowUser.mockResolvedValue(unfollowResult);

      const result = await userController.unfollowUser('me', mockRequest);

      expect(result).toEqual(unfollowResult);
      expect(mockUserService.unfollowUser).toHaveBeenCalledWith(
        mockUser._id,
        mockUser._id,
      );
    });

    it('should handle "me" parameter in getUserFollowers', async () => {
      const followers = [mockUsers[1]];
      mockUserService.getUserFollowers.mockResolvedValue(followers);

      const result = await userController.getUserFollowers('me', mockRequest);

      expect(result).toEqual(followers);
      expect(mockUserService.getUserFollowers).toHaveBeenCalledWith(
        mockUser._id,
      );
    });

    it('should handle "me" parameter in getUserFollowing', async () => {
      const following = [mockUsers[2]];
      mockUserService.getUserFollowing.mockResolvedValue(following);

      const result = await userController.getUserFollowing('me', mockRequest);

      expect(result).toEqual(following);
      expect(mockUserService.getUserFollowing).toHaveBeenCalledWith(
        mockUser._id,
      );
    });
  });

  describe('Error handling with logs', () => {
    it('should log errors in getUserFollowing', async () => {
      const userId = mockUser._id;
      const error = new Error('Following fetch failed');
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      mockUserService.getUserFollowing.mockRejectedValue(error);

      await expect(
        userController.getUserFollowing(userId, mockRequest),
      ).rejects.toThrow(error);

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Erreur dans getUserFollowing:',
        error,
      );

      consoleErrorSpy.mockRestore();
    });
  });
});
