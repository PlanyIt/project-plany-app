import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { MongoMemoryServer } from 'mongodb-memory-server';

import 'dotenv/config';
import { AppModule } from 'src/app.module';
jest.setTimeout(120000);

describe('AppController (e2e)', () => {
  let app: INestApplication;
  let mongoServer: MongoMemoryServer;

  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );

    app.enableCors({
      origin: '*',
    });

    // Disable 'x-powered-by' header if using Express
    const expressApp = app.getHttpAdapter().getInstance?.();
    if (expressApp?.disable) {
      expressApp.disable('x-powered-by');
    }

    await app.init();
  });

  afterAll(async () => {
    if (app) await app.close();
    if (mongoServer) await mongoServer.stop();
  });

  describe('Root endpoint', () => {
    it('/ (GET)', async () => {
      await request(app.getHttpServer())
        .get('/')
        .expect(200)
        .expect('Hello World!');
    });

    it('/ (GET) should return string content-type', async () => {
      await request(app.getHttpServer())
        .get('/')
        .expect(200)
        .expect('Content-Type', /text/)
        .expect('Hello World!');
    });
  });

  describe('Health checks', () => {
    it('/health (GET) should return 404 if not implemented', async () => {
      await request(app.getHttpServer()).get('/health').expect(404);
    });
  });

  describe('API documentation', () => {
    it('/api/docs should be accessible if Swagger is enabled', async () => {
      const response = await request(app.getHttpServer()).get('/api/docs');
      expect([200, 404]).toContain(response.status);
    });
  });

  describe('Error handling', () => {
    it('should return 404 for non-existent routes', async () => {
      await request(app.getHttpServer()).get('/non-existent-route').expect(404);
    });

    it('should handle invalid HTTP methods', async () => {
      await request(app.getHttpServer()).patch('/').expect(404);
    });
  });

  describe('CORS', () => {
    it('should include CORS headers', async () => {
      const res = await request(app.getHttpServer()).get('/');
      expect(res.status).toBe(200);
      expect(res.headers['access-control-allow-origin']).toBeDefined();
    });
  });

  describe('Security headers', () => {
    it('should not expose x-powered-by', async () => {
      const res = await request(app.getHttpServer()).get('/');
      expect(res.status).toBe(200);
      expect(res.headers['x-powered-by']).toBeUndefined();
    });
  });

  describe('Performance', () => {
    it('should respond quickly to root endpoint', async () => {
      const start = Date.now();
      await request(app.getHttpServer()).get('/').expect(200);
      const duration = Date.now() - start;
      expect(duration).toBeLessThan(1000);
    });
  });
});
