import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UserService } from '../user/user.service';
import { PasswordService } from './password.service';
import { TokenService } from './token.service';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';

const mockUser = {
  _id: '507f1f77bcf86cd799439011',
  email: 'a@a.fr',
  username: 'user',
  password: 'hashed',
  toObject: function () {
    return { _id: this._id, email: this.email, username: this.username };
  },
};

const mockUserService = {
  findOneByEmail: jest.fn(),
  findOneByUsername: jest.fn(),
  create: jest.fn(),
  findById: jest.fn(),
  updateById: jest.fn(),
};
const mockPasswordService = {
  verifyPassword: jest.fn(),
  hashPassword: jest.fn(),
};
const mockTokenService = {
  signAccess: jest.fn(),
  signRefresh: jest.fn(),
  verifyRefresh: jest.fn(),
  revokeFromJwt: jest.fn(),
  revokeAllForUser: jest.fn(),
};

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UserService, useValue: mockUserService },
        { provide: PasswordService, useValue: mockPasswordService },
        { provide: TokenService, useValue: mockTokenService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('validateUser', () => {
    it('should return user if password is valid', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(true);
      await expect(service['validateUser']('a@a.fr', 'pass')).resolves.toEqual(
        mockUser,
      );
    });
    it('should return null if user not found', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(null);
      await expect(
        service['validateUser']('a@a.fr', 'pass'),
      ).resolves.toBeNull();
    });
    it('should return null if password is invalid', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(false);
      await expect(
        service['validateUser']('a@a.fr', 'pass'),
      ).resolves.toBeNull();
    });
  });

  describe('login', () => {
    it('should throw UnauthorizedException if user not found or password invalid', async () => {
      jest.spyOn(service as any, 'validateUser').mockResolvedValue(null);
      await expect(
        service.login({ email: 'a@a.fr', password: 'x' }),
      ).rejects.toThrow(UnauthorizedException);
    });
    it('should return tokens and user', async () => {
      jest.spyOn(service as any, 'validateUser').mockResolvedValue(mockUser);
      mockTokenService.signAccess.mockReturnValue('access');
      mockTokenService.signRefresh.mockResolvedValue('refresh');
      const res = await service.login({ email: 'a@a.fr', password: 'x' });
      expect(res).toHaveProperty('accessToken', 'access');
      expect(res).toHaveProperty('refreshToken', 'refresh');
      expect(res).toHaveProperty('currentUser');
    });
  });

  describe('register', () => {
    it('should throw if email exists', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(mockUser);
      await expect(
        service.register({ email: 'a@a.fr', password: 'x', username: 'u' }),
      ).rejects.toThrow(BadRequestException);
    });
    it('should throw if username exists', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockUserService.findOneByUsername.mockResolvedValue(mockUser);
      await expect(
        service.register({ email: 'a@a.fr', password: 'x', username: 'u' }),
      ).rejects.toThrow(BadRequestException);
    });
    it('should create user, hash password, and return tokens', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockUserService.findOneByUsername.mockResolvedValue(null);
      mockPasswordService.hashPassword.mockResolvedValue('hashed');
      mockUserService.create.mockResolvedValue(mockUser);
      mockTokenService.signAccess.mockReturnValue('access');
      mockTokenService.signRefresh.mockResolvedValue('refresh');
      const res = await service.register({
        email: 'a@a.fr',
        password: 'x',
        username: 'u',
      });
      expect(res).toHaveProperty('accessToken', 'access');
      expect(res).toHaveProperty('refreshToken', 'refresh');
      expect(res).toHaveProperty('currentUser');
    });
  });

  describe('changePassword', () => {
    it('should throw if user not found', async () => {
      mockUserService.findById.mockResolvedValue(null);
      await expect(service.changePassword('id', 'a', 'b')).rejects.toThrow(
        UnauthorizedException,
      );
    });
    it('should throw if current password is invalid', async () => {
      mockUserService.findById.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(false);
      await expect(service.changePassword('id', 'a', 'b')).rejects.toThrow(
        UnauthorizedException,
      );
    });
    it('should throw if new password is weak', async () => {
      mockUserService.findById.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(true);
      await expect(service.changePassword('id', 'a', 'short')).rejects.toThrow(
        BadRequestException,
      );
    });
    it('should update password and revoke tokens', async () => {
      mockUserService.findById.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(true);
      mockPasswordService.hashPassword.mockResolvedValue('hashed2');
      mockUserService.updateById.mockResolvedValue({
        ...mockUser,
        password: 'hashed2',
      });
      mockTokenService.revokeAllForUser.mockResolvedValue(undefined);
      await expect(
        service.changePassword('id', 'a', 'Abcdefg1'),
      ).resolves.toBeUndefined();
      expect(mockUserService.updateById).toHaveBeenCalledWith('id', {
        password: 'hashed2',
      });
      expect(mockTokenService.revokeAllForUser).toHaveBeenCalledWith('id');
    });
  });

  describe('refresh', () => {
    it('should return new tokens', async () => {
      mockTokenService.verifyRefresh.mockResolvedValue({ sub: mockUser._id });
      mockUserService.findById.mockResolvedValue(mockUser);
      mockTokenService.signAccess.mockReturnValue('access');
      mockTokenService.signRefresh.mockResolvedValue('refresh');
      const res = await service.refresh('rt');
      expect(res).toHaveProperty('accessToken', 'access');
      expect(res).toHaveProperty('refreshToken', 'refresh');
    });
  });

  describe('logout', () => {
    it('should call revokeFromJwt', async () => {
      mockTokenService.revokeFromJwt.mockResolvedValue(undefined);
      await expect(service.logout('rt')).resolves.toBeUndefined();
      expect(mockTokenService.revokeFromJwt).toHaveBeenCalledWith('rt');
    });
  });
});
