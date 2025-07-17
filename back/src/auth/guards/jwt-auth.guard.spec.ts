import { Test, TestingModule } from '@nestjs/testing';
import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { JwtAuthGuard } from './jwt-auth.guard';
import { JwtStrategy } from '../strategies/jwt.strategy';
import { UserService } from '../../user/user.service';
import { ConfigService } from '@nestjs/config';

describe('JwtAuthGuard', () => {
  let guard: JwtAuthGuard;

  const mockUser = {
    _id: '507f1f77bcf86cd799439011',
    email: 'test@example.com',
    username: 'testuser',
  };

  const mockUserService = {
    findById: jest.fn().mockResolvedValue(mockUser),
  };

  const mockConfigService = {
    get: jest.fn((key: string) => {
      const config = {
        JWT_SECRET_AT: 'test-secret-key-for-integration-tests',
        JWT_SECRET: 'test-secret-key-for-integration-tests',
      };
      return config[key];
    }),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      imports: [
        PassportModule,
        JwtModule.register({
          secret: 'test-secret-key-for-integration-tests',
          signOptions: { expiresIn: '1h' },
        }),
      ],
      providers: [
        JwtAuthGuard,
        JwtStrategy,
        { provide: UserService, useValue: mockUserService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    guard = module.get<JwtAuthGuard>(JwtAuthGuard);
  });

  it('should be defined', () => {
    expect(guard).toBeDefined();
  });

  it('should create execution context without throwing', () => {
    const mockRequest = {
      headers: {},
      user: null,
    };

    const mockContext: ExecutionContext = {
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => mockRequest),
        getResponse: jest.fn(),
        getNext: jest.fn(),
      })) as any,
      getClass: jest.fn(),
      getHandler: jest.fn(),
      getArgs: jest.fn(),
      getArgByIndex: jest.fn(),
      switchToRpc: jest.fn(),
      switchToWs: jest.fn(),
      getType: jest.fn(() => 'http') as any,
    };

    expect(guard).toBeDefined();
    expect(() => mockContext.switchToHttp()).not.toThrow();
  });

  it('should throw UnauthorizedException for missing authorization header', async () => {
    const mockRequest = {
      headers: {},
      user: null,
    };

    const mockContext: ExecutionContext = {
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => mockRequest),
        getResponse: jest.fn(),
        getNext: jest.fn(),
      })) as any,
      getClass: jest.fn(),
      getHandler: jest.fn(),
      getArgs: jest.fn(),
      getArgByIndex: jest.fn(),
      switchToRpc: jest.fn(),
      switchToWs: jest.fn(),
      getType: jest.fn(() => 'http') as any,
    };

    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      'No auth token',
    );
  });

  it('should throw UnauthorizedException for malformed authorization header', async () => {
    const mockRequest = {
      headers: { authorization: 'Invalid header format' },
      user: null,
    };

    const mockContext: ExecutionContext = {
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => mockRequest),
        getResponse: jest.fn(),
        getNext: jest.fn(),
      })) as any,
      getClass: jest.fn(),
      getHandler: jest.fn(),
      getArgs: jest.fn(),
      getArgByIndex: jest.fn(),
      switchToRpc: jest.fn(),
      switchToWs: jest.fn(),
      getType: jest.fn(() => 'http') as any,
    };

    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      'No auth token',
    );
  });

  it('should throw UnauthorizedException for Bearer token without actual token', async () => {
    const mockRequest = {
      headers: { authorization: 'Bearer ' },
      user: null,
    };

    const mockContext: ExecutionContext = {
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => mockRequest),
        getResponse: jest.fn(),
        getNext: jest.fn(),
      })) as any,
      getClass: jest.fn(),
      getHandler: jest.fn(),
      getArgs: jest.fn(),
      getArgByIndex: jest.fn(),
      switchToRpc: jest.fn(),
      switchToWs: jest.fn(),
      getType: jest.fn(() => 'http') as any,
    };

    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      'No auth token',
    );
  });

  it('should throw UnauthorizedException for invalid JWT format', async () => {
    const mockRequest = {
      headers: { authorization: 'Bearer invalid.jwt.format' },
      user: null,
    };

    const mockContext: ExecutionContext = {
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => mockRequest),
        getResponse: jest.fn(),
        getNext: jest.fn(),
      })) as any,
      getClass: jest.fn(),
      getHandler: jest.fn(),
      getArgs: jest.fn(),
      getArgByIndex: jest.fn(),
      switchToRpc: jest.fn(),
      switchToWs: jest.fn(),
      getType: jest.fn(() => 'http') as any,
    };

    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      /jwt malformed|Unauthorized|invalid token/,
    );
  });

  it('should throw UnauthorizedException with specific message for invalid token format', async () => {
    const mockRequest = {
      headers: { authorization: 'Bearer invalid.jwt.format' },
      user: null,
    };

    const mockContext: ExecutionContext = {
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => mockRequest),
        getResponse: jest.fn(),
        getNext: jest.fn(),
      })) as any,
      getClass: jest.fn(),
      getHandler: jest.fn(),
      getArgs: jest.fn(),
      getArgByIndex: jest.fn(),
      switchToRpc: jest.fn(),
      switchToWs: jest.fn(),
      getType: jest.fn(() => 'http') as any,
    };

    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      'invalid token',
    );
  });

  it('should throw UnauthorizedException for completely malformed JWT', async () => {
    const mockRequest = {
      headers: { authorization: 'Bearer notajwtatall' },
      user: null,
    };

    const mockContext: ExecutionContext = {
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => mockRequest),
        getResponse: jest.fn(),
        getNext: jest.fn(),
      })) as any,
      getClass: jest.fn(),
      getHandler: jest.fn(),
      getArgs: jest.fn(),
      getArgByIndex: jest.fn(),
      switchToRpc: jest.fn(),
      switchToWs: jest.fn(),
      getType: jest.fn(() => 'http') as any,
    };

    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      /jwt malformed|invalid token/,
    );
  });

  it('should throw UnauthorizedException for JWT with invalid signature', async () => {
    const fakeJWT =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.invalid_signature';

    const mockRequest = {
      headers: { authorization: `Bearer ${fakeJWT}` },
      user: null,
    };

    const mockContext: ExecutionContext = {
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => mockRequest),
        getResponse: jest.fn(),
        getNext: jest.fn(),
      })) as any,
      getClass: jest.fn(),
      getHandler: jest.fn(),
      getArgs: jest.fn(),
      getArgByIndex: jest.fn(),
      switchToRpc: jest.fn(),
      switchToWs: jest.fn(),
      getType: jest.fn(() => 'http') as any,
    };

    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(mockContext)).rejects.toThrow(
      /invalid signature|invalid token|jwt malformed/,
    );
  });
});
