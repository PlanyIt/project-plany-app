/* eslint-disable prettier/prettier */
import { Test, TestingModule } from '@nestjs/testing';
import { UserService } from '../../../src/user/user.service';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import * as userFixtures from '../../__fixtures__/users.json';
import { getModelToken, getConnectionToken } from '@nestjs/mongoose';
import { PasswordService } from '../../../src/auth/password.service';
import * as argon2 from 'argon2';

/**
 * Factory de mocks pour les tests
 */
function createTestMocks() {
  const { validUsers } = userFixtures;

  const createChainableMock = (resolvedValue: any) => ({
    populate: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    session: jest.fn().mockReturnThis(),
    exec: jest.fn().mockResolvedValue(resolvedValue),
    then: jest
      .fn()
      .mockImplementation((callback) =>
        Promise.resolve(callback(resolvedValue)),
      ),
    catch: jest.fn().mockReturnThis(),
  });

  const createSessionMock = (resolvedValue: any) => ({
    populate: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    session: jest.fn().mockResolvedValue(resolvedValue),
    exec: jest.fn().mockResolvedValue(resolvedValue),
    then: jest
      .fn()
      .mockImplementation((callback) =>
        Promise.resolve(callback(resolvedValue)),
      ),
    catch: jest.fn().mockReturnThis(),
  });

  const createSessionExecMock = (resolvedValue: any) => ({
    populate: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    session: jest.fn().mockReturnValue({
      exec: jest.fn().mockResolvedValue(resolvedValue),
      then: jest
        .fn()
        .mockImplementation((callback) =>
          Promise.resolve(callback(resolvedValue)),
        ),
      catch: jest.fn().mockReturnThis(),
    }),
    exec: jest.fn().mockResolvedValue(resolvedValue),
    then: jest
      .fn()
      .mockImplementation((callback) =>
        Promise.resolve(callback(resolvedValue)),
      ),
    catch: jest.fn().mockReturnThis(),
  });

  const mockUserModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: validUsers[0]._id,
    createdAt: new Date(validUsers[0].createdAt),
    updatedAt: new Date(validUsers[0].updatedAt),
    save: jest.fn().mockResolvedValue({
      _id: validUsers[0]._id,
      ...dto,
      createdAt: new Date(validUsers[0].createdAt),
      updatedAt: new Date(validUsers[0].updatedAt),
    }),
  })) as any;

  mockUserModel.find = jest.fn(() => createChainableMock([]));
  mockUserModel.findOne = jest.fn(() => createChainableMock(null));
  mockUserModel.findById = jest.fn(() => createChainableMock(null));
  mockUserModel.findByIdAndUpdate = jest.fn(() => createChainableMock(null));
  mockUserModel.findByIdAndDelete = jest.fn(() => createChainableMock(null));

  mockUserModel.updateOne = jest.fn().mockResolvedValue({ modifiedCount: 1 });
  mockUserModel.updateMany = jest.fn().mockReturnValue({
    session: jest.fn().mockResolvedValue({ modifiedCount: 1 }),
  });
  mockUserModel.exists = jest.fn();
  mockUserModel.countDocuments = jest.fn();

  const mockPlanModel = {
    find: jest.fn(() => createChainableMock([])),
    countDocuments: jest.fn().mockResolvedValue(0),
    updateMany: jest.fn().mockReturnValue({
      session: jest.fn().mockResolvedValue({ modifiedCount: 0 }),
    }),
    deleteMany: jest.fn().mockReturnValue({
      session: jest.fn().mockResolvedValue({ deletedCount: 0 }),
    }),
  };

  const mockCommentModel = {
    find: jest.fn(() => createChainableMock([])),
    deleteMany: jest.fn().mockReturnValue({
      session: jest.fn().mockResolvedValue({ deletedCount: 0 }),
    }),
    countDocuments: jest.fn().mockResolvedValue(0),
  };

  const mockConnection = {
    startSession: jest.fn().mockReturnValue({
      withTransaction: jest.fn().mockImplementation((callback) => callback()),
      endSession: jest.fn(),
    }),
  };

  const mockPasswordService = {
    hashPassword: jest
      .fn()
      .mockResolvedValue('$argon2id$v=19$m=65536,t=3,p=4$hashedPassword123'),
    comparePassword: jest.fn().mockResolvedValue(true),
  };

  return {
    mockUserModel,
    mockPlanModel,
    mockCommentModel,
    mockConnection,
    mockPasswordService,
    createChainableMock,
    createSessionMock,
    createSessionExecMock,
  };
}

