import { Test, TestingModule } from '@nestjs/testing';
import { UserService } from './user.service';
import { PasswordService } from '../auth/password.service';
import { NotFoundException, BadRequestException } from '@nestjs/common';
 
const mockUserModel = {
  find: jest.fn(),
  findById: jest.fn(),
  findOne: jest.fn(),
  findByIdAndDelete: jest.fn(),
  findByIdAndUpdate: jest.fn(),
  updateMany: jest.fn(),
  updateOne: jest.fn(),
  exists: jest.fn(),
  deleteMany: jest.fn(),
};
const mockPlanModel = {
  find: jest.fn(),
  findOne: jest.fn(),
  findById: jest.fn(),
  deleteMany: jest.fn(),
  updateMany: jest.fn(),
  countDocuments: jest.fn(),
};
const mockCommentModel = {
  deleteMany: jest.fn(),
};
const mockDatabaseConnection = {
  startSession: jest.fn(),
};
const mockPasswordService = {
  hashPassword: jest.fn(),
};
 
describe('UserService', () => {
  let service: UserService;
 
  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        { provide: 'UserModel', useValue: mockUserModel },
        { provide: 'PlanModel', useValue: mockPlanModel },
        { provide: 'CommentModel', useValue: mockCommentModel },
        { provide: 'DatabaseConnection', useValue: mockDatabaseConnection },
        { provide: PasswordService, useValue: mockPasswordService },
      ],
    }).compile();
 
    service = module.get<UserService>(UserService);
  });
 
  it('should be defined', () => {
    expect(service).toBeDefined();
  });
 
  describe('create', () => {
    it('should throw if password is not secure', async () => {
      await expect(
        service.create({
          password: 'abc',
          email: 'a@a.fr',
          username: 'u',
        } as any),
      ).rejects.toThrow(BadRequestException);
    });
 
    it('should create user if password is secure', async () => {
      const dto = { password: 'Abcdefg1', email: 'a@a.fr', username: 'u' };
      const saveMock = jest.fn().mockResolvedValue({ ...dto, _id: 'id' });
      (mockUserModel as any).constructor = function (d: any) {
        return { ...d, save: saveMock };
      };
      jest.spyOn(service as any, 'isPasswordSecure').mockReturnValue(true);
      (service as any).userModel = function (d: any) {
        return { ...d, save: saveMock };
      };
      await expect(service.create(dto as any)).resolves.toHaveProperty('_id');
    });
 
    it('should throw BadRequestException on duplicate email', async () => {
      const dto = { password: 'Abcdefg1', email: 'a@a.fr', username: 'u' };
      jest.spyOn(service as any, 'isPasswordSecure').mockReturnValue(true);
      (service as any).userModel = function () {
        return {
          save: () => {
            throw { code: 11000, keyPattern: { email: 1 } };
          },
        };
      };
      await expect(service.create(dto as any)).rejects.toThrow(
        BadRequestException,
      );
    });
  });
 
  describe('findAll', () => {
    it('should return all users', async () => {
      mockUserModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue([1, 2]),
      });
      await expect(service.findAll()).resolves.toEqual([1, 2]);
    });
  });
 
  describe('findById', () => {
    it('should return null for invalid id', async () => {
      await expect(service.findById('badid')).resolves.toBeNull();
    });
    it('should return user for valid id', async () => {
      mockUserModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ _id: 'id' }),
      });
      await expect(
        service.findById('507f1f77bcf86cd799439011'),
      ).resolves.toHaveProperty('_id');
    });
  });
 
  describe('findOneByEmail', () => {
    it('should return user by email', async () => {
      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ email: 'a@a.fr' }),
      });
      await expect(service.findOneByEmail('a@a.fr')).resolves.toHaveProperty(
        'email',
      );
    });
  });
 
  describe('findOneByUsername', () => {
    it('should return user by username', async () => {
      mockUserModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ username: 'u' }),
      });
      await expect(service.findOneByUsername('u')).resolves.toHaveProperty(
        'username',
      );
    });
  });
 
  describe('updateById', () => {
    it('should update user and return updated', async () => {
      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ _id: 'id', username: 'u' }),
      });
      mockPasswordService.hashPassword.mockResolvedValue('hashed');
      await expect(
        service.updateById('id', { password: 'Abcdefg1' } as any),
      ).resolves.toHaveProperty('_id');
    });
    it('should throw NotFoundException if user not found', async () => {
      mockUserModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });
      await expect(service.updateById('id', {} as any)).rejects.toThrow(
        NotFoundException,
      );
    });
  });
 
  describe('getUserFavorites', () => {
    it('should throw NotFoundException if user not found', async () => {
      jest.spyOn(service, 'findById').mockResolvedValue(null);
      await expect(service.getUserFavorites('id')).rejects.toThrow(
        NotFoundException,
      );
    });
    it('should return favorites', async () => {
      jest.spyOn(service, 'findById').mockResolvedValue({ id: 'id' } as any);
      mockPlanModel.find.mockReturnValue({
        sort: jest
          .fn()
          .mockReturnValue({ exec: jest.fn().mockResolvedValue([1, 2]) }),
      });
      await expect(service.getUserFavorites('id')).resolves.toEqual([1, 2]);
    });
  });
 
  describe('followUser', () => {
    it('should throw NotFoundException if follower not found', async () => {
      mockUserModel.exists.mockResolvedValueOnce(false);
      await expect(service.followUser('f', 't')).rejects.toThrow(
        NotFoundException,
      );
    });
    it('should throw NotFoundException if target not found', async () => {
      mockUserModel.exists
        .mockResolvedValueOnce(true)
        .mockResolvedValueOnce(false);
      await expect(service.followUser('f', 't')).rejects.toThrow(
        NotFoundException,
      );
    });
    it('should return already following', async () => {
      mockUserModel.exists
        .mockResolvedValueOnce(true)
        .mockResolvedValueOnce(true)
        .mockResolvedValueOnce(true);
      await expect(service.followUser('f', 't')).resolves.toHaveProperty(
        'success',
        false,
      );
    });
    it('should follow user', async () => {
      mockUserModel.exists
        .mockResolvedValueOnce(true)
        .mockResolvedValueOnce(true)
        .mockResolvedValueOnce(false);
      mockUserModel.updateOne.mockResolvedValue({});
      await expect(service.followUser('f', 't')).resolves.toHaveProperty(
        'success',
        true,
      );
    });
  });
 
  describe('unfollowUser', () => {
    it('should throw NotFoundException if follower not found', async () => {
      mockUserModel.exists.mockResolvedValueOnce(false);
      await expect(service.unfollowUser('f', 't')).rejects.toThrow(
        NotFoundException,
      );
    });
    it('should throw NotFoundException if target not found', async () => {
      mockUserModel.exists
        .mockResolvedValueOnce(true)
        .mockResolvedValueOnce(false);
      await expect(service.unfollowUser('f', 't')).rejects.toThrow(
        NotFoundException,
      );
    });
    it('should unfollow user', async () => {
      mockUserModel.exists
        .mockResolvedValueOnce(true)
        .mockResolvedValueOnce(true);
      mockUserModel.updateOne.mockResolvedValue({});
      await expect(service.unfollowUser('f', 't')).resolves.toHaveProperty(
        'success',
        true,
      );
    });
  });
 
  describe('getUserStats', () => {
    it('should throw NotFoundException if user not found', async () => {
      jest.spyOn(service, 'findById').mockResolvedValue(null);
      await expect(service.getUserStats('id')).rejects.toThrow(
        NotFoundException,
      );
    });
    it('should return stats', async () => {
      const validId = '507f1f77bcf86cd799439011';
      jest.spyOn(service, 'findById').mockResolvedValue({
        _id: validId,
        followers: [1],
        following: [2],
      } as any);
      mockPlanModel.countDocuments.mockResolvedValue(2);
      await expect(service.getUserStats(validId)).resolves.toHaveProperty(
        'plansCount',
        2,
      );
    });
  });
});