import { Test, TestingModule } from '@nestjs/testing';
import { StepService } from '../../../src/step/step.service';
import { getModelToken } from '@nestjs/mongoose';
import * as stepFixtures from '../../__fixtures__/steps.json';

describe('StepService', () => {
  let stepService: StepService;

  const {
    validSteps,
    createStepDtos,
    updateStepDtos,
    stepsForPlan,
    specialCases,
  } = stepFixtures;

  const mockStepModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: validSteps[0]._id,
    createdAt: new Date(validSteps[0].createdAt),
    updatedAt: new Date(validSteps[0].updatedAt),
    save: jest.fn().mockResolvedValue({
      _id: validSteps[0]._id,
      ...dto,
      createdAt: new Date(validSteps[0].createdAt),
      updatedAt: new Date(validSteps[0].updatedAt),
    }),
  })) as any;

  const mockPlanModel = jest.fn().mockImplementation(() => ({})) as any;

  mockStepModel.find = jest.fn();
  mockStepModel.findOne = jest.fn();
  mockStepModel.findOneAndUpdate = jest.fn();
  mockStepModel.findOneAndDelete = jest.fn();
  mockStepModel.sort = jest.fn();
  mockStepModel.exec = jest.fn();
  mockPlanModel.updateMany = jest.fn();

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
  });

  afterEach(() => {
    jest.clearAllMocks();
    mockStepModel.find.mockReset();
    mockStepModel.findOne.mockReset();
    mockStepModel.findOneAndUpdate.mockReset();
    mockStepModel.findOneAndDelete.mockReset();
    mockPlanModel.updateMany.mockReset();
  });

  it('should be defined', () => {
    expect(stepService).toBeDefined();
  });

  describe('create', () => {
    it('should create and return new step', async () => {
      const result = await stepService.create(createStepDtos.validCreate);

      expect(mockStepModel).toHaveBeenCalledWith(createStepDtos.validCreate);
      expect(result._id).toBe(validSteps[0]._id);
      expect(result.title).toBe(createStepDtos.validCreate.title);
      expect(result.description).toBe(createStepDtos.validCreate.description);
      expect(result.latitude).toBe(createStepDtos.validCreate.latitude);
      expect(result.longitude).toBe(createStepDtos.validCreate.longitude);
      expect(result.order).toBe(createStepDtos.validCreate.order);
      expect(result.image).toBe(createStepDtos.validCreate.image);
      expect(result.duration).toBe(createStepDtos.validCreate.duration);
      expect(result.cost).toBe(createStepDtos.validCreate.cost);
      expect(result.userId).toBe(createStepDtos.validCreate.userId);
    });

    it('should create step with required fields only', async () => {
      const result = await stepService.create(createStepDtos.minimalCreate);

      expect(result.title).toBe(createStepDtos.minimalCreate.title);
      expect(result.description).toBe(createStepDtos.minimalCreate.description);
      expect(result.order).toBe(createStepDtos.minimalCreate.order);
      expect(result.image).toBe(createStepDtos.minimalCreate.image);
      expect(result.userId).toBe(createStepDtos.minimalCreate.userId);
      expect(result.latitude).toBeUndefined();
      expect(result.longitude).toBeUndefined();
      expect(result.duration).toBeUndefined();
      expect(result.cost).toBeUndefined();
    });

    it('should create step without coordinates', async () => {
      const result = await stepService.create(createStepDtos.withoutLocation);

      expect(result.title).toBe(createStepDtos.withoutLocation.title);
      expect(result.duration).toBe(createStepDtos.withoutLocation.duration);
      expect(result.cost).toBe(createStepDtos.withoutLocation.cost);
      expect(result.latitude).toBeUndefined();
      expect(result.longitude).toBeUndefined();
    });

    it('should create step with decimal cost', async () => {
      const result = await stepService.create(createStepDtos.expensiveStep);

      expect(result.cost).toBe(createStepDtos.expensiveStep.cost);
      expect(result.duration).toBe(createStepDtos.expensiveStep.duration);
    });
  });

  describe('findAll', () => {
    it('should return all steps', async () => {
      mockStepModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(validSteps),
      });

      const result = await stepService.findAll();

      expect(result).toEqual(validSteps);
      expect(result).toHaveLength(validSteps.length);
      expect(mockStepModel.find).toHaveBeenCalled();
      expect(result[0].title).toBe(validSteps[0].title);
      expect(result[1].title).toBe(validSteps[1].title);
      expect(result[2].title).toBe(validSteps[2].title);
    });

    it('should return empty array when no steps', async () => {
      mockStepModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await stepService.findAll();

      expect(result).toEqual([]);
      expect(result).toHaveLength(0);
    });
  });

  describe('findById', () => {
    it('should return step when found', async () => {
      const stepId = validSteps[0]._id;
      const expectedStep = validSteps[0];

      mockStepModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedStep),
      });

      const result = await stepService.findById(stepId);

      expect(result).toEqual(expectedStep);
      expect(mockStepModel.findOne).toHaveBeenCalledWith({ _id: stepId });
      expect(result.title).toBe(expectedStep.title);
      expect(result.latitude).toBe(expectedStep.latitude);
      expect(result.longitude).toBe(expectedStep.longitude);
      expect(result.duration).toBe(expectedStep.duration);
      expect(result.cost).toBe(expectedStep.cost);
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
    it('should return steps by IDs sorted by order', async () => {
      const stepIds = stepsForPlan.map((step) => step._id);

      const mockChain = {
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(stepsForPlan),
      };

      mockStepModel.find.mockReturnValue(mockChain);

      const result = await stepService.findByIds(stepIds);

      expect(result).toEqual(stepsForPlan);
      expect(mockStepModel.find).toHaveBeenCalledWith({
        _id: { $in: stepIds },
      });
      expect(mockChain.sort).toHaveBeenCalledWith({ order: 1 });
      expect(result[0].order).toBe(1);
      expect(result[1].order).toBe(2);
      expect(result[2].order).toBe(3);
    });

    it('should return empty array when no steps found for IDs', async () => {
      const stepIds = ['507f1f77bcf86cd799439999', '507f1f77bcf86cd799439998'];

      const mockChain = {
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      };

      mockStepModel.find.mockReturnValue(mockChain);

      const result = await stepService.findByIds(stepIds);

      expect(result).toEqual([]);
    });
  });

  describe('updateById', () => {
    it('should update step for owner', async () => {
      const stepId = validSteps[0]._id;
      const userId = validSteps[0].userId;
      const updateData = updateStepDtos.fullUpdate;

      const updatedStep = {
        _id: stepId,
        ...updateData,
        order: 1,
        image: 'https://example.com/image.jpg',
        userId,
      };

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
      expect(result.title).toBe(updateData.title);
      expect(result.duration).toBe(updateData.duration);
      expect(result.cost).toBe(updateData.cost);
    });

    it('should handle partial updates', async () => {
      const stepId = validSteps[0]._id;
      const userId = validSteps[0].userId;
      const updateData = updateStepDtos.partialUpdate;

      const updatedStep = {
        _id: stepId,
        title: updateData.title,
        description: 'Ancienne description',
        order: 1,
        image: 'old-image.jpg',
        duration: '2h',
        cost: updateData.cost,
        userId,
      };

      mockStepModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedStep),
      });

      const result = await stepService.updateById(stepId, updateData, userId);

      expect(result.title).toBe(updateData.title);
      expect(result.cost).toBe(updateData.cost);
      expect(result.description).toBe('Ancienne description');
    });

    it('should update coordinates', async () => {
      const stepId = validSteps[0]._id;
      const userId = validSteps[0].userId;
      const updateData = updateStepDtos.locationUpdate;

      const updatedStep = {
        _id: stepId,
        ...updateData,
        description: 'Description',
        order: 1,
        image: 'image.jpg',
        userId,
      };

      mockStepModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedStep),
      });

      const result = await stepService.updateById(stepId, updateData, userId);

      expect(result.latitude).toBe(updateData.latitude);
      expect(result.longitude).toBe(updateData.longitude);
      expect(result.title).toBe(updateData.title);
    });

    it('should return null when step not found or user not owner', async () => {
      const stepId = validSteps[0]._id;
      const wrongUserId = '507f1f77bcf86cd799439999';
      const updateData = updateStepDtos.partialUpdate;

      mockStepModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await stepService.updateById(
        stepId,
        updateData,
        wrongUserId,
      );

      expect(result).toBeNull();
    });
  });

  describe('removeById', () => {
    it('should delete step and remove from plans', async () => {
      const stepId = validSteps[0]._id;
      const deletedStep = {
        _id: stepId,
        title: 'Étape à supprimer',
        description: 'Cette étape sera supprimée',
        order: 1,
        image: 'step-to-delete.jpg',
        userId: validSteps[0].userId,
      };

      mockStepModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedStep),
      });

      mockPlanModel.updateMany.mockResolvedValue({
        acknowledged: true,
        modifiedCount: 2,
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

    it('should return null when step not found for deletion', async () => {
      const stepId = '507f1f77bcf86cd799439999';

      mockStepModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await stepService.removeById(stepId);

      expect(result).toBeNull();
      expect(mockPlanModel.updateMany).not.toHaveBeenCalled();
    });
  });

  describe('special cases', () => {
    it('should handle step with zero cost', async () => {
      const zeroCostStep = specialCases.zeroCost;

      const result = await stepService.create(zeroCostStep);

      expect(result.cost).toBe(0);
      expect(result.title).toBe(zeroCostStep.title);
    });

    it('should handle step with negative coordinates', async () => {
      const negativeCoordStep = specialCases.negativeCoordinates;

      const result = await stepService.create(negativeCoordStep);

      expect(result.latitude).toBe(negativeCoordStep.latitude);
      expect(result.longitude).toBe(negativeCoordStep.longitude);
    });

    it('should handle step with long duration string', async () => {
      const longDurationStep = specialCases.longDuration;

      const result = await stepService.create(longDurationStep);

      expect(result.duration).toBe(longDurationStep.duration);
    });
  });
});
