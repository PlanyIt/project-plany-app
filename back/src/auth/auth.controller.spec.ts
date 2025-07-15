/* eslint-disable prettier/prettier */
import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

describe('AuthController', () => {
  let authController: AuthController;
  let authService: AuthService;

  const validLoginDto: LoginDto = {
    email: 'john@plany.com',
    password: 'SecurePass123!',
  };

  const validRegisterDto: RegisterDto = {
    username: 'johndoe',
    email: 'john@plany.com',
    password: 'SecurePass123!',
  };

  const mockAuthResponse = {
    access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    user: {
      _id: '507f1f77bcf86cd799439011',
      username: 'johndoe',
      email: 'john@plany.com',
      description: 'Développeur passionné',
      isPremium: false,
      photoUrl: 'https://example.com/john.jpg',
      birthDate: new Date('1990-05-15T00:00:00.000Z'),
      gender: 'male',
      role: 'user',
      isActive: true,
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
  };

  const mockAuthService = {
    login: jest.fn(),
    register: jest.fn(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: mockAuthService,
        },
      ],
    }).compile();

    authController = module.get<AuthController>(AuthController);
    authService = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(authController).toBeDefined();
    expect(authService).toBeDefined();
  });

  describe('login', () => {
    it('should login user successfully and return access token', async () => {
      mockAuthService.login.mockResolvedValue(mockAuthResponse);

      const result = await authController.login(validLoginDto);

      expect(result).toEqual(mockAuthResponse);
      expect(mockAuthService.login).toHaveBeenCalledWith(validLoginDto);
      expect(mockAuthService.login).toHaveBeenCalledTimes(1);
    });

    it('should throw BadRequestException for invalid credentials', async () => {
      const invalidCredentialsError = new BadRequestException(
        'Email ou mot de passe incorrect',
      );
      mockAuthService.login.mockRejectedValue(invalidCredentialsError);

      await expect(authController.login(validLoginDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authController.login(validLoginDto)).rejects.toThrow(
        'Email ou mot de passe incorrect',
      );
      expect(mockAuthService.login).toHaveBeenCalledWith(validLoginDto);
    });

    it('should throw HttpException for unexpected service errors', async () => {
      const unexpectedError = new Error('Database connection failed');
      mockAuthService.login.mockRejectedValue(unexpectedError);

      await expect(authController.login(validLoginDto)).rejects.toThrow(
        HttpException,
      );
      await expect(authController.login(validLoginDto)).rejects.toThrow(
        'Erreur lors de la connexion',
      );

      try {
        await authController.login(validLoginDto);
      } catch (error) {
        expect(error.getStatus()).toBe(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    });

    it('should log login attempt and success', async () => {
      const loggerSpy = jest
        .spyOn(Logger.prototype, 'log')
        .mockImplementation();
      mockAuthService.login.mockResolvedValue(mockAuthResponse);

      await authController.login(validLoginDto);

      expect(loggerSpy).toHaveBeenCalledWith(
        `Login attempt for email: ${validLoginDto.email}`,
      );
      expect(loggerSpy).toHaveBeenCalledWith(
        `Login successful for email: ${validLoginDto.email}`,
      );

      loggerSpy.mockRestore();
    });

    it('should log login failure', async () => {
      const loggerErrorSpy = jest
        .spyOn(Logger.prototype, 'error')
        .mockImplementation();
      const loginError = new BadRequestException('Invalid credentials');
      mockAuthService.login.mockRejectedValue(loginError);

      try {
        await authController.login(validLoginDto);
      } catch {
        // Expected to throw
      }

      expect(loggerErrorSpy).toHaveBeenCalledWith(
        `Login failed for email: ${validLoginDto.email}`,
        loginError.stack,
      );

      loggerErrorSpy.mockRestore();
    });

    it('should handle empty email in login DTO', async () => {
      const invalidLoginDto = { ...validLoginDto, email: '' };
      const validationError = new BadRequestException('Email requis');
      mockAuthService.login.mockRejectedValue(validationError);

      await expect(authController.login(invalidLoginDto)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('register', () => {
    it('should register user successfully and return access token', async () => {
      mockAuthService.register.mockResolvedValue(mockAuthResponse);

      const result = await authController.register(validRegisterDto);

      expect(result).toEqual(mockAuthResponse);
      expect(mockAuthService.register).toHaveBeenCalledWith(validRegisterDto);
      expect(mockAuthService.register).toHaveBeenCalledTimes(1);
    });

    it('should throw BadRequestException for duplicate email', async () => {
      const duplicateEmailError = new BadRequestException(
        'Cet email est déjà utilisé',
      );
      mockAuthService.register.mockRejectedValue(duplicateEmailError);

      await expect(authController.register(validRegisterDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authController.register(validRegisterDto)).rejects.toThrow(
        'Cet email est déjà utilisé',
      );
      expect(mockAuthService.register).toHaveBeenCalledWith(validRegisterDto);
    });

    it('should throw BadRequestException for duplicate username', async () => {
      const duplicateUsernameError = new BadRequestException(
        "Ce nom d'utilisateur est déjà pris",
      );
      mockAuthService.register.mockRejectedValue(duplicateUsernameError);

      await expect(authController.register(validRegisterDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authController.register(validRegisterDto)).rejects.toThrow(
        "Ce nom d'utilisateur est déjà pris",
      );
    });

    it('should throw BadRequestException for weak password', async () => {
      const weakPasswordDto = { ...validRegisterDto, password: 'weak' };
      const weakPasswordError = new BadRequestException(
        'Le mot de passe doit contenir au moins 8 caractères',
      );
      mockAuthService.register.mockRejectedValue(weakPasswordError);

      await expect(authController.register(weakPasswordDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authController.register(weakPasswordDto)).rejects.toThrow(
        'Le mot de passe doit contenir au moins 8 caractères',
      );
    });

    it('should throw BadRequestException for unexpected service errors', async () => {
      const unexpectedError = new Error('Database connection failed');
      mockAuthService.register.mockRejectedValue(unexpectedError);

      await expect(authController.register(validRegisterDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authController.register(validRegisterDto)).rejects.toThrow(
        'Erreur lors de la création du compte',
      );
    });

    it('should preserve BadRequestException from service', async () => {
      const serviceError = new BadRequestException('Service validation error');
      mockAuthService.register.mockRejectedValue(serviceError);

      await expect(authController.register(validRegisterDto)).rejects.toThrow(
        BadRequestException,
      );
      await expect(authController.register(validRegisterDto)).rejects.toThrow(
        'Service validation error',
      );
    });

    it('should log registration attempt and success', async () => {
      const loggerSpy = jest
        .spyOn(Logger.prototype, 'log')
        .mockImplementation();
      mockAuthService.register.mockResolvedValue(mockAuthResponse);

      await authController.register(validRegisterDto);

      expect(loggerSpy).toHaveBeenCalledWith(
        `Registration attempt for email: ${validRegisterDto.email}`,
      );
      expect(loggerSpy).toHaveBeenCalledWith(
        `Registration successful for email: ${validRegisterDto.email}`,
      );

      loggerSpy.mockRestore();
    });

    it('should log registration failure', async () => {
      const loggerErrorSpy = jest
        .spyOn(Logger.prototype, 'error')
        .mockImplementation();
      const registrationError = new BadRequestException('Registration failed');
      mockAuthService.register.mockRejectedValue(registrationError);

      try {
        await authController.register(validRegisterDto);
      } catch {
        // Expected to throw
      }

      expect(loggerErrorSpy).toHaveBeenCalledWith(
        `Registration failed for email: ${validRegisterDto.email}`,
        registrationError.stack,
      );

      loggerErrorSpy.mockRestore();
    });

    it('should handle registration with minimal required fields', async () => {
      const minimalRegisterDto = {
        username: 'testuser',
        email: 'test@plany.com',
        password: 'TestPass123!',
        description: '',
        isPremium: false,
        photoUrl: '',
        birthDate: new Date(),
        gender: 'other',
        role: 'user',
        isActive: true,
      };

      const minimalResponse = {
        ...mockAuthResponse,
        user: {
          ...mockAuthResponse.user,
          username: 'testuser',
          email: 'test@plany.com',
        },
      };

      mockAuthService.register.mockResolvedValue(minimalResponse);

      const result = await authController.register(minimalRegisterDto);

      expect(result).toEqual(minimalResponse);
      expect(mockAuthService.register).toHaveBeenCalledWith(minimalRegisterDto);
    });
  });

  describe('edge cases', () => {
    it('should throw TypeError when loginDto is null (controller behavior)', async () => {
      await expect(authController.login(null as any)).rejects.toThrow(TypeError);
      await expect(authController.login(null as any)).rejects.toThrow(
        "Cannot read properties of null (reading 'email')"
      );
    });

    it('should throw TypeError when registerDto is null (controller behavior)', async () => {
      await expect(authController.register(null as any)).rejects.toThrow(TypeError);
      await expect(authController.register(null as any)).rejects.toThrow(
        "Cannot read properties of null (reading 'email')"
      );
    });

    it('should throw TypeError when loginDto is undefined (controller behavior)', async () => {
      await expect(authController.login(undefined as any)).rejects.toThrow(TypeError);
    });

    it('should throw TypeError when registerDto is undefined (controller behavior)', async () => {
      await expect(authController.register(undefined as any)).rejects.toThrow(TypeError);
    });

    it('should handle malformed email in login', async () => {
      const malformedLoginDto = { ...validLoginDto, email: 'invalid-email' };
      const validationError = new BadRequestException('Format email invalide');
      mockAuthService.login.mockRejectedValue(validationError);

      await expect(authController.login(malformedLoginDto)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should handle malformed email in register', async () => {
      const malformedRegisterDto = {
        ...validRegisterDto,
        email: 'invalid-email',
      };
      const validationError = new BadRequestException('Format email invalide');
      mockAuthService.register.mockRejectedValue(validationError);

      await expect(
        authController.register(malformedRegisterDto),
      ).rejects.toThrow(BadRequestException);
    });

    it('should log "undefined" when loginDto.email is undefined', async () => {
      const loggerErrorSpy = jest
        .spyOn(Logger.prototype, 'error')
        .mockImplementation();

      const dtoWithoutEmail = { password: 'test' } as any;
      
      try {
        await authController.login(dtoWithoutEmail);
      } catch {
        // Expected TypeError
      }

      expect(loggerErrorSpy).toHaveBeenCalledWith(
        'Login failed for email: undefined',
        expect.any(String),
      );

      loggerErrorSpy.mockRestore();
    });

    it('should log "undefined" when registerDto.email is undefined', async () => {
      const loggerErrorSpy = jest
        .spyOn(Logger.prototype, 'error')
        .mockImplementation();

      const dtoWithoutEmail = { username: 'test', password: 'test' } as any;
      
      try {
        await authController.register(dtoWithoutEmail);
      } catch {
        // Expected TypeError  
      }

      expect(loggerErrorSpy).toHaveBeenCalledWith(
        'Registration failed for email: undefined',
        expect.any(String),
      );

      loggerErrorSpy.mockRestore();
    });
  });

  describe('controller routing', () => {
    it('should be mapped to correct routes', () => {
      const controllerMetadata = Reflect.getMetadata('path', AuthController);
      expect(controllerMetadata).toBeDefined();
      expect(typeof controllerMetadata).toBe('string');
      expect(controllerMetadata).toContain('auth');
    });
  });
});
