import { Test, TestingModule } from '@nestjs/testing';
import { PasswordService } from './password.service';

describe('PasswordService', () => {
  let passwordService: PasswordService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PasswordService],
    }).compile();

    passwordService = module.get<PasswordService>(PasswordService);
  });

  it('should be defined', () => {
    expect(passwordService).toBeDefined();
  });

  describe('hashPassword', () => {
    it('should hash password successfully', async () => {
      const password = 'TestPassword123!';

      const hashedPassword = await passwordService.hashPassword(password);

      expect(hashedPassword).toBeDefined();
      expect(hashedPassword).not.toBe(password);
      expect(hashedPassword).toMatch(/^\$argon2id\$v=19\$/);
    });
  });

  describe('verifyPassword', () => {
    it('should verify correct password', async () => {
      const password = 'TestPassword123!';
      const hashedPassword = await passwordService.hashPassword(password);

      const isValid = await passwordService.verifyPassword(
        password,
        hashedPassword,
      );

      expect(isValid).toBe(true);
    });

    it('should reject incorrect password', async () => {
      const password = 'TestPassword123!';
      const wrongPassword = 'WrongPassword123!';
      const hashedPassword = await passwordService.hashPassword(password);

      const isValid = await passwordService.verifyPassword(
        wrongPassword,
        hashedPassword,
      );

      expect(isValid).toBe(false);
    });
  });
});
