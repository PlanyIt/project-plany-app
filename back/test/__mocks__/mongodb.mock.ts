export const mockMongooseModel = {
  find: jest.fn(),
  findById: jest.fn(),
  findOne: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  updateOne: jest.fn(),
  deleteOne: jest.fn(),
  populate: jest.fn(),
  exec: jest.fn(),
  countDocuments: jest.fn(),
  aggregate: jest.fn(),
};

export const mockRepository = {
  find: jest.fn(),
  findOne: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
  findById: jest.fn(),
  findOneAndUpdate: jest.fn(),
  findOneAndDelete: jest.fn(),
};

export const mockConnection = {
  startSession: jest.fn(),
  close: jest.fn(),
};

export const mockSession = {
  startTransaction: jest.fn(),
  commitTransaction: jest.fn(),
  abortTransaction: jest.fn(),
  endSession: jest.fn(),
};
