import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../../src/app.module';
import { MongooseModule } from '@nestjs/mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';

jest.setTimeout(30000); // 🔧 Important si tu as des tests un peu longs.

describe('PlanController (e2e)', () => {
  let app: INestApplication;
  let mongoServer: MongoMemoryServer;
  let createdPlanId: string;
  let jwtToken: string;
  let categoryId: string;
  let stepId: string;

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
    await app.init();

    const unique = Date.now().toString();
    const maxUniqueLen = 20 - 'testuser'.length;
    const shortUnique = unique.slice(0, maxUniqueLen);
    const user = {
      email: `test+${unique}@e2e.com`,
      username: `testuser${shortUnique}`,
      password: 'Test1234!',
    };
    const registerRes = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send(user);

    if (registerRes.status !== 201) {
      throw new Error('Register failed');
    }

    const loginRes = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: user.email, password: user.password })
      .expect(201);

    jwtToken = loginRes.body.accessToken;

    const categoryRes = await request(app.getHttpServer())
      .post('/api/categories')
      .set('Authorization', `Bearer ${jwtToken}`)
      .send({ name: 'TestCat', icon: 'test', color: '#fff' });

    if (categoryRes.status !== 201) {
      throw new Error('Category creation failed');
    }
    categoryId = categoryRes.body._id;

    const stepRes = await request(app.getHttpServer())
      .post('/api/steps')
      .set('Authorization', `Bearer ${jwtToken}`)
      .send({
        title: 'Step1',
        description: 'desc',
        order: 1,
        image: 'https://example.com/image.jpg',
        latitude: 0,
        longitude: 0,
        duration: 10,
        cost: 0,
      });

    if (stepRes.status !== 201) {
      throw new Error('Step creation failed');
    }
    stepId = stepRes.body._id;
  });

  afterAll(async () => {
    await mongoose.disconnect();
    if (mongoServer) {
      await mongoServer.stop();
    }
    await app.close();
  });

  it('POST /api/plans should create a plan', async () => {
    const plan = {
      title: 'Test Plan',
      description: 'A test plan',
      category: categoryId,
      steps: [stepId],
      isPublic: true,
    };
    const res = await request(app.getHttpServer())
      .post('/api/plans')
      .set('Authorization', `Bearer ${jwtToken}`)
      .send(plan)
      .expect(201);
    expect(res.body).toHaveProperty('_id');
    expect(res.body.title).toBe(plan.title);
    expect(res.body.description).toBe(plan.description);
    createdPlanId = res.body._id;
  });

  it('GET /api/plans should contain the created plan', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/plans')
      .set('Authorization', `Bearer ${jwtToken}`)
      .expect(200);
    const ids = res.body.map((p: any) => p._id);
    expect(ids).toContain(createdPlanId);
  });

  it('GET /api/plans/:id should return the plan', async () => {
    const res = await request(app.getHttpServer())
      .get(`/api/plans/${createdPlanId}`)
      .set('Authorization', `Bearer ${jwtToken}`)
      .expect(200);
    expect(res.body._id).toBe(createdPlanId);
  });

  it('DELETE /api/plans/:id should delete the plan', async () => {
    await request(app.getHttpServer())
      .delete(`/api/plans/${createdPlanId}`)
      .set('Authorization', `Bearer ${jwtToken}`)
      .expect(200);
  });

  it('GET /api/plans should not contain the deleted plan', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/plans')
      .set('Authorization', `Bearer ${jwtToken}`)
      .expect(200);
    const ids = res.body.map((p: any) => p._id);
    expect(ids).not.toContain(createdPlanId);
  });
});
