import { Test, TestingModule } from '@nestjs/testing';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { PasswordService } from '../auth/password.service';
import { PlanService } from '../plan/plan.service';
import { AuthService } from '../auth/auth.service';
import {
  NotFoundException,
  UnauthorizedException,
  InternalServerErrorException,
  BadRequestException,
} from '@nestjs/common';

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
};

describe('UsersController', () => {
  let controller: UserController;

  beforeEach(async () => {
    jest.spyOn(console, 'error').mockImplementation(() => {});
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserController],
      providers: [
        { provide: UserService, useValue: mockUserService },
        { provide: PlanService, useValue: mockPlanService },
        { provide: AuthService, useValue: mockAuthService },
        { provide: PasswordService, useValue: {} },
      ],
    }).compile();

    controller = module.get<UserController>(UserController);
    jest.clearAllMocks();
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all users', async () => {
      mockUserService.findAll.mockResolvedValue(['user1', 'user2']);
      expect(await controller.findAll()).toEqual(['user1', 'user2']);
    });
  });

  describe('findOne', () => {
    it('should return user by id', async () => {
      mockUserService.findById.mockResolvedValue({ _id: '123' });
      const req = { user: { _id: '123' } };
      expect(await controller.findOne('123', req)).toEqual({ _id: '123' });
    });
    it('should throw NotFoundException if user not found', async () => {
      mockUserService.findById.mockResolvedValue(null);
      const req = { user: { _id: '123' } };
      await expect(controller.findOne('123', req)).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('create', () => {
    it('should create a user', async () => {
      mockUserService.create.mockResolvedValue({ _id: '1' });
      expect(
        await controller.create({
          email: 'a',
          password: 'b',
          username: 'c',
        }),
      ).toEqual({
        _id: '1',
      });
    });
    it('should throw InternalServerErrorException on error', async () => {
      mockUserService.create.mockRejectedValue(new Error('fail'));
      await expect(
        controller.create({
          email: 'a',
          password: 'b',
          username: 'c',
        }),
      ).rejects.toThrow(InternalServerErrorException);
    });
    it('should throw BadRequestException if error is BadRequestException', async () => {
      mockUserService.create.mockRejectedValue(new BadRequestException());
      await expect(
        controller.create({
          username: 'c',
          email: 'a',
          password: 'b',
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('updateProfile', () => {
    it('should update user profile', async () => {
      mockUserService.updateById.mockResolvedValue({
        _id: '1',
        username: 'testuser',
      });
      const req = { user: { _id: '1' } };
      expect(
        await controller.updateProfile('1', { username: 'testuser' }, req),
      ).toEqual({ _id: '1', username: 'testuser' });
    });
    it('should throw UnauthorizedException if user tries to update another profile', () => {
      const req = { user: { _id: '1' } };
      expect(() =>
        controller.updateProfile('2', { username: 'test' }, req),
      ).toThrow(UnauthorizedException);
    });
  });

  describe('removeById', () => {
    it('should remove user', async () => {
      mockUserService.removeById.mockResolvedValue({ _id: '1' });
      const req = { user: { _id: '1' } };
      expect(await controller.removeById('1', req)).toEqual({ _id: '1' });
    });
    it('should throw UnauthorizedException if user tries to delete another account', () => {
      const req = { user: { _id: '1' } };
      expect(() => controller.removeById('2', req)).toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('findOneByUsername', () => {
    it('should return user by username', async () => {
      mockUserService.findOneByUsername.mockResolvedValue({ username: 'bob' });
      expect(await controller.findOneByUsername('bob')).toEqual({
        username: 'bob',
      });
    });
  });

  describe('findOneByEmail', () => {
    it('should return user by email', async () => {
      mockUserService.findOneByEmail.mockResolvedValue({ email: 'bob@a.com' });
      expect(await controller.findOneByEmail('bob@a.com')).toEqual({
        email: 'bob@a.com',
      });
    });
  });

  describe('updateEmail', () => {
    it('should update email if password is correct', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockAuthService.validateUser.mockResolvedValue({ _id: '1' });
      mockUserService.updateById.mockResolvedValue({ email: 'new@a.com' });
      const req = { user: { _id: '1', email: 'old@a.com' } };
      expect(await controller.updateEmail('1', 'new@a.com', 'pw', req)).toEqual(
        { email: 'new@a.com' },
      );
    });
    it('should throw UnauthorizedException if email already used', async () => {
      mockUserService.findOneByEmail.mockResolvedValue({ _id: '2' });
      const req = { user: { _id: '1', email: 'old@a.com' } };
      await expect(
        controller.updateEmail('1', 'new@a.com', 'pw', req),
      ).rejects.toThrow(UnauthorizedException);
    });
    it('should throw UnauthorizedException if password is wrong', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockAuthService.validateUser.mockResolvedValue(null);
      const req = { user: { _id: '1', email: 'old@a.com' } };
      await expect(
        controller.updateEmail('1', 'new@a.com', 'pw', req),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('updateUserPhoto', () => {
    it('should update user photo', async () => {
      mockUserService.updateById.mockResolvedValue({ photoUrl: 'url' });
      const req = { user: { _id: '1' } };
      expect(await controller.updateUserPhoto('1', 'url', req)).toEqual({
        photoUrl: 'url',
      });
    });
    it('should throw UnauthorizedException if not owner', () => {
      const req = { user: { _id: '1' } };
      expect(() => controller.updateUserPhoto('2', 'url', req)).toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('deleteUserPhoto', () => {
    it('should delete user photo', async () => {
      mockUserService.updateById.mockResolvedValue({ photoUrl: null });
      const req = { user: { _id: '1' } };
      expect(await controller.deleteUserPhoto('1', req)).toEqual({
        photoUrl: null,
      });
    });
    it('should throw UnauthorizedException if not owner', () => {
      const req = { user: { _id: '1' } };
      expect(() => controller.deleteUserPhoto('2', req)).toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('getUserStats', () => {
    it('should return user stats', async () => {
      mockUserService.getUserStats.mockResolvedValue({ plans: 2 });
      const req = { user: { _id: '1' } };
      expect(await controller.getUserStats('1', req)).toEqual({ plans: 2 });
    });
  });

  describe('getUserPlans', () => {
    it('should return user plans', async () => {
      mockPlanService.findAllByUserId.mockResolvedValue(['plan1']);
      const req = { user: { _id: '1' } };
      expect(await controller.getUserPlans('1', req)).toEqual(['plan1']);
    });
  });

  describe('getUserFavorites', () => {
    it('should return user favorites', async () => {
      mockPlanService.findFavoritesByUserId.mockResolvedValue(['fav1']);
      const req = { user: { _id: '1' } };
      expect(await controller.getUserFavorites('1', req)).toEqual(['fav1']);
    });
  });

  describe('updatePremiumStatus', () => {
    it('should update premium status if owner', async () => {
      mockUserService.updateById.mockResolvedValue({ isPremium: true });
      const req = { user: { _id: '1', role: 'user' } };
      expect(await controller.updatePremiumStatus('1', true, req)).toEqual({
        isPremium: true,
      });
    });
    it('should update premium status if admin', async () => {
      mockUserService.updateById.mockResolvedValue({ isPremium: true });
      const req = { user: { _id: '2', role: 'admin' } };
      expect(await controller.updatePremiumStatus('1', true, req)).toEqual({
        isPremium: true,
      });
    });
    it('should throw UnauthorizedException if not owner or admin', async () => {
      const req = { user: { _id: '2', role: 'user' } };
      await expect(
        controller.updatePremiumStatus('1', true, req),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('followUser', () => {
    it('should follow user', async () => {
      mockUserService.followUser.mockResolvedValue({ followed: true });
      const req = { user: { _id: '1' } };
      expect(await controller.followUser('2', req)).toEqual({ followed: true });
    });
    it('should throw UnauthorizedException if not authenticated', async () => {
      await expect(controller.followUser('2', {} as any)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('unfollowUser', () => {
    it('should unfollow user', async () => {
      mockUserService.unfollowUser.mockResolvedValue({ unfollowed: true });
      const req = { user: { _id: '1' } };
      expect(await controller.unfollowUser('2', req)).toEqual({
        unfollowed: true,
      });
    });
    it('should throw UnauthorizedException if not authenticated', async () => {
      await expect(controller.unfollowUser('2', {} as any)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('getUserFollowers', () => {
    it('should return followers', async () => {
      mockUserService.getUserFollowers.mockResolvedValue(['f1']);
      const req = { user: { _id: '1' } };
      expect(await controller.getUserFollowers('1', req)).toEqual(['f1']);
    });
  });

  describe('getUserFollowing', () => {
    it('should return following', async () => {
      mockUserService.getUserFollowing.mockResolvedValue(['f2']);
      const req = { user: { _id: '1' } };
      expect(await controller.getUserFollowing('1', req)).toEqual(['f2']);
    });
  });

  describe('checkFollowing', () => {
    it('should return isFollowing', async () => {
      mockUserService.isFollowing.mockResolvedValue(true);
      const req = { user: { _id: '1' } };
      expect(await controller.checkFollowing('1', '2', req)).toEqual({
        isFollowing: true,
      });
    });
  });

  describe('explicitFollowUser', () => {
    it('should follow user explicitly', async () => {
      mockUserService.followUser.mockResolvedValue({ followed: true });
      const req = { user: { _id: '1' } };
      expect(await controller.explicitFollowUser('1', '2', req)).toEqual({
        followed: true,
      });
    });
  });

  describe('explicitUnfollowUser', () => {
    it('should unfollow user explicitly', async () => {
      mockUserService.unfollowUser.mockResolvedValue({ unfollowed: true });
      const req = { user: { _id: '1' } };
      expect(await controller.explicitUnfollowUser('1', '2', req)).toEqual({
        unfollowed: true,
      });
    });
  });
});
