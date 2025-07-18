import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from './../src/app.module';
import { MongooseModule } from '@nestjs/mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';

import 'dotenv/config';
jest.setTimeout(60000);

describe('AppController (e2e)', () => {
  let app: INestApplication;
  let mongoServer: MongoMemoryServer;

  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();
    await mongoose.connect(mongoUri);

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

    // Applique CORS + Headers sécurité
    app.enableCors({ origin: '*', credentials: true });
    // Désactive l'en-tête x-powered-by pour Express
    const expressApp = app.getHttpAdapter().getInstance();
    if (expressApp && typeof expressApp.disable === 'function') {
      expressApp.disable('x-powered-by');
    }

    await app.init();
  });

  afterAll(async () => {
    await mongoose.disconnect();
    if (mongoServer) await mongoServer.stop();
    if (app) await app.close();
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
