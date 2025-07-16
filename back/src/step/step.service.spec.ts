import { Test, TestingModule } from '@nestjs/testing';
import { StepService } from './step.service';

const mockStepModel = {
  find: jest.fn().mockReturnThis(),
  findOne: jest.fn().mockReturnThis(),
  findOneAndUpdate: jest.fn().mockReturnThis(),
  findOneAndDelete: jest.fn().mockReturnThis(),
  updateMany: jest.fn(),
  save: jest.fn(),
  sort: jest.fn().mockReturnThis(),
  exec: jest.fn(),
};
const mockPlanModel = {
  updateMany: jest.fn(),
};

describe('StepService', () => {
  let service: StepService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StepService,
        { provide: 'StepModel', useValue: mockStepModel },
        { provide: 'PlanModel', useValue: mockPlanModel },
      ],
    }).compile();

    service = module.get<StepService>(StepService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all steps', async () => {
      const steps = [{ title: 'Step1' }, { title: 'Step2' }];
      mockStepModel.exec.mockResolvedValueOnce(steps);
      expect(await service.findAll()).toBe(steps);
      expect(mockStepModel.find).toHaveBeenCalled();
    });
  });

  describe('findById', () => {
    it('should return a step by id', async () => {
      const step = { _id: '1', title: 'Test' };
      mockStepModel.exec.mockResolvedValueOnce(step);
      expect(await service.findById('1')).toBe(step);
      expect(mockStepModel.findOne).toHaveBeenCalledWith({ _id: '1' });
    });
    it('should return undefined if not found', async () => {
      mockStepModel.exec.mockResolvedValueOnce(undefined);
      expect(await service.findById('notfound')).toBeUndefined();
    });
  });

  describe('findByIds', () => {
    it('should return steps by ids', async () => {
      const steps = [{ _id: '1' }, { _id: '2' }];
      mockStepModel.exec.mockResolvedValueOnce(steps);
      expect(await service.findByIds(['1', '2'])).toBe(steps);
      expect(mockStepModel.find).toHaveBeenCalledWith({
        _id: { $in: ['1', '2'] },
      });
      expect(mockStepModel.sort).toHaveBeenCalledWith({ order: 1 });
    });
  });

  describe('calculateTotalCost', () => {
    it('should sum cost of steps', async () => {
      const steps = [{ cost: 10 }, { cost: 5 }, { cost: undefined }];
      jest.spyOn(service, 'findByIds').mockResolvedValueOnce(steps as any);
      expect(await service.calculateTotalCost(['1', '2', '3'])).toBe(15);
    });
  });

  describe('calculateTotalDuration', () => {
    it('should sum duration of steps', async () => {
      const steps = [
        { duration: 30 },
        { duration: 15 },
        { duration: undefined },
      ];
      jest.spyOn(service, 'findByIds').mockResolvedValueOnce(steps as any);
      expect(await service.calculateTotalDuration(['1', '2', '3'])).toBe(45);
    });
  });
});
