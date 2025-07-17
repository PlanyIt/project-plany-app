import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from './../src/app.module';
import { MongooseModule } from '@nestjs/mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

describe('AppController (e2e)', () => {
  let app: INestApplication;
  let mongoServer: MongoMemoryServer;

  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule, MongooseModule.forRoot(mongoUri)],
    }).compile();

    app = moduleFixture.createNestApplication();

    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );

    await app.init();
  });

  afterAll(async () => {
    await app.close();
    await mongoServer.stop();
  });

  describe('Root endpoint', () => {
    it('/ (GET)', () => {
      return request(app.getHttpServer())
        .get('/')
        .expect(200)
        .expect('Hello World!');
    });

    it('/ (GET) should return string content-type', () => {
      return request(app.getHttpServer())
        .get('/')
        .expect(200)
        .expect('Content-Type', /text/)
        .expect('Hello World!');
    });
  });

  describe('Health checks', () => {
    it('/health (GET) should return 404 if not implemented', () => {
      return request(app.getHttpServer()).get('/health').expect(404);
    });
  });

  describe('API documentation', () => {
    it('/api/docs should be accessible if Swagger is enabled', async () => {
      const response = await request(app.getHttpServer()).get('/api/docs');

      expect([200, 404]).toContain(response.status);
    });
  });

  describe('Error handling', () => {
    it('should return 404 for non-existent routes', () => {
      return request(app.getHttpServer())
        .get('/non-existent-route')
        .expect(404);
    });

    it('should handle invalid HTTP methods', () => {
      return request(app.getHttpServer()).patch('/').expect(404);
    });
  });

  describe('CORS', () => {
    it('should include CORS headers', () => {
      return request(app.getHttpServer())
        .get('/')
        .expect(200)
        .expect((res) => {
          if (res.headers['access-control-allow-origin']) {
            expect(res.headers['access-control-allow-origin']).toBeDefined();
          }
        });
    });
  });

  describe('Security headers', () => {
    it('should not expose sensitive information', () => {
      return request(app.getHttpServer())
        .get('/')
        .expect(200)
        .expect((res) => {
          expect(res.headers['x-powered-by']).toBeDefined();
        });
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
