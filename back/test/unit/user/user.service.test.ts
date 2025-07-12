/* eslint-disable prettier/prettier */
import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { UserService } from '../../../src/user/user.service';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import * as userFixtures from '../../__fixtures__/users.json';

describe('UserService', () => {
  let userService: UserService;

  const {
    validUsers,
    createUserDtos,
    updateUserDtos,
    invalidData,
    followOperations,
    accountOperations,
    passwordOperations,
    specialCases
  } = userFixtures;

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

  mockUserModel.find = jest.fn().mockReturnValue({
    skip: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockUserModel.findOne = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockUserModel.findById = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockUserModel.findByIdAndUpdate = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockUserModel.findByIdAndDelete = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockUserModel.updateOne = jest.fn();
  mockUserModel.updateMany = jest.fn();

  mockUserModel.exists = jest.fn();
  mockUserModel.countDocuments = jest.fn();

  const mockPlanModel = {
    find: jest.fn(),
    countDocuments: jest.fn(),
    updateMany: jest.fn(),
    deleteMany: jest.fn(),
  };

  const mockConnection = {
    startSession: jest.fn().mockReturnValue({
      withTransaction: jest.fn().mockImplementation((callback) => callback()),
      endSession: jest.fn(),
    }),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    
    mockUserModel.findOne.mockReturnValue({
      exec: jest.fn(),
    });
    
    mockUserModel.findById.mockReturnValue({
      exec: jest.fn(),
    });
    
    mockUserModel.findByIdAndUpdate.mockReturnValue({
      exec: jest.fn(),
    });
    
    mockUserModel.findByIdAndDelete.mockReturnValue({
      exec: jest.fn(),
    });
    
    mockUserModel.find.mockReturnValue({
      skip: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      sort: jest.fn().mockReturnThis(),
      exec: jest.fn(),
    });

    const module: TestingModule = await Test.createTestingModule({
      providers:
      [
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
          provide: 'DatabaseConnection',
          useValue: mockConnection,
        },
      ],
    }).compile();

    userService = module.get<UserService>(UserService);
    
    jest.spyOn(bcrypt, 'hash').mockResolvedValue(passwordOperations.hashResults.hash as never);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(userService).toBeDefined();
  });

  describe('create', () => {
    beforeEach(() => {
      jest.spyOn(bcrypt, 'hash').mockResolvedValue(passwordOperations.hashResults.hash as never);
    });

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

      mockUserModel.findOne.mockResolvedValue(null);
      jest.spyOn(userService as any, 'isPasswordSecure').mockReturnValue(true);

      const result = await userService.create(createData);

      expect(result.username).toBe(createData.username);
      expect(result.email).toBe(createData.email);
      expect(result.description).toBeUndefined();
      expect(result.photoUrl).toBeUndefined();
      expect(result.birthDate).toBeUndefined();
    });

    it('should create premium user', async () => {
      const createData = createUserDtos.premiumCreate;

      mockUserModel.findOne.mockResolvedValue(null);
      jest.spyOn(userService as any, 'isPasswordSecure').mockReturnValue(true);

      const result = await userService.create(createData);

      expect(result.isPremium).toBe(createData.isPremium);
      expect(result.description).toBe(createData.description);
    });

    it('should create admin user', async () => {
      const createData = createUserDtos.adminCreate;

      mockUserModel.findOne.mockResolvedValue(null);
      jest.spyOn(userService as any, 'isPasswordSecure').mockReturnValue(true);

      const result = await userService.create(createData);

      expect(result.role).toBe(createData.role);
      expect(result.description).toBe(createData.description);
    });

    it('should throw error when email already exists', async () => {
      const createData = invalidData.duplicateEmail;

      const mongoError = new Error('Duplicate key error') as Error & { code: number; keyPattern?: any };
      (mongoError as typeof mongoError & { code: number }).code = 11000;
      mongoError.keyPattern = { email: 1 };
      const mockSave = jest.fn().mockRejectedValue(mongoError);
      mockUserModel.mockImplementation(() => ({
        save: mockSave,
      }));

      await expect(userService.create(createData)).rejects.toThrow(BadRequestException);
      await expect(userService.create(createData)).rejects.toThrow('Cet email est déjà utilisé');
    });

    it('should throw error when username already exists', async () => {
      const createData = invalidData.duplicateUsername;

      const mongoError = new Error('Duplicate key error') as Error & { code?: number; keyPattern?: any };
      mongoError.code = 11000;
      mongoError.keyPattern = { username: 1 };

      const mockSave = jest.fn().mockRejectedValue(mongoError);
      mockUserModel.mockImplementation(() => ({
        save: mockSave,
      }));

      await expect(userService.create(createData)).rejects.toThrow(BadRequestException);
      await expect(userService.create(createData)).rejects.toThrow("Ce nom d'utilisateur est déjà pris");
    });

    it('should throw error when password is not secure', async () => {
      const createData = invalidData.weakPassword;

      await expect(userService.create(createData)).rejects.toThrow(BadRequestException);
      await expect(userService.create(createData)).rejects.toThrow('Le mot de passe doit contenir au moins 8 caractères');
    });
  });

  describe('findOneByEmail', () => {
    it('should return user when found', async () => {
      const email = validUsers[0].email;
      const expectedUser = validUsers[0];

      mockUserModel.findOne.mockImplementation(() => ({
        exec: jest.fn().mockResolvedValue(expectedUser),
      }));

      const result = await userService.findOneByEmail(email);

      expect(result).toEqual(expectedUser);
      expect(mockUserModel.findOne).toHaveBeenCalledWith({ email });
    });

    it('should return null when user not found', async () => {
      const email = 'nonexistent@plany.com';

      mockUserModel.findOne.mockImplementation(() => ({
        exec: jest.fn().mockResolvedValue(null),
      }));

      const result = await userService.findOneByEmail(email);

      expect(result).toBeNull();
    });
  });

  describe('findById', () => {
    it('should return user when found', async () => {
      const userId = validUsers[0]._id;
      const expectedUser = validUsers[0];

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedUser),
      });

      const result = await userService.findById(userId);

      expect(result).toEqual(expectedUser);
      expect(mockUserModel.findById).toHaveBeenCalledWith(userId);
    });

    it('should return null when user not found', async () => {
      const userId = '507f1f77bcf86cd799439999';

      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await userService.findById(userId);

      expect(result).toBeNull();
    });
  });

  describe('findOneByUsername', () => {
    it('should return user when found', async () => {
      const username = validUsers[0].username;
      const expectedUser = validUsers[0];

      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedUser),
      });

      const result = await userService.findOneByUsername(username);

      expect(result).toEqual(expectedUser);
      expect(mockUserModel.findOne).toHaveBeenCalledWith({ username });
    });
  });

  describe('updateById', () => {
    it('should throw NotFoundException when user not found', async () => {
      const userId = '507f1f77bcf86cd799439999';
      const updateData = updateUserDtos.partialUpdate;

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(userService.updateById(userId, updateData))
        .rejects.toThrow(NotFoundException);
    });

    it('should update and return user when found', async () => {
      const userId = validUsers[0]._id;
      const updateData = updateUserDtos.partialUpdate;

      const updatedUser = {
        ...validUsers[0],
        ...updateData,
      };

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedUser),
      });

      const result = await userService.updateById(userId, updateData);

      expect(result).toEqual(updatedUser);
      expect(result.description).toBe(updateData.description);
    });
  });

  describe('followUser', () => {
    beforeEach(() => {
      jest.clearAllMocks();
    });

    it('should add user to following and follower lists', async () => {
      const userId = followOperations.beforeFollow._id;
      const targetUserId = followOperations.userToFollow._id;

      mockUserModel.exists
        .mockResolvedValueOnce({ _id: userId })
        .mockResolvedValueOnce({ _id: targetUserId });

      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      mockUserModel.updateOne.mockResolvedValue({ modifiedCount: 1 });

      const result = await userService.followUser(userId, targetUserId);

      expect(result.success).toBe(true);
      expect(mockUserModel.exists).toHaveBeenCalled();
      
      expect(mockUserModel.updateOne).toHaveBeenCalledTimes(2);
      
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: userId },
        { $addToSet: { following: targetUserId } }
      );
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: targetUserId },
        { $addToSet: { followers: userId } }
      );
    });
  });

  describe('unfollowUser', () => {
    it('should successfully unfollow a user', async () => {
      const userId = followOperations.afterFollow._id;
      const targetUserId = followOperations.userToFollow._id;

      mockUserModel.exists
        .mockResolvedValueOnce({ _id: userId })
        .mockResolvedValueOnce({ _id: targetUserId });

      mockUserModel.updateOne.mockResolvedValue({ modifiedCount: 1 });

      const result = await userService.unfollowUser(userId, targetUserId);

      expect(result.success).toBe(true);
      expect(mockUserModel.exists).toHaveBeenCalledTimes(2);
      expect(mockUserModel.updateOne).toHaveBeenCalledTimes(2);
    });

    it('should handle unfollow operation calls correctement', async () => {
      const userId = followOperations.afterFollow._id;
      const targetUserId = followOperations.userToFollow._id;

      mockUserModel.exists
        .mockResolvedValueOnce({ _id: userId })
        .mockResolvedValueOnce({ _id: targetUserId });

      mockUserModel.updateOne.mockResolvedValue({ modifiedCount: 1 });

      await userService.unfollowUser(userId, targetUserId);

      expect(mockUserModel.exists).toHaveBeenCalled();
      expect(mockUserModel.updateOne).toHaveBeenCalledTimes(2);
      
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: userId },
        { $pull: { following: targetUserId } }
      );
      expect(mockUserModel.updateOne).toHaveBeenCalledWith(
        { _id: targetUserId },
        { $pull: { followers: userId } }
      );
    });
  });

  describe('removeById', () => {
    it('should delete user and cleanup related data', async () => {
      const userId = validUsers[0]._id;
      const deletedUser = accountOperations.deletedUser;

      mockUserModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedUser),
      });

      mockPlanModel.updateMany.mockResolvedValue({ modifiedCount: 5 });
      mockPlanModel.deleteMany.mockResolvedValue({ deletedCount: 3 });

      const result = await userService.removeById(userId);

      expect(result).toEqual(deletedUser);
      expect(mockUserModel.findByIdAndDelete).toHaveBeenCalledWith(userId);
      
    });

    it('should return null when user not found', async () => {
      const userId = '507f1f77bcf86cd799439999';

      const mockSession = {
        withTransaction: jest.fn().mockImplementation((callback) => callback()),
        endSession: jest.fn(),
      };
      mockConnection.startSession.mockResolvedValue(mockSession);

      mockUserModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await userService.removeById(userId);

      expect(result).toBeNull();
    });
  });

  describe('isPasswordSecure', () => {
    it('should return true for secure passwords', () => {
      passwordOperations.securePasswords.forEach(password => {
        const result = (userService as any).isPasswordSecure(password);
        expect(result).toBe(true);
      });
    });

    it('should return false for weak passwords', () => {
      passwordOperations.weakPasswords.forEach(password => {
        const result = (userService as any).isPasswordSecure(password);
        expect(result).toBe(false);
      });
    });
  });

  describe('special cases', () => {
    it('should handle user with long description', async () => {
      const longDescUser = specialCases.userWithLongDescription;
      
      const mockSave = jest.fn().mockResolvedValue({
        _id: validUsers[0]._id,
        username: `unique_${Date.now()}`,
        email: `unique_${Date.now()}@example.com`,
        password: 'hashedPassword',
        description: longDescUser.description,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
      
      mockUserModel.mockImplementation(() => ({
        save: mockSave,
      }));
      
      const result = await userService.create({
        username: `unique_${Date.now()}`,
        email: `unique_${Date.now()}@example.com`,
        password: 'SecurePass123!',
        description: longDescUser.description
      });

      expect(result.description).toBe(longDescUser.description);
      expect(result.description.length).toBeGreaterThan(100);
    });

    it('should handle user with long description - property test', () => {
      const longDescUser = specialCases.userWithLongDescription;
      
      expect(longDescUser.description).toBeDefined();
      expect(longDescUser.description.length).toBeGreaterThan(100);
      expect(typeof longDescUser.description).toBe('string');
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
      expect(result.gender).toBeUndefined();
      expect(result.followers).toEqual([]);
      expect(result.following).toEqual([]);
    });
  });


  describe('findAll', () => {
    it('should return all active users', async () => {
      const activeUsers = validUsers.filter(user => user.isActive);

      mockUserModel.find.mockReturnValue({
        skip: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(activeUsers),
      });

      const result = await userService.findAll();

      expect(result).toEqual(activeUsers);
      expect(mockUserModel.find).toHaveBeenCalled();
    });
  });
});
