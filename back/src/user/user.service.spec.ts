import { Test, TestingModule } from '@nestjs/testing';
import { UserService } from './user.service';
import { getModelToken, getConnectionToken } from '@nestjs/mongoose';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

jest.mock('bcrypt');
const mockedBcrypt = bcrypt as jest.Mocked<typeof bcrypt>;

describe('UserService', () => {
  let userService: UserService;

  const mockUsers = [
    {
      _id: '507f1f77bcf86cd799439011',
      username: 'johndoe',
      email: 'john@plany.com',
      password: '$argon2id$v=19$m=65536,t=3,p=4$hashedPassword123',
      description: 'Développeur passionné',
      isPremium: false,
      photoUrl: 'https://example.com/john.jpg',
      birthDate: new Date('1990-05-15T00:00:00.000Z'),
      gender: 'male',
      role: 'user',
      isActive: true,
      followers: ['507f1f77bcf86cd799439012'],
      following: ['507f1f77bcf86cd799439012'],
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439012',
      username: 'janedoe',
      email: 'jane@plany.com',
      password: '$argon2id$v=19$m=65536,t=3,p=4$hashedPassword456',
      description: 'Voyageuse et photographe',
      isPremium: true,
      photoUrl: 'https://example.com/jane.jpg',
      birthDate: new Date('1992-08-22T00:00:00.000Z'),
      gender: 'female',
      role: 'user',
      isActive: true,
      followers: ['507f1f77bcf86cd799439011'],
      following: [],
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
  ];

  const mockPlans = [
    {
      _id: '507f1f77bcf86cd799439041',
      title: 'Voyage à Paris',
      user: '507f1f77bcf86cd799439011',
      favorites: ['507f1f77bcf86cd799439012'],
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439042',
      title: 'Plan Fitness',
      user: '507f1f77bcf86cd799439012',
      favorites: ['507f1f77bcf86cd799439011'],
      createdAt: new Date('2024-01-20T11:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439043',
      title: 'Séjour à Londres',
      user: '507f1f77bcf86cd799439011',
      favorites: [],
      createdAt: new Date('2024-01-21T10:00:00.000Z'),
    },
  ];

  const createUserDto = {
    username: 'newuser',
    email: 'newuser@plany.com',
    password: 'SecurePass123!',
    description: 'Nouvel utilisateur',
    isPremium: false,
    photoUrl: 'https://example.com/newuser.jpg',
    birthDate: new Date('1995-03-10T00:00:00.000Z'),
    gender: 'other',
    role: 'user',
    isActive: true,
  };

  const updateUserDto = {
    username: 'updateduser',
    email: 'updated@plany.com',
    description: 'Description mise à jour',
    photoUrl: 'https://example.com/updated.jpg',
    birthDate: new Date('1991-06-20T00:00:00.000Z'),
    gender: 'female',
  };

  const mockUserModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: mockUsers[0]._id,
    followers: [],
    following: [],
    createdAt: mockUsers[0].createdAt,
    updatedAt: mockUsers[0].updatedAt,
    save: jest.fn().mockResolvedValue({
      _id: mockUsers[0]._id,
      ...dto,
      followers: [],
      following: [],
      createdAt: mockUsers[0].createdAt,
      updatedAt: mockUsers[0].updatedAt,
    }),
  })) as any;

  mockUserModel.find = jest.fn().mockReturnValue({
    populate: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockUserModel.findOne = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockUserModel.findById = jest.fn().mockReturnValue({
    populate: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockUserModel.findByIdAndUpdate = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockUserModel.findByIdAndDelete = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockUserModel.updateOne = jest.fn();
  mockUserModel.exists = jest.fn();
  mockUserModel.countDocuments = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  const mockPlanModel = {
    find: jest.fn().mockReturnValue({
      sort: jest.fn().mockReturnThis(),
      exec: jest.fn(),
    }),
    countDocuments: jest.fn().mockImplementation(() => ({
      exec: jest.fn().mockResolvedValue(0),
    })),
  };

  const mockConnection = {};

  beforeEach(async () => {
    jest.clearAllMocks();
    mockedBcrypt.hash.mockResolvedValue('hashedPassword' as never);

    mockPlanModel.countDocuments.mockReset();
    mockPlanModel.countDocuments.mockReturnValue({
      exec: jest.fn().mockResolvedValue(0),
    });

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        {
          provide: getModelToken('User'),
          useValue: mockUserModel,
        },
        {
          provide: getModelToken('Plan'),
          useValue: mockPlanModel,
        },
        {
          provide: getConnectionToken(),
          useValue: mockConnection,
        },
      ],
    }).compile();

    userService = module.get<UserService>(UserService);
  });

  it('should be defined', () => {
    expect(userService).toBeDefined();
  });

  describe('create', () => {
    it('should create and return new user with secure password', async () => {
      const result = await userService.create(createUserDto);

      expect(mockUserModel).toHaveBeenCalledWith(createUserDto);
      expect(result._id).toBe(mockUsers[0]._id);
      expect(result.username).toBe(createUserDto.username);
      expect(result.email).toBe(createUserDto.email);
      expect(result.description).toBe(createUserDto.description);
    });

    it('should throw error for insecure password', async () => {
      const insecureUserDto = {
        ...createUserDto,
        password: 'weak',
      };

      await expect(userService.create(insecureUserDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(userService.create(insecureUserDto)).rejects.toThrow(
        'Le mot de passe doit contenir au moins 8 caractères, dont une majuscule, une minuscule et un chiffre',
      );
    });

    it('should handle MongoDB duplicate email error', async () => {
      const duplicateError = new Error('Duplicate key error') as any;
      duplicateError.code = 11000;
      duplicateError.keyPattern = { email: 1 };

      mockUserModel.mockReset();
      mockUserModel.mockImplementation(() => ({
        save: jest.fn().mockRejectedValue(duplicateError),
      }));

      await expect(userService.create(createUserDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(userService.create(createUserDto)).rejects.toThrow(
        'Cet email est déjà utilisé',
      );
    });

    it('should handle MongoDB duplicate username error', async () => {
      const duplicateError = new Error('Duplicate key error') as any;
      duplicateError.code = 11000;
      duplicateError.keyPattern = { username: 1 };

      mockUserModel.mockReset();
      mockUserModel.mockImplementation(() => ({
        save: jest.fn().mockRejectedValue(duplicateError),
      }));

      await expect(userService.create(createUserDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(userService.create(createUserDto)).rejects.toThrow(
        "Ce nom d'utilisateur est déjà pris",
      );
    });
  });

  describe('findAll', () => {
    it('should return all users', async () => {
      mockUserModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockUsers),
      });

      const result = await userService.findAll();

      expect(result).toEqual(mockUsers);
      expect(mockUserModel.find).toHaveBeenCalled();
    });
  });

  describe('findById', () => {
    it('should return user when found with valid ObjectId', async () => {
      const userId = mockUsers[0]._id;
      const expectedUser = mockUsers[0];

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedUser),
      });

      const result = await userService.findById(userId);

      expect(result).toEqual(expectedUser);
      expect(mockUserModel.findById).toHaveBeenCalledWith(userId);
    });

    it('should return null for invalid ObjectId', async () => {
      const result = await userService.findById('invalid-id');

      expect(result).toBeNull();
      expect(mockUserModel.findById).not.toHaveBeenCalled();
    });

    it('should return null when user not found', async () => {
      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await userService.findById('507f1f77bcf86cd799439999');

      expect(result).toBeNull();
    });
  });

  describe('findOneByEmail', () => {
    it('should return user by email', async () => {
      const email = mockUsers[0].email;
      const expectedUser = mockUsers[0];

      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedUser),
      });

      const result = await userService.findOneByEmail(email);

      expect(result).toEqual(expectedUser);
      expect(mockUserModel.findOne).toHaveBeenCalledWith({ email });
    });

    it('should return null when email not found', async () => {
      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await userService.findOneByEmail('nonexistent@plany.com');

      expect(result).toBeNull();
    });
  });

  describe('findOneByUsername', () => {
    it('should return user by username', async () => {
      const username = mockUsers[0].username;
      const expectedUser = mockUsers[0];

      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedUser),
      });

      const result = await userService.findOneByUsername(username);

      expect(result).toEqual(expectedUser);
      expect(mockUserModel.findOne).toHaveBeenCalledWith({ username });
    });
  });

  describe('updateById', () => {
    it('should update and return user', async () => {
      const userId = mockUsers[0]._id;
      const updatedUser = {
        ...mockUsers[0],
        ...updateUserDto,
      };

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedUser),
      });

      const result = await userService.updateById(userId, updateUserDto);

      expect(result).toEqual(updatedUser);
      expect(mockUserModel.findByIdAndUpdate).toHaveBeenCalledWith(
        userId,
        { $set: updateUserDto },
        { new: true },
      );
    });

    it('should hash password when updating', async () => {
      const userId = mockUsers[0]._id;
      const updateWithPassword = {
        ...updateUserDto,
        password: 'NewPassword123!',
      };

      const updatedUser = {
        ...mockUsers[0],
        ...updateWithPassword,
        password: 'hashedPassword',
      };

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedUser),
      });

      const result = await userService.updateById(userId, updateWithPassword);

      expect(mockedBcrypt.hash).toHaveBeenCalledWith('NewPassword123!', 12);
      expect(result.password).toBe('hashedPassword');
    });

    it('should handle birthDate format', async () => {
      const userId = mockUsers[0]._id;
      const updateWithBirthDate = {
        birthDate: new Date('1995-06-15T14:30:00.000Z'),
      };

      const expectedBirthDate = new Date(Date.UTC(1995, 5, 15, 12, 0, 0));

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          ...mockUsers[0],
          birthDate: expectedBirthDate,
        }),
      });

      await userService.updateById(userId, updateWithBirthDate);

      expect(mockUserModel.findByIdAndUpdate).toHaveBeenCalledWith(
        userId,
        { $set: { birthDate: expectedBirthDate } },
        { new: true },
      );
    });

    it('should throw NotFoundException when user not found', async () => {
      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(
        userService.updateById('nonexistent', updateUserDto),
      ).rejects.toThrow(NotFoundException);
      await expect(
        userService.updateById('nonexistent', updateUserDto),
      ).rejects.toThrow('User with ID nonexistent not found');
    });
  });

  describe('removeById', () => {
    it('should delete and return user', async () => {
      const userId = mockUsers[0]._id;
      const deletedUser = mockUsers[0];

      mockUserModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedUser),
      });

      const result = await userService.removeById(userId);

      expect(result).toEqual(deletedUser);
      expect(mockUserModel.findByIdAndDelete).toHaveBeenCalledWith(userId);
    });
  });

  describe('getUserPlans', () => {
    it('should return user plans', async () => {
      const userId = mockUsers[0]._id;
      const userPlans = [mockPlans[0], mockPlans[2]];

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockUsers[0]),
      });

      mockPlanModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(userPlans),
      });

      const result = await userService.getUserPlans(userId);

      expect(result).toEqual(userPlans);
      expect(mockUserModel.findById).toHaveBeenCalledWith(userId);
    });

    it('should throw NotFoundException when user not found', async () => {
      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(userService.getUserPlans('nonexistent')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('getUserFavorites', () => {
    it('should return user favorite plans', async () => {
      const userId = mockUsers[0]._id;
      const favorites = [mockPlans[1]];

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockUsers[0]),
      });

      mockPlanModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(favorites),
      });

      const result = await userService.getUserFavorites(userId);

      expect(result).toEqual(favorites);
      expect(mockUserModel.findById).toHaveBeenCalledWith(userId);
    });
  });

  describe('getPremiumStatus', () => {
    it('should return true for premium user', async () => {
      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockUsers[1]),
      });

      const result = await userService.getPremiumStatus(mockUsers[1]._id);

      expect(result).toBe(true);
    });

    it('should return false for non-premium user', async () => {
      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockUsers[0]),
      });

      const result = await userService.getPremiumStatus(mockUsers[0]._id);

      expect(result).toBe(false);
    });

    it('should return false when user not found', async () => {
      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await userService.getPremiumStatus('nonexistent');

      expect(result).toBe(false);
    });
  });

  describe('followUser', () => {
    it('should follow user successfully', async () => {
      const followerId = mockUsers[0]._id;
      const targetUserId = mockUsers[1]._id;

      mockUserModel.exists
        .mockResolvedValueOnce({ _id: followerId })
        .mockResolvedValueOnce({ _id: targetUserId })
        .mockResolvedValueOnce(null);
      mockUserModel.updateOne.mockResolvedValue({ modifiedCount: 1 });

      const result = await userService.followUser(followerId, targetUserId);

      expect(result).toEqual({ message: 'Abonnement réussi', success: true });
      expect(mockUserModel.updateOne).toHaveBeenCalledTimes(2);
    });

    it('should return message if already following', async () => {
      const followerId = mockUsers[0]._id;
      const targetUserId = mockUsers[1]._id;

      mockUserModel.exists
        .mockResolvedValueOnce({ _id: followerId })
        .mockResolvedValueOnce({ _id: targetUserId })
        .mockResolvedValueOnce({ _id: followerId });

      const result = await userService.followUser(followerId, targetUserId);

      expect(result).toEqual({
        message: 'Vous suivez déjà cet utilisateur',
        success: false,
      });
      expect(mockUserModel.updateOne).not.toHaveBeenCalled();
    });

    it('should throw NotFoundException when follower not found', async () => {
      mockUserModel.exists.mockResolvedValueOnce(null);

      await expect(
        userService.followUser('nonexistent', mockUsers[1]._id),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException when target not found', async () => {
      mockUserModel.exists
        .mockResolvedValueOnce({ _id: mockUsers[0]._id })
        .mockResolvedValueOnce(null);

      await expect(
        userService.followUser(mockUsers[0]._id, 'nonexistent'),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('unfollowUser', () => {
    it('should unfollow user successfully', async () => {
      const followerId = mockUsers[0]._id;
      const targetUserId = mockUsers[1]._id;

      mockUserModel.exists
        .mockResolvedValueOnce({ _id: followerId })
        .mockResolvedValueOnce({ _id: targetUserId });

      mockUserModel.updateOne.mockResolvedValue({ modifiedCount: 1 });

      const result = await userService.unfollowUser(followerId, targetUserId);

      expect(result).toEqual({
        message: 'Désabonnement réussi',
        success: true,
      });
      expect(mockUserModel.updateOne).toHaveBeenCalledTimes(2);
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: followerId },
        { $pull: { following: targetUserId } },
      );
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: targetUserId },
        { $pull: { followers: followerId } },
      );
    });
  });

  describe('getUserFollowers', () => {
    it('should return user followers', async () => {
      const userId = mockUsers[0]._id;
      const populatedUser = {
        ...mockUsers[0],
        followers: [{ username: 'jane', photoUrl: 'jane.jpg' }],
      };

      mockUserModel.findById
        .mockReturnValueOnce({
          exec: jest.fn().mockResolvedValue(mockUsers[0]),
        })
        .mockReturnValueOnce({
          populate: jest.fn().mockReturnThis(),
          exec: jest.fn().mockResolvedValue(populatedUser),
        });

      const result = await userService.getUserFollowers(userId);

      expect(result).toEqual(populatedUser.followers);
    });
  });

  describe('getUserFollowing', () => {
    it('should return formatted following users', async () => {
      const userId = mockUsers[0]._id;
      const followingUsers = [mockUsers[1]];

      mockUserModel.findOne.mockResolvedValue(mockUsers[0]);
      mockUserModel.find.mockReturnValue({
        select: jest.fn().mockResolvedValue(followingUsers),
      });

      const result = await userService.getUserFollowing(userId);

      expect(result).toHaveLength(1);
      expect(result[0]).toEqual({
        id: mockUsers[1]._id,
        username: mockUsers[1].username,
        photoUrl: mockUsers[1].photoUrl,
        isPremium: mockUsers[1].isPremium,
        followersCount: mockUsers[1].followers.length,
        followingCount: mockUsers[1].following.length,
      });
    });
  });

  describe('checkIfFollowing', () => {
    it('should return true if following', async () => {
      mockUserModel.findById
        .mockReturnValueOnce({
          exec: jest.fn().mockResolvedValue(mockUsers[0]),
        })
        .mockReturnValueOnce({
          exec: jest.fn().mockResolvedValue(mockUsers[1]),
        });

      const result = await userService.checkIfFollowing(
        mockUsers[0]._id,
        mockUsers[1]._id,
      );

      expect(result.isFollowing).toBe(true);
    });

    it('should return false if not following', async () => {
      const userNotFollowing = {
        ...mockUsers[0],
        following: [],
      };

      mockUserModel.findById
        .mockReturnValueOnce({
          exec: jest.fn().mockResolvedValue(userNotFollowing),
        })
        .mockReturnValueOnce({
          exec: jest.fn().mockResolvedValue(mockUsers[1]),
        });

      const result = await userService.checkIfFollowing(
        mockUsers[0]._id,
        mockUsers[1]._id,
      );

      expect(result.isFollowing).toBe(false);
    });
  });

  describe('getUserStats', () => {
    it('should call required methods', async () => {
      const userId = mockUsers[0]._id;

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockUsers[0]),
      });

      const result = await userService.getUserStats(userId);

      expect(result).toBeDefined();
      expect(result).toHaveProperty('plansCount');
      expect(result).toHaveProperty('favoritesCount');
      expect(result).toHaveProperty('followersCount');
      expect(result).toHaveProperty('followingCount');
      expect(mockUserModel.findById).toHaveBeenCalledWith(userId);
    });
  });

  describe('isFollowing', () => {
    it('should return true when user is following target', async () => {
      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockUsers[0]),
      });

      const result = await userService.isFollowing(
        mockUsers[0]._id,
        mockUsers[1]._id,
      );

      expect(result).toBe(true);
      expect(mockUserModel.findOne).toHaveBeenCalledWith({
        _id: mockUsers[0]._id,
        following: mockUsers[1]._id,
      });
    });

    it('should return false when user is not following target', async () => {
      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await userService.isFollowing(
        mockUsers[0]._id,
        'someOtherId',
      );

      expect(result).toBe(false);
    });
  });
});
