import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from '../../../src/auth/auth.service';
import { UserService } from '../../../src/user/user.service';
import { JwtService } from '@nestjs/jwt';
import { PasswordService } from '../../../src/auth/password.service';
import { TokenService } from '../../../src/auth/token.service';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';
import * as authFixtures from '../../__fixtures__/auth.json';

describe('AuthService', () => {
  let authService: AuthService;
  let userService: UserService;
  let passwordService: PasswordService;

  const {
    validUsers,
    loginDtos,
    registerDtos,
    jwtTokens,
    passwordOperations,
    errorMessages,
  } = authFixtures;

  const mockUserService = {
    findOneByEmail: jest.fn(),
    findOneByUsername: jest.fn(),
    create: jest.fn(),
    findById: jest.fn(),
  };

  const mockJwtService = {
    sign: jest.fn(() => jwtTokens.validToken),
  };

  const mockPasswordService = {
    hashPassword: jest.fn(() =>
      Promise.resolve(passwordOperations.hashedPasswords[0]),
    ),
    verifyPassword: jest.fn(() => Promise.resolve(true)),
    verifyLegacyPassword: jest.fn(() => Promise.resolve(false)),
  };

  const mockTokenService = {
    signAccess: jest.fn(() => jwtTokens.validToken),
    signRefresh: jest.fn(() => Promise.resolve('refresh_token_mock')),
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
        { provide: JwtService, useValue: mockJwtService },
        { provide: PasswordService, useValue: mockPasswordService },
        { provide: TokenService, useValue: mockTokenService },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
    userService = module.get<UserService>(UserService);
    passwordService = module.get<PasswordService>(PasswordService);
  });

  it('should be defined', () => {
    expect(authService).toBeDefined();
  });

  describe('validateUser', () => {
    it('should return user data when credentials are valid', async () => {
      const loginData = loginDtos.validLogin;
      const user = validUsers[0];

      const mockUser = {
        ...user,
        toObject: () => ({
          _id: user._id,
          email: user.email,
          username: user.username,
          description: user.description,
          isPremium: user.isPremium,
          photoUrl: user.photoUrl,
          birthDate: user.birthDate,
          gender: user.gender,
          followers: user.followers,
          following: user.following,
          createdAt: user.createdAt,
          role: user.role,
          updatedAt: user.updatedAt,
          password: user.password,
        }),
      };

      mockUserService.findOneByEmail.mockResolvedValue(mockUser);
      mockPasswordService.verifyPassword.mockResolvedValue(true);

      const result = await authService.validateUser(
        loginData.email,
        loginData.password,
      );

      expect(result).toEqual(
        expect.objectContaining({
          _id: user._id,
          email: user.email,
          username: user.username,
          description: user.description,
          isPremium: user.isPremium,
          photoUrl: user.photoUrl,
          birthDate: user.birthDate,
          gender: user.gender,
          role: user.role,
          password: user.password,
        }),
      );

      expect(userService.findOneByEmail).toHaveBeenCalledWith(loginData.email);
      expect(passwordService.verifyPassword).toHaveBeenCalledWith(
        loginData.password,
        user.password,
      );
    });

    it('should return null when user not found', async () => {
      const loginData = loginDtos.invalidEmail;

      mockUserService.findOneByEmail.mockResolvedValue(null);

      const result = await authService.validateUser(
        loginData.email,
        loginData.password,
      );

      expect(result).toBeNull();
      expect(userService.findOneByEmail).toHaveBeenCalledWith(loginData.email);
      expect(passwordService.verifyPassword).not.toHaveBeenCalled();
    });

    it('should return null when password is invalid', async () => {
      const loginData = loginDtos.invalidPassword;
      const user = validUsers[0];

      mockUserService.findOneByEmail.mockResolvedValue(user);
      mockPasswordService.verifyPassword.mockResolvedValue(false);
      mockPasswordService.verifyLegacyPassword.mockResolvedValue(false);

      const result = await authService.validateUser(
        loginData.email,
        loginData.password,
      );

      expect(result).toBeNull();
      expect(passwordService.verifyPassword).toHaveBeenCalledWith(
        loginData.password,
        user.password,
      );
    });
  });

  describe('login', () => {
    it('should return token and user data when credentials are valid', async () => {
      const loginData = loginDtos.validLogin;
      const user = validUsers[0];

      mockUserService.findOneByEmail.mockResolvedValue({
        ...user,
        toObject: () => ({
          _id: user._id,
          email: user.email,
          username: user.username,
          isPremium: user.isPremium,
          description: user.description,
          photoUrl: user.photoUrl,
          birthDate: user.birthDate,
          gender: user.gender,
          followers: user.followers,
          following: user.following,
          createdAt: user.createdAt,
          role: user.role,
          updatedAt: user.updatedAt,
        }),
      });
      mockPasswordService.verifyPassword.mockResolvedValue(true);

      const result = await authService.login(loginData);

      expect(result.accessToken).toBe(jwtTokens.validToken);
      expect(result.currentUser._id).toBe(user._id);
      expect(result.currentUser.email).toBe(user.email);
      expect(result.currentUser.username).toBe(user.username);
      expect(result.currentUser.isPremium).toBe(user.isPremium);
    });

    it('should throw UnauthorizedException when credentials are invalid', async () => {
      const loginData = loginDtos.invalidEmail;

      mockUserService.findOneByEmail.mockResolvedValue(null);

      await expect(authService.login(loginData)).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(authService.login(loginData)).rejects.toThrow(
        errorMessages.invalidCredentials,
      );
    });
  });

  describe('register', () => {
    it('should create user and return token when data is valid', async () => {
      const registerData = registerDtos.validRegister;
      const hashedPassword = passwordOperations.hashedPasswords[0];

      const newUser = {
        _id: '507f1f77bcf86cd799439013',
        ...registerData,
        password: hashedPassword,
        isPremium: false,
        description: null,
        photoUrl: null,
        birthDate: null,
        gender: null,
        followers: [],
        following: [],
        toObject: () => ({
          _id: '507f1f77bcf86cd799439013',
          email: registerData.email,
          username: registerData.username,
          isPremium: false,
          description: null,
          photoUrl: null,
          birthDate: null,
          gender: null,
          followers: [],
          following: [],
          role: 'user',
          createdAt: new Date(),
          updatedAt: new Date(),
        }),
      };

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockUserService.findOneByUsername.mockResolvedValue(null);
      mockPasswordService.hashPassword.mockResolvedValue(hashedPassword);
      mockUserService.create.mockResolvedValue(newUser);

      const result = await authService.register(registerData);

      expect(result.accessToken).toBe(jwtTokens.validToken);
      expect(result.currentUser.email).toBe(registerData.email);
      expect(result.currentUser.username).toBe(registerData.username);
      expect(passwordService.hashPassword).toHaveBeenCalledWith(
        registerData.password,
      );
      expect(userService.create).toHaveBeenCalledWith({
        ...registerData,
        password: hashedPassword,
      });
    });

    it('should throw error when email already exists', async () => {
      const registerData = registerDtos.duplicateEmail;
      const existingUser = validUsers[0];

      mockUserService.findOneByEmail.mockResolvedValue(existingUser);

      await expect(authService.register(registerData)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authService.register(registerData)).rejects.toThrow(
        errorMessages.emailAlreadyExists,
      );
    });

    it('should throw error when username already exists', async () => {
      const registerData = registerDtos.duplicateUsername;
      const existingUser = validUsers[0];

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockUserService.findOneByUsername.mockResolvedValue(existingUser);

      await expect(authService.register(registerData)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authService.register(registerData)).rejects.toThrow(
        errorMessages.usernameAlreadyExists,
      );
    });

    it('should handle MongoDB duplicate key error', async () => {
      const registerData = registerDtos.validRegister;
      const hashedPassword = passwordOperations.hashedPasswords[0];

      mockUserService.findOneByEmail.mockResolvedValue(null);
      mockUserService.findOneByUsername.mockResolvedValue(null);
      mockPasswordService.hashPassword.mockResolvedValue(hashedPassword);

      const createError = new Error('Database error');
      mockUserService.create.mockRejectedValue(createError);

      await expect(authService.register(registerData)).rejects.toThrow(Error);
    });
  });
});
