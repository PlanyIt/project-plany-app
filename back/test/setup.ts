import { MongoMemoryServer } from 'mongodb-memory-server';
import { connect, connection } from 'mongoose';

let mongoServer: MongoMemoryServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();

  await connect(mongoUri);

  jest.setTimeout(30000);
});

afterAll(async () => {
  await connection.dropDatabase();
  await connection.close();
  await mongoServer.stop();
});

afterEach(async () => {
  const collections = connection.collections;
  for (const key in collections) {
    const collection = collections[key];
    await collection.deleteMany({});
  }

  jest.clearAllMocks();
});

export const loadFixture = async (fixtureName: string) => {
  const fixture = await import(`./__fixtures__/${fixtureName}.json`);
  return fixture;
};

export const createTestUser = async (userData = {}) => {
  const { validUser } = await loadFixture('users');
  return { ...validUser, ...userData };
};

export const createTestPlan = async (planData = {}) => {
  const { validPlan } = await loadFixture('plans');
  return { ...validPlan, ...planData };
};
