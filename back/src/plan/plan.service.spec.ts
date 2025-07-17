import { Test, TestingModule } from '@nestjs/testing';
import { PlanService } from './plan.service';
import { StepService } from '../step/step.service';

// Helper pour chaînage .populate().populate().exec()
function mockQuery(result) {
  return {
    populate: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    exec: jest.fn().mockResolvedValue(result),
  };
}

const mockPlanModel = {
  find: jest.fn(),
  findById: jest.fn(),
  findOne: jest.fn(),
  findOneAndUpdate: jest.fn(),
  findOneAndDelete: jest.fn(),
  findByIdAndUpdate: jest.fn(),
  updateOne: jest.fn(),
  deleteMany: jest.fn(),
  save: jest.fn(),
};
const mockStepModel = {
  deleteMany: jest.fn().mockReturnThis(),
  exec: jest.fn(),
};
const mockCommentModel = {
  deleteMany: jest.fn().mockReturnThis(),
  exec: jest.fn(),
};
const mockDatabaseConnection = {
  startSession: jest.fn().mockResolvedValue({
    withTransaction: jest.fn((cb) => cb()),
    endSession: jest.fn(),
  }),
};
const mockStepService = {
  calculateTotalCost: jest.fn(),
  calculateTotalDuration: jest.fn(),
};

describe('PlanService', () => {
  let service: PlanService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PlanService,
        { provide: 'PlanModel', useValue: mockPlanModel },
        { provide: 'StepModel', useValue: mockStepModel },
        { provide: 'CommentModel', useValue: mockCommentModel },
        { provide: 'DatabaseConnection', useValue: mockDatabaseConnection },
        { provide: StepService, useValue: mockStepService },
        {
          provide: 'CACHE_MANAGER',
          useValue: { get: jest.fn(), set: jest.fn(), del: jest.fn() },
        },
      ],
    }).compile();

    service = module.get<PlanService>(PlanService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all public plans', async () => {
      const plans = [{ title: 'Plan1' }, { title: 'Plan2' }];
      mockPlanModel.find.mockReturnValue(mockQuery(plans));
      expect(await service.findAll()).toBe(plans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({ isPublic: true });
    });
  });

  describe('findById', () => {
    it('should return a plan by id', async () => {
      const plan = { _id: '1', title: 'Test' };
      mockPlanModel.findById.mockReturnValue(mockQuery(plan));
      expect(await service.findById('507f1f77bcf86cd799439011')).toBe(plan);
      expect(mockPlanModel.findById).toHaveBeenCalledWith(
        '507f1f77bcf86cd799439011',
      );
    });
    it('should throw if id is invalid', async () => {
      await expect(service.findById('invalid')).rejects.toThrow();
    });
  });

  describe('findAllByUserId', () => {
    it('should return all plans for owner', async () => {
      const plans = [{ title: 'Plan1' }];
      mockPlanModel.find.mockReturnValue(mockQuery(plans));
      expect(
        await service.findAllByUserId(
          '507f1f77bcf86cd799439011',
          '507f1f77bcf86cd799439011',
        ),
      ).toBe(plans);
    });
    it('should return only public plans for other users', async () => {
      const plans = [{ title: 'Plan2' }];
      mockPlanModel.find.mockReturnValue(mockQuery(plans));
      expect(
        await service.findAllByUserId('507f1f77bcf86cd799439011', 'other'),
      ).toBe(plans);
    });
  });

  describe('findFavoritesByUserId', () => {
    it('should return favorite plans', async () => {
      const plans = [{ title: 'Fav1' }];
      mockPlanModel.find.mockReturnValue(mockQuery(plans));
      expect(await service.findFavoritesByUserId('user1')).toBe(plans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({ favorites: 'user1' });
    });
  });
});
