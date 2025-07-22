jest.setTimeout(30000); // Augmente le timeout à 30 secondes

process.env.JWT_SECRET_AT = process.env.JWT_SECRET_AT || 'test-secret';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret';

import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../../src/app.module';
import { MongoMemoryServer } from 'mongodb-memory-server';

describe('Security (e2e)', () => {
  let app: INestApplication;
  let mongoServer: MongoMemoryServer;

  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();
    process.env.MONGO_URI = mongoUri;
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
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    await mongoServer.stop();
  });

  it('should reject requests with invalid JWT', async () => {
    await request(app.getHttpServer())
      .get('/api/plans')
      .set('Authorization', 'Bearer invalid.token.here')
      .expect(401);
  });

  it('should reject access to protected endpoint without token', async () => {
    await request(app.getHttpServer()).get('/api/plans').expect(401);
  });
});
