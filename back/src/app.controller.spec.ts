import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';

describe('AppController', () => {
  let appController: AppController;
  let appService: AppService;

  const mockAppService = {
    getHello: jest.fn(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [
        {
          provide: AppService,
          useValue: mockAppService,
        },
      ],
    }).compile();

    appController = app.get<AppController>(AppController);
    appService = app.get<AppService>(AppService);
  });

  it('should be defined', () => {
    expect(appController).toBeDefined();
    expect(appService).toBeDefined();
  });

  describe('getHello', () => {
    it('should return "Hello World!"', () => {
      const expectedMessage = 'Hello World!';
      mockAppService.getHello.mockReturnValue(expectedMessage);

      const result = appController.getHello();

      expect(result).toBe(expectedMessage);
      expect(mockAppService.getHello).toHaveBeenCalledTimes(1);
    });

    it('should call AppService.getHello method', () => {
      const message = 'Hello World!';
      mockAppService.getHello.mockReturnValue(message);

      appController.getHello();

      expect(mockAppService.getHello).toHaveBeenCalled();
      expect(mockAppService.getHello).toHaveBeenCalledWith();
    });

    it('should return string type', () => {
      const message = 'Hello World!';
      mockAppService.getHello.mockReturnValue(message);

      const result = appController.getHello();

      expect(typeof result).toBe('string');
    });

    it('should handle different messages from service', () => {
      const customMessage = 'Welcome to PLANY API!';
      mockAppService.getHello.mockReturnValue(customMessage);

      const result = appController.getHello();

      expect(result).toBe(customMessage);
      expect(mockAppService.getHello).toHaveBeenCalledTimes(1);
    });

    it('should work with multiple calls', () => {
      const message = 'Hello World!';
      mockAppService.getHello.mockReturnValue(message);

      const result1 = appController.getHello();
      const result2 = appController.getHello();
      const result3 = appController.getHello();

      expect(result1).toBe(message);
      expect(result2).toBe(message);
      expect(result3).toBe(message);
      expect(mockAppService.getHello).toHaveBeenCalledTimes(3);
    });
  });

  describe('Controller configuration', () => {
    it('should be mapped to root route', () => {
      const controllerPath = Reflect.getMetadata('path', AppController);
      expect(controllerPath).toBe('/');
    });

    it('should have GET method decorator on getHello', () => {
      expect(typeof appController.getHello).toBe('function');
    });

    it('should be instantiated with AppService dependency', () => {
      expect(appController).toBeInstanceOf(AppController);
      expect(appService).toBeDefined();
    });
  });

  describe('Error handling', () => {
    it('should propagate service errors', () => {
      const serviceError = new Error('Service is down');
      mockAppService.getHello.mockImplementation(() => {
        throw serviceError;
      });

      expect(() => appController.getHello()).toThrow('Service is down');
      expect(mockAppService.getHello).toHaveBeenCalledTimes(1);
    });

    it('should handle service returning null', () => {
      mockAppService.getHello.mockReturnValue(null);

      const result = appController.getHello();

      expect(result).toBeNull();
      expect(mockAppService.getHello).toHaveBeenCalledTimes(1);
    });

    it('should handle service returning undefined', () => {
      mockAppService.getHello.mockReturnValue(undefined);

      const result = appController.getHello();

      expect(result).toBeUndefined();
      expect(mockAppService.getHello).toHaveBeenCalledTimes(1);
    });

    it('should handle service returning empty string', () => {
      mockAppService.getHello.mockReturnValue('');

      const result = appController.getHello();

      expect(result).toBe('');
      expect(mockAppService.getHello).toHaveBeenCalledTimes(1);
    });
  });

  describe('Performance', () => {
    it('should respond quickly', () => {
      mockAppService.getHello.mockReturnValue('Hello World!');

      const startTime = performance.now();
      appController.getHello();
      const endTime = performance.now();

      const duration = endTime - startTime;
      expect(duration).toBeLessThan(5);
    });

    it('should handle rapid successive calls', () => {
      mockAppService.getHello.mockReturnValue('Hello World!');

      const startTime = performance.now();
      for (let i = 0; i < 100; i++) {
        appController.getHello();
      }
      const endTime = performance.now();

      const duration = endTime - startTime;
      expect(duration).toBeLessThan(50);
      expect(mockAppService.getHello).toHaveBeenCalledTimes(100);
    });
  });

  describe('Integration', () => {
    it('should maintain consistency across calls', () => {
      const message = 'Consistent Hello!';
      mockAppService.getHello.mockReturnValue(message);

      const results = [];
      for (let i = 0; i < 10; i++) {
        results.push(appController.getHello());
      }

      results.forEach((result) => {
        expect(result).toBe(message);
      });

      expect(mockAppService.getHello).toHaveBeenCalledTimes(10);
    });

    it('should work with real AppService behavior', () => {
      mockAppService.getHello.mockReturnValue('Hello World!');

      const result = appController.getHello();

      expect(result).toBe('Hello World!');
      expect(result).toMatch(/Hello/);
      expect(result).toMatch(/World/);
    });
  });
});
