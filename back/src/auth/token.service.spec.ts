import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { getModelToken } from '@nestjs/mongoose';
import { UnauthorizedException } from '@nestjs/common';
import { TokenService } from './token.service';
import { RefreshToken } from './schemas/refresh-token.schema';

describe('TokenService', () => {
  let tokenService: TokenService;
  let jwtService: JwtService;

  const mockJwtService = {
    sign: jest.fn(),
    verify: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn((key: string) => {
      const config = {
        JWT_SECRET_AT: 'access-secret',
        JWT_SECRET_RT: 'refresh-secret',
        JWT_AT_EXPIRES_IN: '15m',
        JWT_RT_EXPIRES_IN: '30d',
      };
      return config[key];
    }),
  };

  const mockRefreshModel = {
    create: jest.fn(),
    updateOne: jest.fn(() => ({ exec: jest.fn() })),
    updateMany: jest.fn(),
    findOne: jest.fn(() => ({ lean: jest.fn() })),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    mockConfigService.get.mockImplementation((key: string) => {
      const config = {
        JWT_SECRET_AT: 'access-secret',
        JWT_SECRET_RT: 'refresh-secret',
        JWT_AT_EXPIRES_IN: '15m',
        JWT_RT_EXPIRES_IN: '30d',
      };
      return config[key];
    });

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TokenService,
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
        {
          provide: getModelToken(RefreshToken.name),
          useValue: mockRefreshModel,
        },
      ],
    }).compile();

    tokenService = module.get<TokenService>(TokenService);
    jwtService = module.get<JwtService>(JwtService);
  });

  it('should be defined', () => {
    expect(tokenService).toBeDefined();
  });

  describe('signAccess', () => {
    it('should sign access token with correct payload and options', () => {
      const payload = {
        sub: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
        username: 'testuser',
      };

      mockJwtService.sign.mockReturnValue('signed.access.token');

      const result = tokenService.signAccess(payload);

      expect(result).toBe('signed.access.token');
      expect(jwtService.sign).toHaveBeenCalledWith(payload, {
        secret: 'access-secret',
        expiresIn: '15m',
        algorithm: 'HS512',
      });
    });

    it('should use default expires time when config is not set', () => {
      mockConfigService.get.mockImplementation((key: string) => {
        if (key === 'JWT_SECRET_AT') return 'access-secret';
        if (key === 'JWT_AT_EXPIRES_IN') return undefined;
        return undefined;
      });

      const payload = { sub: '507f1f77bcf86cd799439011' };
      mockJwtService.sign.mockReturnValue('token');

      tokenService.signAccess(payload);

      expect(jwtService.sign).toHaveBeenCalledWith(payload, {
        secret: 'access-secret',
        expiresIn: '15m',
        algorithm: 'HS512',
      });
    });
  });

  describe('signRefresh', () => {
    it('should create refresh token in database and sign JWT', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const tokenVersion = 1;

      mockRefreshModel.create.mockResolvedValue({});
      mockJwtService.sign.mockReturnValue('signed.refresh.token');

      const result = await tokenService.signRefresh(userId, tokenVersion);

      expect(result).toBe('signed.refresh.token');
      expect(mockRefreshModel.create).toHaveBeenCalledWith({
        jti: expect.any(String),
        userId,
        expiresAt: expect.any(Date),
      });
      expect(jwtService.sign).toHaveBeenCalledWith(
        { sub: userId, jti: expect.any(String), tokenVersion },
        {
          secret: 'refresh-secret',
          expiresIn: '30d',
          algorithm: 'HS512',
        },
      );
    });

    it('should use default token version when not provided', async () => {
      const userId = '507f1f77bcf86cd799439011';

      mockRefreshModel.create.mockResolvedValue({});
      mockJwtService.sign.mockReturnValue('token');

      await tokenService.signRefresh(userId);

      expect(jwtService.sign).toHaveBeenCalledWith(
        { sub: userId, jti: expect.any(String), tokenVersion: 0 },
        {
          secret: 'refresh-secret',
          expiresIn: '30d',
          algorithm: 'HS512',
        },
      );
    });
  });

  describe('revoke', () => {
    it('should mark refresh token as revoked in database', async () => {
      const jti = 'test-jti';

      mockRefreshModel.updateOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ modifiedCount: 1 }),
      });

      await tokenService.revoke(jti);

      expect(mockRefreshModel.updateOne).toHaveBeenCalledWith(
        { jti },
        { revoked: true },
      );
    });
  });

  describe('verifyRefresh', () => {
    it('should verify valid refresh token and return payload', async () => {
      const refreshToken = 'valid.refresh.token';
      const payload = { sub: '507f1f77bcf86cd799439011', jti: 'test-jti' };
      const dbRecord = {
        jti: 'test-jti',
        userId: '507f1f77bcf86cd799439011',
        revoked: false,
      };

      mockJwtService.verify.mockReturnValue(payload);
      mockRefreshModel.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue(dbRecord),
      });

      const result = await tokenService.verifyRefresh(refreshToken);

      expect(result).toEqual(payload);
      expect(jwtService.verify).toHaveBeenCalledWith(refreshToken, {
        secret: 'refresh-secret',
      });
      expect(mockRefreshModel.findOne).toHaveBeenCalledWith({
        jti: 'test-jti',
      });
    });

    it('should throw UnauthorizedException when token is revoked', async () => {
      const refreshToken = 'revoked.refresh.token';
      const payload = { sub: '507f1f77bcf86cd799439011', jti: 'test-jti' };
      const dbRecord = {
        jti: 'test-jti',
        userId: '507f1f77bcf86cd799439011',
        revoked: true,
      };

      mockJwtService.verify.mockReturnValue(payload);
      mockRefreshModel.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue(dbRecord),
      });

      await expect(tokenService.verifyRefresh(refreshToken)).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(tokenService.verifyRefresh(refreshToken)).rejects.toThrow(
        'Refresh token invalide ou expiré',
      );
    });

    it('should throw UnauthorizedException when token record not found', async () => {
      const refreshToken = 'unknown.refresh.token';
      const payload = { sub: '507f1f77bcf86cd799439011', jti: 'unknown-jti' };

      mockJwtService.verify.mockReturnValue(payload);
      mockRefreshModel.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue(null),
      });

      await expect(tokenService.verifyRefresh(refreshToken)).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(tokenService.verifyRefresh(refreshToken)).rejects.toThrow(
        'Refresh token invalide ou expiré',
      );
    });

    it('should throw UnauthorizedException when JWT verification fails', async () => {
      const refreshToken = 'invalid.refresh.token';

      mockJwtService.verify.mockImplementation(() => {
        throw new Error('JWT verification failed');
      });

      await expect(tokenService.verifyRefresh(refreshToken)).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(tokenService.verifyRefresh(refreshToken)).rejects.toThrow(
        'Refresh token invalide ou expiré',
      );
    });
  });

  describe('revokeAllForUser', () => {
    it('should revoke all active refresh tokens for user', async () => {
      const userId = '507f1f77bcf86cd799439011';

      mockRefreshModel.updateMany.mockResolvedValue({ modifiedCount: 3 });

      await tokenService.revokeAllForUser(userId);

      expect(mockRefreshModel.updateMany).toHaveBeenCalledWith(
        { userId, revoked: false },
        { revoked: true },
      );
    });
  });

  describe('revokeFromJwt', () => {
    it('should extract jti from JWT and revoke it', async () => {
      const refreshToken = 'token.to.revoke';
      const jti = 'test-jti';

      mockJwtService.verify.mockReturnValue({ jti });
      mockRefreshModel.updateOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ modifiedCount: 1 }),
      });

      await tokenService.revokeFromJwt(refreshToken);

      expect(jwtService.verify).toHaveBeenCalledWith(refreshToken, {
        secret: 'refresh-secret',
        ignoreExpiration: true,
      });
      expect(mockRefreshModel.updateOne).toHaveBeenCalledWith(
        { jti },
        { revoked: true },
      );
    });

    it('should handle JWT verification errors silently', async () => {
      const refreshToken = 'invalid.token';

      mockJwtService.verify.mockImplementation(() => {
        throw new Error('Invalid token');
      });

      await expect(
        tokenService.revokeFromJwt(refreshToken),
      ).resolves.toBeUndefined();
    });
  });

  describe('edge cases', () => {
    it('should handle missing JWT_SECRET_RT in signRefresh', async () => {
      mockConfigService.get.mockImplementation((key: string) => {
        if (key === 'JWT_SECRET_RT') return undefined;
        if (key === 'JWT_RT_EXPIRES_IN') return '30d';
        return undefined;
      });

      const userId = '507f1f77bcf86cd799439011';
      mockRefreshModel.create.mockResolvedValue({});
      mockJwtService.sign.mockReturnValue('token');

      await tokenService.signRefresh(userId);

      expect(jwtService.sign).toHaveBeenCalledWith(expect.any(Object), {
        secret: undefined,
        expiresIn: '30d',
        algorithm: 'HS512',
      });
    });

    it('should use default expires time for refresh token when not configured', async () => {
      mockConfigService.get.mockImplementation((key: string) => {
        if (key === 'JWT_SECRET_RT') return 'refresh-secret';
        if (key === 'JWT_RT_EXPIRES_IN') return undefined;
        return undefined;
      });

      const userId = '507f1f77bcf86cd799439011';
      mockRefreshModel.create.mockResolvedValue({});
      mockJwtService.sign.mockReturnValue('token');

      await tokenService.signRefresh(userId);

      expect(jwtService.sign).toHaveBeenCalledWith(expect.any(Object), {
        secret: 'refresh-secret',
        expiresIn: '30d',
        algorithm: 'HS512',
      });
    });
  });
});
