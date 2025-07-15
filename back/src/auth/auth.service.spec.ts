import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UserService } from '../user/user.service';
import { PasswordService } from './password.service';
import { TokenService } from './token.service';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';

describe('AuthService', () => {
  let authService: AuthService;
  let userService: UserService;
  let passwordService: PasswordService;
  let tokenService: TokenService;

  const mockUser = {
    _id: '507f1f77bcf86cd799439011',
    username: 'johndoe',
    email: 'john@plany.com',
    password: '$argon2id$v=19$m=65536,t=3,p=4$hashedPassword123',
    isActive: true,
    isPremium: false,
    role: 'user',
    followers: [],
    following: [],
    toObject: function () {
      const { password, __v, ...rest } = this;
      return rest;
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
    hashPassword: jest.fn(),
    verifyPassword: jest.fn(),
    verifyLegacyPassword: jest.fn(),
  };

  const mockTokenService = {
    signAccess: jest.fn(() => 'mock.access.token'),
    signRefresh: jest.fn(() => Promise.resolve('mock.refresh.token')),
    verifyRefresh: jest.fn(),
    revokeFromJwt: jest.fn(),
    revokeAllForUser: jest.fn(),
  };

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

    authService = module.get<AuthService>(AuthService);
    userService = module.get<UserService>(UserService);
    passwordService = module.get<PasswordService>(PasswordService);
    tokenService = module.get<TokenService>(TokenService);
  });

  it('should be defined', () => {
    expect(authService).toBeDefined();
  });

  describe('validateUser', () => {
    it('should return user when credentials are valid', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(true);

      const result = await authService.validateUser(
        'john@plany.com',
        'password',
      );

      expect(result).toEqual(mockUser);
      expect(userService.findOneByEmail).toHaveBeenCalledWith('john@plany.com');
      expect(passwordService.verifyPassword).toHaveBeenCalledWith(
        'password',
        mockUser.password,
      );
    });

    it('should return null when user not found', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(null);

      const result = await authService.validateUser(
        'nonexistent@plany.com',
        'password',
      );

      expect(result).toBeNull();
    });

    it('should return null when password is invalid', async () => {
      mockUserService.findOneByEmail.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(false);

      const result = await authService.validateUser(
        'john@plany.com',
        'wrongpassword',
      );

      expect(result).toBeNull();
    });
  });

  describe('login', () => {
    it('should return access and refresh tokens when credentials are valid', async () => {
      const loginDto = {
        email: 'john@plany.com',
        password: 'SecurePass123!',
      };

      mockUserService.findOneByEmail.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(true);

      const result = await authService.login(loginDto);

      expect(result.accessToken).toBe('mock.access.token');
      expect(result.refreshToken).toBe('mock.refresh.token');
      expect(result.currentUser._id).toBe(mockUser._id);
      expect(result.currentUser.email).toBe(mockUser.email);
      expect(result.currentUser.username).toBe(mockUser.username);
      expect(result.currentUser.password).toBeUndefined();

      expect(tokenService.signAccess).toHaveBeenCalledWith({
        sub: mockUser._id.toString(),
        email: mockUser.email,
        username: mockUser.username,
      });
      expect(tokenService.signRefresh).toHaveBeenCalledWith(
        mockUser._id.toString(),
      );
    });

    it('should throw UnauthorizedException when user not found', async () => {
      const loginDto = {
        email: 'nonexistent@plany.com',
        password: 'SecurePass123!',
      };

      mockUserService.findOneByEmail.mockResolvedValue(null);

      await expect(authService.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(authService.login(loginDto)).rejects.toThrow(
        'Email ou mot de passe incorrect',
      );
    });

    it('should throw UnauthorizedException when password is invalid', async () => {
      const loginDto = {
        email: 'john@plany.com',
        password: 'WrongPassword',
      };

      mockUserService.findOneByEmail.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(false);

      await expect(authService.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('register', () => {
    it('should create user and return tokens when data is valid', async () => {
      const registerDto = {
        username: 'newuser',
        email: 'newuser@plany.com',
        password: 'NewUserPass123!',
      };

      const newUser = {
        _id: '507f1f77bcf86cd799439013',
        ...registerDto,
        password: 'hashedPassword',
        isActive: true,
        isPremium: false,
        followers: [],
        following: [],
        toObject: function () {
          const { password, __v, ...rest } = this;
          return rest;
        },
      };

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockUserService.findOneByUsername.mockResolvedValue(null);
      mockPasswordService.hashPassword.mockResolvedValue('hashedPassword');
      mockUserService.create.mockResolvedValue(newUser);

      const result = await authService.register(registerDto);

      expect(result.accessToken).toBe('mock.access.token');
      expect(result.refreshToken).toBe('mock.refresh.token');
      expect(result.currentUser.email).toBe(registerDto.email);
      expect(result.currentUser.username).toBe(registerDto.username);
      expect(result.currentUser.password).toBeUndefined();

      expect(passwordService.hashPassword).toHaveBeenCalledWith(
        registerDto.password,
      );
      expect(userService.create).toHaveBeenCalledWith({
        ...registerDto,
        password: 'hashedPassword',
      });
    });

    it('should throw error when email already exists', async () => {
      const registerDto = {
        username: 'uniqueuser',
        email: 'john@plany.com',
        password: 'ValidPass123!',
      };

      mockUserService.findOneByEmail.mockResolvedValue(mockUser);

      await expect(authService.register(registerDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authService.register(registerDto)).rejects.toThrow(
        'Cet email est déjà utilisé',
      );
    });

    it('should throw error when username already exists', async () => {
      const registerDto = {
        username: 'johndoe',
        email: 'unique@plany.com',
        password: 'ValidPass123!',
      };

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockUserService.findOneByUsername.mockResolvedValue(mockUser);

      await expect(authService.register(registerDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authService.register(registerDto)).rejects.toThrow(
        "Ce nom d'utilisateur est déjà pris",
      );
    });
  });

  describe('changePassword', () => {
    it('should change password successfully', async () => {
      const userId = mockUser._id;
      const currentPassword = 'CurrentPass123!';
      const newPassword = 'NewPass123!';

      mockUserService.findById.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(true);
      mockPasswordService.hashPassword.mockResolvedValue('newHashedPassword');

      await authService.changePassword(userId, currentPassword, newPassword);

      expect(userService.findById).toHaveBeenCalledWith(userId);
      expect(passwordService.verifyPassword).toHaveBeenCalledWith(
        currentPassword,
        mockUser.password,
      );
      expect(passwordService.hashPassword).toHaveBeenCalledWith(newPassword);
      expect(userService.updateById).toHaveBeenCalledWith(userId, {
        password: 'newHashedPassword',
      });
      expect(tokenService.revokeAllForUser).toHaveBeenCalledWith(userId);
    });

    it('should throw UnauthorizedException when user not found', async () => {
      mockUserService.findById.mockResolvedValue(null);

      await expect(
        authService.changePassword('nonexistent', 'current', 'new'),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException when current password is incorrect', async () => {
      mockUserService.findById.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(false);

      await expect(
        authService.changePassword(
          mockUser._id,
          'wrongpassword',
          'NewPass123!',
        ),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should throw BadRequestException when new password is weak', async () => {
      mockUserService.findById.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(true);

      await expect(
        authService.changePassword(mockUser._id, 'CurrentPass123!', 'weak'),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('refresh', () => {
    it('should return new tokens when refresh token is valid', async () => {
      const refreshToken = 'valid.refresh.token';
      const payload = { sub: mockUser._id };

      mockTokenService.verifyRefresh.mockResolvedValue(payload);
      mockUserService.findById.mockResolvedValue(mockUser);

      const result = await authService.refresh(refreshToken);

      expect(result.accessToken).toBe('mock.access.token');
      expect(result.refreshToken).toBe('mock.refresh.token');
      expect(tokenService.verifyRefresh).toHaveBeenCalledWith(refreshToken);
      expect(userService.findById).toHaveBeenCalledWith(payload.sub);
    });
  });

  describe('logout', () => {
    it('should revoke refresh token', async () => {
      const refreshToken = 'refresh.token.to.revoke';

      await authService.logout(refreshToken);

      expect(tokenService.revokeFromJwt).toHaveBeenCalledWith(refreshToken);
    });
  });
});
