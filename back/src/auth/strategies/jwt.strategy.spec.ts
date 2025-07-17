import { JwtStrategy } from './jwt.strategy';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException } from '@nestjs/common';

describe('JwtStrategy', () => {
  let strategy: JwtStrategy;
  let mockUserService: any;
  let mockConfigService: any;

  beforeEach(() => {
    mockUserService = {
      findById: jest.fn(),
    };
    mockConfigService = {
      get: jest.fn().mockReturnValue('secret'),
    };
    strategy = new JwtStrategy(mockConfigService, mockUserService);
  });

  it('should be defined', () => {
    expect(strategy).toBeDefined();
  });

  describe('validate', () => {
    it('should return user if found', async () => {
      const user = { _id: 'id', email: 'a@a.fr' };
      mockUserService.findById.mockResolvedValue(user);
      await expect(strategy.validate({ sub: 'id' })).resolves.toBe(user);
    });

    it('should throw UnauthorizedException if user not found', async () => {
      mockUserService.findById.mockResolvedValue(null);
      await expect(strategy.validate({ sub: 'id' })).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  it('should throw if secret is missing', () => {
    const badConfig = new ConfigService();
    jest.spyOn(badConfig, 'get').mockReturnValue(undefined);
    expect(() => new JwtStrategy(badConfig, mockUserService)).toThrow();
  });
});
