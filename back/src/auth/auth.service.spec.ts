import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UserService } from '../user/user.service';
import { JwtService } from '@nestjs/jwt';
import { PasswordService } from './password.service';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';

describe('AuthService', () => {
  let authService: AuthService;
  let userService: UserService;
  let jwtService: JwtService;
  let passwordService: PasswordService;

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
      return {
        _id: this._id,
        email: this.email,
        username: this.username,
        isPremium: this.isPremium,
        followers: this.followers,
        following: this.following,
      };
    },
  };

  const mockUserService = {
    findOneByEmail: jest.fn(),
    findOneByUsername: jest.fn(),
    create: jest.fn(),
    findById: jest.fn(),
  };

  const mockJwtService = {
    sign: jest.fn(() => 'mock.jwt.token'),
  };

  const mockPasswordService = {
    hashPassword: jest.fn(() => Promise.resolve('hashedPassword')),
    verifyPassword: jest.fn(() => Promise.resolve(true)),
    verifyLegacyPassword: jest.fn(() => Promise.resolve(false)),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UserService, useValue: mockUserService },
        { provide: JwtService, useValue: mockJwtService },
        { provide: PasswordService, useValue: mockPasswordService },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
    userService = module.get<UserService>(UserService);
    jwtService = module.get<JwtService>(JwtService);
    passwordService = module.get<PasswordService>(PasswordService);
  });

  it('should be defined', () => {
    expect(authService).toBeDefined();
  });

  describe('login', () => {
    it('should return token and user data when credentials are valid', async () => {
      const loginDto = {
        email: 'john@plany.com',
        password: 'SecurePass123!',
      };

      mockUserService.findOneByEmail.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(true);

      const result = await authService.login(loginDto);

      expect(result.token).toBe('mock.jwt.token');
      expect(result.currentUser.id).toBe(mockUser._id);
      expect(result.currentUser.email).toBe(mockUser.email);
      expect(result.currentUser.username).toBe(mockUser.username);
      expect(userService.findOneByEmail).toHaveBeenCalledWith(loginDto.email);
      expect(passwordService.verifyPassword).toHaveBeenCalledWith(
        loginDto.password,
        mockUser.password,
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
      mockPasswordService.verifyLegacyPassword.mockResolvedValue(false);

      await expect(authService.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('register', () => {
    it('should create user and return token when data is valid', async () => {
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
      };

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockUserService.findOneByUsername.mockResolvedValue(null);
      mockPasswordService.hashPassword.mockResolvedValue('hashedPassword');
      mockUserService.create.mockResolvedValue(newUser);

      const result = await authService.register(registerDto);

      expect(result.token).toBe('mock.jwt.token');
      expect(result.currentUser.email).toBe(registerDto.email);
      expect(result.currentUser.username).toBe(registerDto.username);
      expect(passwordService.hashPassword).toHaveBeenCalledWith(
        registerDto.password,
      );
      expect(userService.create).toHaveBeenCalledWith({
        ...registerDto,
        password: 'hashedPassword',
        isActive: true,
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

  describe('refreshToken', () => {
    it('should return new token when user exists', async () => {
      const userId = mockUser._id;

      mockUserService.findById.mockResolvedValue(mockUser);

      const result = await authService.refreshToken(userId);

      expect(result.token).toBe('mock.jwt.token');
      expect(userService.findById).toHaveBeenCalledWith(userId);
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: mockUser._id,
        email: mockUser.email,
        username: mockUser.username,
      });
    });

    it('should throw UnauthorizedException when user not found', async () => {
      const userId = 'nonexistent';

      mockUserService.findById.mockResolvedValue(null);

      await expect(authService.refreshToken(userId)).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(authService.refreshToken(userId)).rejects.toThrow(
        'Utilisateur non trouvé',
      );
    });
  });
});
