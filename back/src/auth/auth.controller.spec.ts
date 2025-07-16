import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { BadRequestException, HttpException } from '@nestjs/common';

const mockAuthService = {
  login: jest.fn(),
  register: jest.fn(),
  refresh: jest.fn(),
  logout: jest.fn(),
  changePassword: jest.fn(),
};

describe('AuthController', () => {
  let controller: AuthController;

  beforeEach(async () => {
    jest.spyOn(console, 'error').mockImplementation(() => {});
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [{ provide: AuthService, useValue: mockAuthService }],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    jest.clearAllMocks();
  });

  afterEach(() => {
    (console.error as jest.Mock).mockRestore();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('login', () => {
    it('should return login result', async () => {
      mockAuthService.login.mockResolvedValue({ token: 'abc' });
      await expect(
        controller.login({ email: 'a@a.fr', password: 'x' }),
      ).resolves.toEqual({ token: 'abc' });
    });

    it('should throw BadRequestException on error', async () => {
      mockAuthService.login.mockRejectedValue(new BadRequestException('fail'));
      await expect(
        controller.login({ email: 'a@a.fr', password: 'x' }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw HttpException on unknown error', async () => {
      mockAuthService.login.mockRejectedValue(new Error('fail'));
      await expect(
        controller.login({ email: 'a@a.fr', password: 'x' }),
      ).rejects.toThrow(HttpException);
    });
  });

  describe('register', () => {
    it('should return register result', async () => {
      mockAuthService.register.mockResolvedValue({ user: 'u' });
      await expect(
        controller.register({ email: 'a@a.fr', password: 'x', username: 'u' }),
      ).resolves.toEqual({ user: 'u' });
    });

    it('should throw BadRequestException on error', async () => {
      mockAuthService.register.mockRejectedValue(
        new BadRequestException('fail'),
      );
      await expect(
        controller.register({ email: 'a@a.fr', password: 'x', username: 'u' }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException on unknown error', async () => {
      mockAuthService.register.mockRejectedValue(new Error('fail'));
      await expect(
        controller.register({ email: 'a@a.fr', password: 'x', username: 'u' }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('refresh', () => {
    it('should throw if refreshToken is missing', async () => {
      await expect(controller.refresh({} as any)).rejects.toThrow(
        BadRequestException,
      );
    });
    it('should return refresh result', async () => {
      mockAuthService.refresh.mockResolvedValue({ token: 'new' });
      await expect(controller.refresh({ refreshToken: 'rt' })).resolves.toEqual(
        { token: 'new' },
      );
    });
  });

  describe('logout', () => {
    it('should throw if refreshToken is missing', async () => {
      await expect(controller.logout(undefined as any)).rejects.toThrow(
        BadRequestException,
      );
    });
    it('should call logout', async () => {
      mockAuthService.logout.mockResolvedValue(undefined);
      await expect(controller.logout('rt')).resolves.toBeUndefined();
      expect(mockAuthService.logout).toHaveBeenCalledWith('rt');
    });
  });

  describe('changePwd', () => {
    it('should throw if userId is missing', async () => {
      await expect(
        controller.changePwd(
          { currentPassword: 'a', newPassword: 'b' },
          { user: undefined },
        ),
      ).rejects.toThrow(HttpException);
    });
    it('should call changePassword and return message', async () => {
      mockAuthService.changePassword.mockResolvedValue(undefined);
      const req = { user: { sub: 'id' } };
      await expect(
        controller.changePwd({ currentPassword: 'a', newPassword: 'b' }, req),
      ).resolves.toEqual({ message: 'Mot de passe modifié avec succès' });
      expect(mockAuthService.changePassword).toHaveBeenCalledWith(
        'id',
        'a',
        'b',
      );
    });
  });
});