describe('UserService', () => {
  let userService: UserService;
  let passwordService: PasswordService;

  const {
    validUsers,
    createUserDtos,
    updateUserDtos,
    invalidData,
    followOperations,
    passwordOperations,
    specialCases,
  } = userFixtures;

  const {
    mockUserModel,
    mockPlanModel,
    mockCommentModel,
    mockConnection,
    mockPasswordService,
    createChainableMock,
    createSessionMock,
    createSessionExecMock,
  } = createTestMocks();

  beforeEach(async () => {
    jest.clearAllMocks();

    mockUserModel.findOne.mockReturnValue(createChainableMock(null));
    mockUserModel.findById.mockReturnValue(createChainableMock(null));
    mockUserModel.find.mockReturnValue(createChainableMock([]));
    mockPlanModel.find.mockReturnValue(createChainableMock([]));

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
          provide: getModelToken('Comment'),
          useValue: mockCommentModel,
        },
        {
          provide: getConnectionToken(),
          useValue: mockConnection,
        },
        {
          provide: PasswordService,
          useValue: mockPasswordService,
        },
        {
          provide: 'CACHE_MANAGER',
          useValue: { get: jest.fn(), set: jest.fn(), del: jest.fn() },
        },
      ],
    }).compile();

    userService = module.get<UserService>(UserService);
    passwordService = module.get<PasswordService>(PasswordService);

    jest
      .spyOn(argon2, 'hash')
      .mockResolvedValue(passwordOperations.hashResults.hash);
  });

  it('should be defined', () => {
    expect(userService).toBeDefined();
  });

  // --- TESTS POUR CREATE ---
  describe('create', () => {
    it('should create and return new user with valid data', async () => {
      const createData = createUserDtos.validCreate;

      const result = await userService.create(createData);

      expect(mockUserModel).toHaveBeenCalledWith(createData);
      expect(result._id).toBe(validUsers[0]._id);
      expect(result.username).toBe(createData.username);
      expect(result.email).toBe(createData.email);
    });

    it('should create user with minimal required data', async () => {
      const createData = createUserDtos.minimalCreate;
      jest.spyOn(userService as any, 'isPasswordSecure').mockReturnValue(true);

      const result = await userService.create(createData);

      expect(result.username).toBe(createData.username);
      expect(result.email).toBe(createData.email);
      expect(result.description).toBeUndefined();
    });

    it('should create premium user', async () => {
      const createData = createUserDtos.premiumCreate;
      jest.spyOn(userService as any, 'isPasswordSecure').mockReturnValue(true);

      const result = await userService.create(createData);

      expect(result.isPremium).toBe(createData.isPremium);
    });

    it('should create admin user', async () => {
      const createData = createUserDtos.adminCreate;
      jest.spyOn(userService as any, 'isPasswordSecure').mockReturnValue(true);

      const result = await userService.create(createData);

      expect(result.role).toBe(createData.role);
    });

    it('should throw error when email already exists', async () => {
      const createData = invalidData.duplicateEmail;
      const mongoError = new Error('Duplicate key error') as Error & {
        code: number;
        keyPattern?: any;
      };
      mongoError.code = 11000;
      mongoError.keyPattern = { email: 1 };

      mockUserModel.mockImplementation(() => ({
        save: jest.fn().mockRejectedValue(mongoError),
      }));

      await expect(userService.create(createData)).rejects.toThrow(
        'Cet email est déjà utilisé',
      );
    });

    it('should throw error when username already exists', async () => {
      const createData = invalidData.duplicateUsername;
      const mongoError = new Error('Duplicate key error') as Error & {
        code: number;
        keyPattern?: any;
      };
      mongoError.code = 11000;
      mongoError.keyPattern = { username: 1 };

      mockUserModel.mockImplementation(() => ({
        save: jest.fn().mockRejectedValue(mongoError),
      }));

      await expect(userService.create(createData)).rejects.toThrow(
        "Ce nom d'utilisateur est déjà pris",
      );
    });

    it('should throw error when password is not secure', async () => {
      const createData = invalidData.weakPassword;

      await expect(userService.create(createData)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  // --- TESTS POUR FIND ---
  describe('find methods', () => {
    it('should find user by id when exists', async () => {
      const userId = validUsers[0]._id;

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(validUsers[0]),
      });

      const result = await userService.findById(userId);

      expect(result).toEqual(validUsers[0]);
      expect(mockUserModel.findById).toHaveBeenCalledWith(userId);
    });

    it('should find user by email when exists', async () => {
      const email = validUsers[0].email;

      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(validUsers[0]),
      });

      const result = await userService.findOneByEmail(email);

      expect(result).toEqual(validUsers[0]);
      expect(mockUserModel.findOne).toHaveBeenCalledWith({ email });
    });

    it('should find user by username when exists', async () => {
      const username = validUsers[0].username;

      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(validUsers[0]),
      });

      const result = await userService.findOneByUsername(username);

      expect(result).toEqual(validUsers[0]);
      expect(mockUserModel.findOne).toHaveBeenCalledWith({ username });
    });

    it('should find all users', async () => {
      mockUserModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(validUsers),
      });

      const result = await userService.findAll();

      expect(result).toEqual(validUsers);
      expect(mockUserModel.find).toHaveBeenCalled();
    });
  });

  // --- TESTS POUR UPDATE ---
  describe('updateById', () => {
    it('should update user with valid data', async () => {
      const userId = validUsers[0]._id;
      const updateData = updateUserDtos.partialUpdate;
      const updatedUser = { ...validUsers[0], ...updateData };

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedUser),
      });

      const result = await userService.updateById(userId, updateData);

      expect(result).toEqual(updatedUser);
      expect(mockUserModel.findByIdAndUpdate).toHaveBeenCalledWith(
        userId,
        { $set: updateData },
        { new: true },
      );
    });

    it('should throw NotFoundException when user not found', async () => {
      const userId = '507f1f77bcf86cd799439999';
      const updateData = updateUserDtos.partialUpdate;

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(userService.updateById(userId, updateData)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should hash password when updating password', async () => {
      const userId = validUsers[0]._id;
      const updateData = { password: 'NewPassword123!' };
      const hashedPassword = '$argon2id$v=19$m=65536,t=3,p=4$hashedPassword123';

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          ...validUsers[0],
          password: hashedPassword,
        }),
      });

      await userService.updateById(userId, updateData);

      expect(passwordService.hashPassword).toHaveBeenCalledWith(
        'NewPassword123!',
      );
    });

    it('should format birthDate correctly', async () => {
      const userId = validUsers[0]._id;
      const birthDate = new Date('1990-05-15');
      const updateData = { birthDate };

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          ...validUsers[0],
          birthDate,
        }),
      });

      await userService.updateById(userId, updateData);

      expect(mockUserModel.findByIdAndUpdate).toHaveBeenCalledWith(
        userId,
        {
          $set: expect.objectContaining({
            birthDate: expect.any(Date),
          }),
        },
        { new: true },
      );
    });
  });

  // --- TESTS POUR FOLLOW/UNFOLLOW ---
  describe('follow operations', () => {
    it('should follow user successfully', async () => {
      const userId = followOperations.beforeFollow._id;
      const targetUserId = followOperations.userToFollow._id;

      mockUserModel.exists
        .mockResolvedValueOnce({ _id: userId })
        .mockResolvedValueOnce({ _id: targetUserId })
        .mockResolvedValueOnce(null);

      const result = await userService.followUser(userId, targetUserId);

      expect(result.success).toBe(true);
      expect(mockUserModel.updateOne).toHaveBeenCalledTimes(2);
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: userId },
        { $addToSet: { following: targetUserId } },
      );
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: targetUserId },
        { $addToSet: { followers: userId } },
      );
    });

    it('should unfollow user successfully', async () => {
      const userId = followOperations.afterFollow._id;
      const targetUserId = followOperations.userToFollow._id;

      mockUserModel.exists
        .mockResolvedValueOnce({ _id: userId })
        .mockResolvedValueOnce({ _id: targetUserId });

      const result = await userService.unfollowUser(userId, targetUserId);

      expect(result.success).toBe(true);
      expect(mockUserModel.updateOne).toHaveBeenCalledTimes(2);
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: userId },
        { $pull: { following: targetUserId } },
      );
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: targetUserId },
        { $pull: { followers: userId } },
      );
    });

    it('should check if user is following another', async () => {
      const followerId = validUsers[0]._id;
      const targetId = validUsers[1]._id;

      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(validUsers[0]),
      });

      const result = await userService.isFollowing(followerId, targetId);

      expect(result).toBe(true);
      expect(mockUserModel.findOne).toHaveBeenCalledWith({
        _id: followerId,
        following: targetId,
      });
    });
  });

  // --- TESTS POUR DELETE ---
  describe('removeById', () => {
    it('should delete user and cleanup related data', async () => {
      const userId = validUsers[0]._id;
      const mockSession = {
        withTransaction: jest.fn().mockImplementation((callback) => callback()),
        endSession: jest.fn(),
      };

      mockConnection.startSession.mockResolvedValue(mockSession);

      // Mock pour vérifier que l'utilisateur existe
      mockUserModel.findById.mockReturnValue(
        createSessionExecMock(validUsers[0]),
      );

      const userPlans = [
        { _id: 'plan1', title: 'Plan 1', user: userId },
        { _id: 'plan2', title: 'Plan 2', user: userId },
      ];

      mockPlanModel.find.mockReturnValue(createSessionMock(userPlans));

      mockCommentModel.deleteMany.mockReturnValue({
        session: jest.fn().mockResolvedValue({ deletedCount: 5 }),
      });

      mockPlanModel.deleteMany.mockReturnValue({
        session: jest.fn().mockResolvedValue({ deletedCount: 2 }),
      });

      mockPlanModel.updateMany.mockReturnValue({
        session: jest.fn().mockResolvedValue({ modifiedCount: 3 }),
      });

      mockUserModel.updateMany
        .mockReturnValueOnce({
          session: jest.fn().mockResolvedValue({ modifiedCount: 1 }),
        })
        .mockReturnValueOnce({
          session: jest.fn().mockResolvedValue({ modifiedCount: 1 }),
        });

      mockUserModel.findByIdAndDelete.mockReturnValue(
        createSessionExecMock(validUsers[0]),
      );

      const result = await userService.removeById(userId);

      expect(result).toEqual(validUsers[0]);
      expect(mockSession.withTransaction).toHaveBeenCalled();
      expect(mockSession.endSession).toHaveBeenCalled();
    });

    it('should handle user not found during delete', async () => {
      const userId = '507f1f77bcf86cd799439999';
      const mockSession = {
        withTransaction: jest.fn().mockImplementation((callback) => callback()),
        endSession: jest.fn(),
      };

      mockConnection.startSession.mockResolvedValue(mockSession);

      mockUserModel.findById.mockReturnValue(createSessionExecMock(null));

      mockPlanModel.find.mockReturnValue(createSessionMock([]));

      await expect(userService.removeById(userId)).rejects.toThrow(
        NotFoundException,
      );
      expect(mockSession.endSession).toHaveBeenCalled();
    });
  });

  describe('user stats and data retrieval', () => {
    it('should get user favorites', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const testUser = {
        _id: userId,
        id: userId,
        username: 'testuser',
        email: 'test@example.com',
      };

      const favorites = [
        { _id: 'plan1', title: 'Plan 1' },
        { _id: 'plan2', title: 'Plan 2' },
      ];

      expect(userId).toBeDefined();

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(testUser),
      });

      mockPlanModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue(favorites),
        }),
        exec: jest.fn().mockResolvedValue(favorites),
        populate: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        session: jest.fn().mockReturnThis(),
        then: jest
          .fn()
          .mockImplementation((callback) =>
            Promise.resolve(callback(favorites)),
          ),
        catch: jest.fn().mockReturnThis(),
      });

      const result = await userService.getUserFavorites(userId);

      expect(result).toEqual(favorites);
      expect(mockUserModel.findById).toHaveBeenCalledWith(userId);
      expect(mockPlanModel.find).toHaveBeenCalledWith({ favorites: userId });
    });

    it('should get user followers', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const testUser = {
        _id: userId,
        username: 'testuser',
        email: 'test@example.com',
      };

      const followers = [
        { _id: 'user1', id: 'user1', username: 'follower1' },
        { _id: 'user2', id: 'user2', username: 'follower2' },
      ];

      mockUserModel.findById.mockReturnValue({
        populate: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue({ followers }),
        }),
        exec: jest.fn().mockResolvedValue(testUser),
      });

      const result = await userService.getUserFollowers(userId);

      expect(result).toEqual(followers);
    });

    it('should get user following', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const testUser = {
        _id: userId,
        username: 'testuser',
        email: 'test@example.com',
      };

      const following = [
        { _id: 'user1', id: userId, username: 'following1' },
        { _id: 'user2', id: userId, username: 'following2' },
      ];

      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(testUser),
      });

      mockUserModel.findById.mockReturnValue({
        populate: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue({ following }),
        }),
      });

      const result = await userService.getUserFollowing(userId);

      expect(result).toEqual(following);
    });

    it('should get user stats', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const user = {
        _id: userId,
        username: 'testuser',
        email: 'test@example.com',
        followers: ['user1', 'user2'],
        following: ['user3'],
      };

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(user),
      });

      mockPlanModel.countDocuments
        .mockResolvedValueOnce(5)
        .mockResolvedValueOnce(3);

      const result = await userService.getUserStats(userId);

      expect(result).toEqual({
        plansCount: 5,
        favoritesCount: 3,
        followersCount: 2,
        followingCount: 1,
      });
    });
  });

  // --- TESTS POUR CAS SPÉCIAUX ---
  describe('special cases', () => {
    it('should handle user with long description', async () => {
      const longDescUser = specialCases.userWithLongDescription;

      mockUserModel.mockImplementation(() => ({
        save: jest.fn().mockResolvedValue({
          _id: validUsers[0]._id,
          username: 'testuser',
          email: 'test@example.com',
          description: longDescUser.description,
          createdAt: new Date(),
          updatedAt: new Date(),
        }),
      }));

      jest.spyOn(userService as any, 'isPasswordSecure').mockReturnValue(true);

      const result = await userService.create({
        username: 'testuser',
        email: 'test@example.com',
        password: 'SecurePass123!',
        description: longDescUser.description,
      });

      expect(result.description).toBe(longDescUser.description);
      expect(result.description.length).toBeGreaterThan(100);
    });

    it('should handle user with many followers', async () => {
      const popularUser = specialCases.userWithManyFollowers;

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(popularUser),
      });

      const result = await userService.findById(popularUser._id);

      expect(result.followers).toHaveLength(5);
      expect(result.followers).toEqual(popularUser.followers);
    });

    it('should handle user without optional fields', async () => {
      const basicUser = specialCases.userWithoutOptionalFields;

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(basicUser),
      });

      const result = await userService.findById(basicUser._id);

      expect(result.description).toBeUndefined();
      expect(result.photoUrl).toBeUndefined();
      expect(result.birthDate).toBeUndefined();
      expect(result.followers).toEqual([]);
      expect(result.following).toEqual([]);
    });

    it('should check if password is secure', () => {
      // Test mots de passe sécurisés
      passwordOperations.securePasswords.forEach((password) => {
        const result = (userService as any).isPasswordSecure(password);
        expect(result).toBe(true);
      });

      // Test mots de passe faibles
      passwordOperations.weakPasswords.forEach((password) => {
        const result = (userService as any).isPasswordSecure(password);
        expect(result).toBe(false);
      });
    });
  });
});
