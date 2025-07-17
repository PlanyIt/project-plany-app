import { Test, TestingModule } from '@nestjs/testing';
import { StepService } from '../../../src/step/step.service';
import { getModelToken } from '@nestjs/mongoose';
import * as stepFixtures from '../../__fixtures__/steps.json';

describe('StepService', () => {
  let stepService: StepService;

  const { validSteps, createStepDtos, updateStepDtos } = stepFixtures;

  const mockStepModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: validSteps[0]._id,
    createdAt: new Date(),
    updatedAt: new Date(),
    save: jest.fn().mockResolvedValue({
      _id: validSteps[0]._id,
      ...dto,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
  })) as any;

  mockStepModel.find = jest.fn();
  mockStepModel.findOne = jest.fn();
  mockStepModel.findOneAndUpdate = jest.fn();
  mockStepModel.findOneAndDelete = jest.fn();

  const mockPlanModel = {
    updateMany: jest
      .fn()
      .mockResolvedValue({ acknowledged: true, modifiedCount: 1 }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StepService,
        {
          provide: getModelToken('Step'),
          useValue: mockStepModel,
        },
        {
          provide: getModelToken('Plan'),
          useValue: mockPlanModel,
        },
      ],
    }).compile();

    stepService = module.get<StepService>(StepService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(stepService).toBeDefined();
  });

  describe('create', () => {
    it('should create and return new step', async () => {
      const result = await stepService.create(createStepDtos.validCreate);

      expect(mockStepModel).toHaveBeenCalledWith(createStepDtos.validCreate);
      expect(result.title).toBe(createStepDtos.validCreate.title);
      expect(result.description).toBe(createStepDtos.validCreate.description);
      expect(result.latitude).toBe(createStepDtos.validCreate.latitude);
      expect(result.longitude).toBe(createStepDtos.validCreate.longitude);
      expect(result.order).toBe(createStepDtos.validCreate.order);
      expect(result.image).toBe(createStepDtos.validCreate.image);
      expect(result.duration).toBe(createStepDtos.validCreate.duration);
      expect(result.cost).toBe(createStepDtos.validCreate.cost);
    });

    it('should create step with required fields only', async () => {
      const result = await stepService.create(createStepDtos.minimalCreate);

      expect(result.title).toBe(createStepDtos.minimalCreate.title);
      expect(result.description).toBe(createStepDtos.minimalCreate.description);
      expect(result.order).toBe(createStepDtos.minimalCreate.order);
      expect(result.image).toBe(createStepDtos.minimalCreate.image);
      expect(result.duration).toBe(createStepDtos.minimalCreate.duration);
      expect(result.cost).toBe(createStepDtos.minimalCreate.cost);
      expect(result.latitude).toBeUndefined();
      expect(result.longitude).toBeUndefined();
    });
  });

  describe('findAll', () => {
    it('should return array of steps', async () => {
      mockStepModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(validSteps),
      });

      const result = await stepService.findAll();

      expect(result).toEqual(validSteps);
      expect(Array.isArray(result)).toBe(true);
      expect(mockStepModel.find).toHaveBeenCalled();
    });

    it('should return empty array when no steps found', async () => {
      mockStepModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await stepService.findAll();

      expect(result).toEqual([]);
      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('findById', () => {
    it('should return step when found', async () => {
      const stepId = validSteps[0]._id;

      mockStepModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(validSteps[0]),
      });

      const result = await stepService.findById(stepId);

      expect(result).toEqual(validSteps[0]);
      expect(mockStepModel.findOne).toHaveBeenCalledWith({ _id: stepId });
    });

    it('should return undefined when step not found', async () => {
      const stepId = '507f1f77bcf86cd799439999';

      mockStepModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await stepService.findById(stepId);

      expect(result).toBeUndefined();
    });
  });

  describe('findByIds', () => {
    it('should return array of steps for given IDs', async () => {
      const stepIds = [validSteps[0]._id, validSteps[1]._id];
      const expectedSteps = [validSteps[0], validSteps[1]];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue(expectedSteps),
        }),
      });

      const result = await stepService.findByIds(stepIds);

      expect(result).toEqual(expectedSteps);
      expect(mockStepModel.find).toHaveBeenCalledWith({
        _id: { $in: stepIds },
      });
    });

    it('should return empty array for empty IDs array', async () => {
      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue([]),
        }),
      });

      const result = await stepService.findByIds([]);

      expect(result).toEqual([]);
    });
  });

  describe('updateById', () => {
    it('should update and return step', async () => {
      const stepId = validSteps[0]._id;
      const userId = 'user123';
      const updateData = updateStepDtos.fullUpdate;
      const updatedStep = { ...validSteps[0], ...updateData };

      mockStepModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedStep),
      });

      const result = await stepService.updateById(stepId, updateData, userId);

      expect(result).toEqual(updatedStep);
      expect(mockStepModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: stepId, userId },
        updateData,
        { new: true },
      );
    });

    it('should return null when step not found', async () => {
      const stepId = '507f1f77bcf86cd799439999';
      const userId = 'user123';
      const updateData = updateStepDtos.partialUpdate;

      mockStepModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await stepService.updateById(stepId, updateData, userId);

      expect(result).toBeNull();
    });
  });

  describe('removeById', () => {
    it('should delete and return step', async () => {
      const stepId = validSteps[0]._id;
      const deletedStep = validSteps[0];

      mockStepModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedStep),
      });

      const result = await stepService.removeById(stepId);

      expect(result).toEqual(deletedStep);
      expect(mockStepModel.findOneAndDelete).toHaveBeenCalledWith({
        _id: stepId,
      });
      expect(mockPlanModel.updateMany).toHaveBeenCalledWith(
        { steps: stepId },
        { $pull: { steps: stepId } },
      );
    });

    it('should return null when step not found', async () => {
      const stepId = '507f1f77bcf86cd799439999';

      mockStepModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await stepService.removeById(stepId);

      expect(result).toBeNull();
      expect(mockPlanModel.updateMany).not.toHaveBeenCalled();
    });
  });

  describe('calculateTotalDuration', () => {
    it('should calculate total duration of steps', async () => {
      const stepIds = [validSteps[0]._id, validSteps[1]._id];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue([
            { ...validSteps[0], duration: 60 },
            { ...validSteps[1], duration: 90 },
          ]),
        }),
      });

      const result = await stepService.calculateTotalDuration(stepIds);

      expect(result).toBe(150);
    });

    it('should handle steps with undefined duration', async () => {
      const stepIds = [validSteps[0]._id];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest
            .fn()
            .mockResolvedValue([{ ...validSteps[0], duration: undefined }]),
        }),
      });

      const result = await stepService.calculateTotalDuration(stepIds);

      expect(result).toBe(0);
    });
  });

  describe('calculateTotalCost', () => {
    it('should calculate total cost of steps', async () => {
      const stepIds = [validSteps[0]._id, validSteps[1]._id];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue([
            { ...validSteps[0], cost: 25.5 },
            { ...validSteps[1], cost: 30.25 },
          ]),
        }),
      });

      const result = await stepService.calculateTotalCost(stepIds);

      expect(result).toBe(55.75);
    });

    it('should handle steps with undefined cost', async () => {
      const stepIds = [validSteps[0]._id];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest
            .fn()
            .mockResolvedValue([{ ...validSteps[0], cost: undefined }]),
        }),
      });

      const result = await stepService.calculateTotalCost(stepIds);

      expect(result).toBe(0);
    });
  });
});
