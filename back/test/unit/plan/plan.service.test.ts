import { Test, TestingModule } from '@nestjs/testing';
import { PlanService } from '../../../src/plan/plan.service';
import { getModelToken, getConnectionToken } from '@nestjs/mongoose';
import * as planFixtures from '../../__fixtures__/plans.json';
import { StepService } from '../../../src/step/step.service';

describe('PlanService', () => {
  let planService: PlanService;

  const { validPlans } = planFixtures;

  const createMockQuery = (resolveValue) => ({
    populate: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    session: jest.fn().mockReturnThis(),
    exec: jest.fn().mockResolvedValue(resolveValue),
  });

  const mockPlanModel = {
    find: jest.fn(),
    findOne: jest.fn(),
    findById: jest.fn(),
    findByIdAndUpdate: jest.fn(),
    findOneAndUpdate: jest.fn(),
    findOneAndDelete: jest.fn(),
    countDocuments: jest.fn(),
    updateOne: jest.fn(),
    updateMany: jest.fn(),
    deleteOne: jest.fn(),
    populate: jest.fn(),
    sort: jest.fn(),
    exec: jest.fn(),
    create: jest.fn(),
  };

  const mockUserModel = {};
  const mockStepModel = {
    deleteMany: jest.fn(() => ({
      exec: jest.fn().mockResolvedValue({ deletedCount: 2 }),
    })),
  };
  const mockCommentModel = {
    deleteMany: jest.fn(() => ({
      exec: jest.fn().mockResolvedValue({ deletedCount: 5 }),
    })),
  };
  const mockConnection = {
    startSession: jest.fn().mockReturnValue({
      withTransaction: jest.fn().mockImplementation((fn) => fn()),
      endSession: jest.fn().mockResolvedValue(undefined),
    }),
  };
  const mockStepService = {
    calculateTotalCost: jest.fn().mockResolvedValue(150),
    calculateTotalDuration: jest.fn().mockResolvedValue(240),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    mockPlanModel.find.mockReturnValue(createMockQuery([]));
    mockPlanModel.findById.mockReturnValue(createMockQuery(null));
    mockPlanModel.findOne.mockReturnValue(createMockQuery(null));
    mockPlanModel.findByIdAndUpdate.mockReturnValue(createMockQuery(null));
    mockPlanModel.findOneAndUpdate.mockReturnValue(createMockQuery(null));
    mockPlanModel.findOneAndDelete.mockReturnValue(createMockQuery(null));
    mockPlanModel.countDocuments.mockReturnValue(createMockQuery(0));

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PlanService,
        { provide: getModelToken('Plan'), useValue: mockPlanModel },
        { provide: getModelToken('User'), useValue: mockUserModel },
        { provide: getModelToken('Step'), useValue: mockStepModel },
        { provide: getModelToken('Comment'), useValue: mockCommentModel },
        { provide: getConnectionToken(), useValue: mockConnection },
        { provide: StepService, useValue: mockStepService },
        {
          provide: 'CACHE_MANAGER',
          useValue: { get: jest.fn(), set: jest.fn(), del: jest.fn() },
        },
      ],
    }).compile();

    planService = module.get<PlanService>(PlanService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(planService).toBeDefined();
  });

  describe('removeById', () => {
    it('should throw NotFoundException when user is not the owner', async () => {
      mockPlanModel.findOne.mockReturnValue(createMockQuery(null));
      await expect(
        planService.removeById(validPlans[0]._id, 'wrong-user'),
      ).rejects.toThrow('Plan not found or not owned by user');
    });

    it('should delete plan when found and user is owner', async () => {
      const planId = validPlans[0]._id;
      const userId = validPlans[0].user;
      mockPlanModel.findOne.mockReturnValue(createMockQuery(validPlans[0]));
      mockPlanModel.deleteOne.mockResolvedValue({ deletedCount: 1 });

      const result = await planService.removeById(planId, userId);

      expect(result).toEqual({ deleted: true });
      expect(mockPlanModel.deleteOne).toHaveBeenCalledWith({
        _id: planId,
        user: userId,
      });
    });
  });
});
