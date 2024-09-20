import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from '../auth.controller';
import { AuthService } from '../auth.service';

describe('AuthController', () => {
  let authController: AuthController;
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let authService: AuthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: {
            generateJwt: jest
              .fn()
              .mockResolvedValue({ access_token: 'mockJwtToken' }),
          },
        },
      ],
    }).compile();

    authController = module.get<AuthController>(AuthController);
    authService = module.get<AuthService>(AuthService);
  });

  it('should return a JWT token on callback', async () => {
    const req = { user: { userId: '123', email: 'test@example.com' } };
    const res = { json: jest.fn() };
    await authController.callback(req, res);
    expect(res.json).toHaveBeenCalledWith({ access_token: 'mockJwtToken' });
  });
});
