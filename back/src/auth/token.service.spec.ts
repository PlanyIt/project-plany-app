import { Test, TestingModule } from '@nestjs/testing';
import { TokenService } from './token.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { getModelToken } from '@nestjs/mongoose';
import { UnauthorizedException } from '@nestjs/common';

const mockJwtService = {
  sign: jest.fn(),
  verify: jest.fn(),
};
const mockConfigService = {
  get: jest.fn(),
};
const mockRefreshModel = {
  create: jest.fn(),
  updateOne: jest.fn(),
  updateMany: jest.fn(),
  findOne: jest.fn(),
};

describe('TokenService', () => {
  let service: TokenService;

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TokenService,
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
        { provide: getModelToken('RefreshToken'), useValue: mockRefreshModel },
      ],
    }).compile();

    service = module.get<TokenService>(TokenService);
    // Patch the refreshModel property directly for test
    (service as any).refreshModel = mockRefreshModel;
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('signAccess', () => {
    it('should sign access token', () => {
      mockConfigService.get.mockReturnValueOnce('secret');
      mockJwtService.sign.mockReturnValue('access-token');
      const res = service.signAccess({ sub: 'id' });
      expect(res).toBe('access-token');
      expect(mockJwtService.sign).toHaveBeenCalled();
    });
  });

  describe('signRefresh', () => {
    it('should create refresh token and sign JWT', async () => {
      mockConfigService.get.mockReturnValue('secret');
      mockRefreshModel.create.mockResolvedValue({});
      mockJwtService.sign.mockReturnValue('refresh-token');
      const res = await service.signRefresh('userid');
      expect(res).toBe('refresh-token');
      expect(mockRefreshModel.create).toHaveBeenCalled();
      expect(mockJwtService.sign).toHaveBeenCalled();
    });
  });

  describe('revoke', () => {
    it('should update refresh token as revoked', async () => {
      mockRefreshModel.updateOne.mockReturnValue({
        exec: () => Promise.resolve({}),
      });
      await expect(service.revoke('jti')).resolves.toBeUndefined();
      expect(mockRefreshModel.updateOne).toHaveBeenCalledWith(
        { jti: 'jti' },
        { revoked: true },
      );
    });
  });

  describe('verifyRefresh', () => {
    it('should return payload if valid and not revoked', async () => {
      const payload = { jti: 'jti', sub: 'id' };
      mockConfigService.get.mockReturnValue('secret');
      mockJwtService.verify.mockReturnValue(payload);
      mockRefreshModel.findOne.mockImplementation(() => ({
        lean: () => Promise.resolve({ revoked: false }),
      }));
      const result = await service.verifyRefresh('rt');
      expect(result).toEqual(payload);
    });

    it('should throw UnauthorizedException if revoked', async () => {
      const payload = { jti: 'jti', sub: 'id' };
      mockConfigService.get.mockReturnValue('secret');
      mockJwtService.verify.mockReturnValue(payload);
      mockRefreshModel.findOne.mockImplementation(() => ({
        lean: () => Promise.resolve({ revoked: true }),
      }));
      await expect(service.verifyRefresh('rt')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw UnauthorizedException if not found', async () => {
      const payload = { jti: 'jti', sub: 'id' };
      mockConfigService.get.mockReturnValue('secret');
      mockJwtService.verify.mockReturnValue(payload);
      mockRefreshModel.findOne.mockImplementation(() => ({
        lean: () => Promise.resolve(null),
      }));
      await expect(service.verifyRefresh('rt')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw UnauthorizedException if jwt.verify fails', async () => {
      mockJwtService.verify.mockImplementation(() => {
        throw new Error();
      });
      await expect(service.verifyRefresh('rt')).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('revokeAllForUser', () => {
    it('should update all refresh tokens for user as revoked', async () => {
      mockRefreshModel.updateMany.mockResolvedValue({});
      await expect(service.revokeAllForUser('uid')).resolves.toBeUndefined();
      expect(mockRefreshModel.updateMany).toHaveBeenCalledWith(
        { userId: 'uid', revoked: false },
        { revoked: true },
      );
    });
  });

  describe('revokeFromJwt', () => {
    it('should extract jti and revoke', async () => {
      mockConfigService.get.mockReturnValue('secret');
      mockJwtService.verify.mockReturnValue({ jti: 'jti' });
      const spy = jest.spyOn(service, 'revoke').mockResolvedValue(undefined);
      await expect(service.revokeFromJwt('rt')).resolves.toBeUndefined();
      expect(spy).toHaveBeenCalledWith('jti');
    });

    it('should not throw if jwt.verify fails', async () => {
      mockJwtService.verify.mockImplementation(() => {
        throw new Error();
      });
      await expect(service.revokeFromJwt('rt')).resolves.toBeUndefined();
    });
  });
});
