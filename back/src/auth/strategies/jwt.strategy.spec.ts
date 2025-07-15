import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException } from '@nestjs/common';
import { JwtStrategy } from './jwt.strategy';
import { UserService } from '../../user/user.service';

describe('JwtStrategy', () => {
  let jwtStrategy: JwtStrategy;
  let userService: UserService;
  let configService: ConfigService;

  const mockUser = {
    _id: '507f1f77bcf86cd799439011',
    email: 'test@example.com',
    username: 'testuser',
    isActive: true,
  };

  const mockUserService = {
    findById: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn((key: string) => {
      const config = {
        JWT_SECRET_AT: 'test-access-secret',
        JWT_SECRET: 'fallback-secret',
      };
      return config[key];
    }),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        JwtStrategy,
        { provide: UserService, useValue: mockUserService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    jwtStrategy = module.get<JwtStrategy>(JwtStrategy);
    userService = module.get<UserService>(UserService);
    configService = module.get<ConfigService>(ConfigService);
  });

  it('should be defined', () => {
    expect(jwtStrategy).toBeDefined();
  });

  describe('constructor', () => {
    it('should use JWT_SECRET_AT when available', () => {
      expect(configService.get).toHaveBeenCalledWith('JWT_SECRET_AT');
    });

    it('should throw error when no JWT secret is configured', async () => {
      const invalidConfigService = {
        get: jest.fn(() => undefined),
      };

      await expect(async () => {
        await Test.createTestingModule({
          providers: [
            JwtStrategy,
            { provide: UserService, useValue: mockUserService },
            { provide: ConfigService, useValue: invalidConfigService },
          ],
        }).compile();
      }).rejects.toThrow('JWT_SECRET_AT (ou JWT_SECRET) manquant');
    });

    it('should fallback to JWT_SECRET when JWT_SECRET_AT is not available', async () => {
      const fallbackConfigService = {
        get: jest.fn((key: string) => {
          if (key === 'JWT_SECRET_AT') return undefined;
          if (key === 'JWT_SECRET') return 'fallback-secret';
          return undefined;
        }),
      };

      const module = await Test.createTestingModule({
        providers: [
          JwtStrategy,
          { provide: UserService, useValue: mockUserService },
          { provide: ConfigService, useValue: fallbackConfigService },
        ],
      }).compile();

      const strategy = module.get<JwtStrategy>(JwtStrategy);
      expect(strategy).toBeDefined();
      expect(fallbackConfigService.get).toHaveBeenCalledWith('JWT_SECRET_AT');
      expect(fallbackConfigService.get).toHaveBeenCalledWith('JWT_SECRET');
    });
  });

  describe('validate', () => {
    it('should return user when user exists', async () => {
      const payload = {
        sub: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
        username: 'testuser',
      };

      mockUserService.findById.mockResolvedValue(mockUser);

      const result = await jwtStrategy.validate(payload);

      expect(result).toEqual(mockUser);
      expect(userService.findById).toHaveBeenCalledWith(payload.sub);
    });

    it('should throw UnauthorizedException when user not found', async () => {
      const payload = {
        sub: 'nonexistent-user-id',
        email: 'nonexistent@example.com',
      };

      mockUserService.findById.mockResolvedValue(null);

      await expect(jwtStrategy.validate(payload)).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(jwtStrategy.validate(payload)).rejects.toThrow(
        'Utilisateur non trouvé',
      );

      expect(userService.findById).toHaveBeenCalledWith(payload.sub);
    });

    it('should throw UnauthorizedException when userService throws error', async () => {
      const payload = {
        sub: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
      };

      mockUserService.findById.mockRejectedValue(new Error('Database error'));

      await expect(jwtStrategy.validate(payload)).rejects.toThrow(
        'Database error',
      );
      expect(userService.findById).toHaveBeenCalledWith(payload.sub);
    });

    it('should handle payload with minimal data', async () => {
      const payload = { sub: '507f1f77bcf86cd799439011' };

      mockUserService.findById.mockResolvedValue(mockUser);

      const result = await jwtStrategy.validate(payload);

      expect(result).toEqual(mockUser);
      expect(userService.findById).toHaveBeenCalledWith(payload.sub);
    });
  });
});
