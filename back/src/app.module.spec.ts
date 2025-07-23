import { Test, TestingModule } from '@nestjs/testing';
import { AppModule } from './app.module';

describe('AppModule', () => {
  let module: TestingModule;

  beforeAll(async () => {
    jest.spyOn(console, 'error').mockImplementation(() => {});
    jest.spyOn(console, 'log').mockImplementation(() => {});
    module = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
  }, 30000); // Increase timeout for slow setup

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
    (console.log as jest.Mock).mockRestore();
  });

  it('should be defined', () => {
    expect(module).toBeDefined();
  });
});
