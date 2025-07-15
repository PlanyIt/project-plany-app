import { Test, TestingModule } from '@nestjs/testing';
import { StepService } from './step.service';
import { getModelToken } from '@nestjs/mongoose';

describe('StepService', () => {
  let stepService: StepService;

  const mockSteps = [
    {
      _id: '507f1f77bcf86cd799439051',
      title: 'Visite de la Tour Eiffel',
      description: 'Montée au sommet de la Tour Eiffel avec vue panoramique',
      latitude: 48.8584,
      longitude: 2.2945,
      order: 1,
      image: 'eiffel-tower.jpg',
      duration: 120,
      cost: 25,
      userId: '507f1f77bcf86cd799439011',
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439052',
      title: 'Musée du Louvre',
      description: 'Visite guidée du plus grand musée du monde',
      latitude: 48.8606,
      longitude: 2.3376,
      order: 2,
      image: 'louvre-museum.jpg',
      duration: 180,
      cost: 15,
      userId: '507f1f77bcf86cd799439011',
      createdAt: new Date('2024-01-20T11:00:00.000Z'),
      updatedAt: new Date('2024-01-20T11:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439053',
      title: 'Séance de cardio',
      description: 'Entraînement cardiovasculaire intensif',
      order: 1,
      image: 'cardio-workout.jpg',
      duration: 45,
      cost: 0,
      userId: '507f1f77bcf86cd799439012',
      createdAt: new Date('2024-01-20T12:00:00.000Z'),
      updatedAt: new Date('2024-01-20T12:00:00.000Z'),
    },
  ];

  const createStepDto = {
    title: 'Nouvelle Étape',
    description: 'Description de la nouvelle étape',
    latitude: 48.8566,
    longitude: 2.3522,
    order: 3,
    image: 'new-step.jpg',
    duration: 60,
    cost: 10,
    userId: '507f1f77bcf86cd799439011',
  };

  const updateStepDto = {
    title: 'Étape Mise à Jour',
    description: 'Description mise à jour',
    latitude: 48.8567,
    longitude: 2.3523,
    order: 1,
    image: 'updated-step.jpg',
    duration: 90,
    cost: 12,
    userId: '507f1f77bcf86cd799439011',
  };

  const mockStepModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: mockSteps[0]._id,
    createdAt: mockSteps[0].createdAt,
    updatedAt: mockSteps[0].updatedAt,
    save: jest.fn().mockResolvedValue({
      _id: mockSteps[0]._id,
      ...dto,
      createdAt: mockSteps[0].createdAt,
      updatedAt: mockSteps[0].updatedAt,
    }),
  })) as any;

  mockStepModel.find = jest.fn().mockReturnValue({
    sort: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockStepModel.findOne = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockStepModel.findOneAndUpdate = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockStepModel.findOneAndDelete = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  const mockPlanModel = {
    updateMany: jest.fn(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

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

  it('should be defined', () => {
    expect(stepService).toBeDefined();
  });

  describe('create', () => {
    it('should create and return new step', async () => {
      const result = await stepService.create(createStepDto);

      expect(mockStepModel).toHaveBeenCalledWith(createStepDto);
      expect(result._id).toBe(mockSteps[0]._id);
      expect(result.title).toBe(createStepDto.title);
      expect(result.description).toBe(createStepDto.description);
      expect(result.order).toBe(createStepDto.order);
      expect(result.image).toBe(createStepDto.image);
      expect(result.duration).toBe(createStepDto.duration);
      expect(result.cost).toBe(createStepDto.cost);
    });

    it('should create step without optional fields', async () => {
      const minimalStepDto = {
        title: 'Step Minimal',
        description: 'Description minimale',
        order: 1,
        image: 'minimal.jpg',
        userId: '507f1f77bcf86cd799439011',
        duration: 3,
        location: null,
        cost: 0,
      };

      const result = await stepService.create(minimalStepDto);

      expect(result.title).toBe(minimalStepDto.title);
      expect(result.description).toBe(minimalStepDto.description);
      expect(result.order).toBe(minimalStepDto.order);
    });

    it('should create step with zero cost and duration', async () => {
      const stepWithZeros = {
        ...createStepDto,
        duration: 0,
        cost: 0,
      };

      const result = await stepService.create(stepWithZeros);

      expect(result.duration).toBe(0);
      expect(result.cost).toBe(0);
    });
  });

  describe('findAll', () => {
    it('should return all steps', async () => {
      mockStepModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockSteps),
      });

      const result = await stepService.findAll();

      expect(result).toEqual(mockSteps);
      expect(result).toHaveLength(3);
      expect(mockStepModel.find).toHaveBeenCalled();
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
      const stepId = mockSteps[0]._id;
      const expectedStep = mockSteps[0];

      mockStepModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedStep),
      });

      const result = await stepService.findById(stepId);

      expect(result).toEqual(expectedStep);
      expect(mockStepModel.findOne).toHaveBeenCalledWith({ _id: stepId });
    });

    it('should return undefined when step not found', async () => {
      mockStepModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await stepService.findById('nonexistent');

      expect(result).toBeUndefined();
    });
  });

  describe('findByIds', () => {
    it('should return steps sorted by order', async () => {
      const stepIds = [mockSteps[1]._id, mockSteps[0]._id];
      const expectedSteps = [mockSteps[0], mockSteps[1]];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(expectedSteps),
      });

      const result = await stepService.findByIds(stepIds);

      expect(result).toEqual(expectedSteps);
      expect(mockStepModel.find).toHaveBeenCalledWith({
        _id: { $in: stepIds },
      });
      expect(mockStepModel.find().sort).toHaveBeenCalledWith({ order: 1 });
    });

    it('should return empty array when no matching ids', async () => {
      const stepIds = ['nonexistent1', 'nonexistent2'];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await stepService.findByIds(stepIds);

      expect(result).toEqual([]);
    });

    it('should handle empty stepIds array', async () => {
      const stepIds: string[] = [];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await stepService.findByIds(stepIds);

      expect(result).toEqual([]);
      expect(mockStepModel.find).toHaveBeenCalledWith({ _id: { $in: [] } });
    });
  });

  describe('calculateTotalCost', () => {
    it('should calculate total cost of steps', async () => {
      const stepIds = [mockSteps[0]._id, mockSteps[1]._id];
      const stepsWithCost = [mockSteps[0], mockSteps[1]];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(stepsWithCost),
      });

      const result = await stepService.calculateTotalCost(stepIds);

      expect(result).toBe(40);
      expect(mockStepModel.find).toHaveBeenCalledWith({
        _id: { $in: stepIds },
      });
    });

    it('should handle steps with zero cost', async () => {
      const stepIds = [mockSteps[2]._id];
      const stepsWithZeroCost = [mockSteps[2]];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(stepsWithZeroCost),
      });

      const result = await stepService.calculateTotalCost(stepIds);

      expect(result).toBe(0);
    });

    it('should handle steps with undefined cost', async () => {
      const stepWithUndefinedCost = {
        ...mockSteps[0],
        cost: undefined,
      };

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([stepWithUndefinedCost]),
      });

      const result = await stepService.calculateTotalCost([mockSteps[0]._id]);

      expect(result).toBe(0);
    });

    it('should handle empty step array', async () => {
      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await stepService.calculateTotalCost([]);

      expect(result).toBe(0);
    });

    it('should handle mixed costs including nulls', async () => {
      const stepsWithMixedCosts = [
        { ...mockSteps[0], cost: 25 },
        { ...mockSteps[1], cost: null },
        { ...mockSteps[2], cost: 0 },
      ];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(stepsWithMixedCosts),
      });

      const result = await stepService.calculateTotalCost([
        'id1',
        'id2',
        'id3',
      ]);

      expect(result).toBe(25);
    });
  });

  describe('calculateTotalDuration', () => {
    it('should calculate total duration of steps', async () => {
      const stepIds = [mockSteps[0]._id, mockSteps[1]._id];
      const stepsWithDuration = [mockSteps[0], mockSteps[1]];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(stepsWithDuration),
      });

      const result = await stepService.calculateTotalDuration(stepIds);

      expect(result).toBe(300);
      expect(mockStepModel.find).toHaveBeenCalledWith({
        _id: { $in: stepIds },
      });
    });

    it('should handle steps with zero duration', async () => {
      const stepWithZeroDuration = {
        ...mockSteps[0],
        duration: 0,
      };

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([stepWithZeroDuration]),
      });

      const result = await stepService.calculateTotalDuration([
        mockSteps[0]._id,
      ]);

      expect(result).toBe(0);
    });

    it('should handle steps with undefined duration', async () => {
      const stepWithUndefinedDuration = {
        ...mockSteps[0],
        duration: undefined,
      };

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([stepWithUndefinedDuration]),
      });

      const result = await stepService.calculateTotalDuration([
        mockSteps[0]._id,
      ]);

      expect(result).toBe(0);
    });

    it('should handle empty step array', async () => {
      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await stepService.calculateTotalDuration([]);

      expect(result).toBe(0);
    });

    it('should handle mixed durations including nulls and decimals', async () => {
      const stepsWithMixedDurations = [
        { ...mockSteps[0], duration: 120.5 },
        { ...mockSteps[1], duration: null },
        { ...mockSteps[2], duration: 45 },
      ];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(stepsWithMixedDurations),
      });

      const result = await stepService.calculateTotalDuration([
        'id1',
        'id2',
        'id3',
      ]);

      expect(result).toBe(165.5);
    });
  });

  describe('updateById', () => {
    it('should update and return step when user is authorized', async () => {
      const stepId = mockSteps[0]._id;
      const userId = mockSteps[0].userId;
      const updatedStep = {
        ...mockSteps[0],
        ...updateStepDto,
      };

      mockStepModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedStep),
      });

      const result = await stepService.updateById(
        stepId,
        updateStepDto,
        userId,
      );

      expect(result).toEqual(updatedStep);
      expect(result.title).toBe(updateStepDto.title);
      expect(result.description).toBe(updateStepDto.description);
      expect(result.latitude).toBe(updateStepDto.latitude);
      expect(result.longitude).toBe(updateStepDto.longitude);
      expect(result.cost).toBe(updateStepDto.cost);
      expect(result.duration).toBe(updateStepDto.duration);
      expect(mockStepModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: stepId, userId },
        updateStepDto,
        { new: true },
      );
    });

    it('should return null when step not found', async () => {
      mockStepModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await stepService.updateById(
        'nonexistent',
        updateStepDto,
        'userId',
      );

      expect(result).toBeNull();
    });

    it('should return null when user is not authorized', async () => {
      const stepId = mockSteps[0]._id;
      const unauthorizedUserId = 'unauthorized';

      mockStepModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await stepService.updateById(
        stepId,
        updateStepDto,
        unauthorizedUserId,
      );

      expect(result).toBeNull();
      expect(mockStepModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: stepId, userId: unauthorizedUserId },
        updateStepDto,
        { new: true },
      );
    });

    it('should update step with partial data', async () => {
      const stepId = mockSteps[0]._id;
      const userId = mockSteps[0].userId;
      const partialUpdate = {
        title: 'Titre Modifié',
        description: mockSteps[0].description,
        order: mockSteps[0].order,
        image: mockSteps[0].image,
        userId: userId,
        cost: 20,
        duration: 90,
      };
      const updatedStep = {
        ...mockSteps[0],
        ...partialUpdate,
      };

      mockStepModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedStep),
      });

      const result = await stepService.updateById(
        stepId,
        partialUpdate,
        userId,
      );

      expect(result).toEqual(updatedStep);
      expect(result.title).toBe(partialUpdate.title);
      expect(result.cost).toBe(partialUpdate.cost);
      expect(result.duration).toBe(partialUpdate.duration);
    });
  });

  describe('removeById', () => {
    it('should delete step and remove from plans', async () => {
      const stepId = mockSteps[0]._id;
      const deletedStep = mockSteps[0];

      mockStepModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedStep),
      });

      mockPlanModel.updateMany.mockResolvedValue({
        modifiedCount: 2,
        matchedCount: 2,
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
      mockStepModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await stepService.removeById('nonexistent');

      expect(result).toBeNull();
      expect(mockStepModel.findOneAndDelete).toHaveBeenCalledWith({
        _id: 'nonexistent',
      });
      expect(mockPlanModel.updateMany).not.toHaveBeenCalled();
    });

    it('should delete step even if no plans reference it', async () => {
      const stepId = mockSteps[2]._id;
      const deletedStep = mockSteps[2];

      mockStepModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedStep),
      });

      mockPlanModel.updateMany.mockResolvedValue({
        modifiedCount: 0,
        matchedCount: 0,
      });

      const result = await stepService.removeById(stepId);

      expect(result).toEqual(deletedStep);
      expect(mockPlanModel.updateMany).toHaveBeenCalledWith(
        { steps: stepId },
        { $pull: { steps: stepId } },
      );
    });
  });

  describe('edge cases', () => {
    it('should handle step with no latitude/longitude', async () => {
      const stepWithoutLocation = {
        title: 'Step sans localisation',
        description: 'Étape virtuelle',
        order: 1,
        image: 'virtual.jpg',
        userId: '507f1f77bcf86cd799439011',
        location: null,
        duration: 30,
        cost: 5,
      };

      const result = await stepService.create(stepWithoutLocation);

      expect(result.title).toBe(stepWithoutLocation.title);
      expect(result.latitude).toBeUndefined();
      expect(result.longitude).toBeUndefined();
    });

    it('should handle step with zero cost', async () => {
      const freeStep = {
        ...createStepDto,
        cost: 0,
      };

      const result = await stepService.create(freeStep);

      expect(result.cost).toBe(0);
    });

    it('should handle step with very long description', async () => {
      const stepWithLongDesc = {
        ...createStepDto,
        description: 'A'.repeat(1000),
      };

      const result = await stepService.create(stepWithLongDesc);

      expect(result.description).toBe(stepWithLongDesc.description);
      expect(result.description.length).toBe(1000);
    });

    it('should handle findByIds with mixed existing and non-existing ids', async () => {
      const mixedIds = [mockSteps[0]._id, 'nonexistent', mockSteps[1]._id];
      const foundSteps = [mockSteps[0], mockSteps[1]];

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(foundSteps),
      });

      const result = await stepService.findByIds(mixedIds);

      expect(result).toEqual(foundSteps);
      expect(result).toHaveLength(2);
    });

    it('should handle extreme coordinate values', async () => {
      const extremeCoordStep = {
        ...createStepDto,
        latitude: -90,
        longitude: -180,
      };

      const result = await stepService.create(extremeCoordStep);

      expect(result.latitude).toBe(-90);
      expect(result.longitude).toBe(-180);
    });

    it('should handle very large duration values', async () => {
      const longDurationStep = {
        ...createStepDto,
        duration: 999999,
      };

      const result = await stepService.create(longDurationStep);

      expect(result.duration).toBe(999999);
    });

    it('should handle negative cost (edge case)', async () => {
      const negativeCostStep = {
        ...createStepDto,
        cost: -10,
      };

      const result = await stepService.create(negativeCostStep);

      expect(result.cost).toBe(-10);
    });

    it('should handle decimal duration and cost', async () => {
      const decimalStep = {
        ...createStepDto,
        duration: 45.5,
        cost: 12.99,
      };

      const result = await stepService.create(decimalStep);

      expect(result.duration).toBe(45.5);
      expect(result.cost).toBe(12.99);
    });
  });

  describe('Error handling', () => {
    it('should handle database errors in create', async () => {
      const mockSave = jest.fn().mockRejectedValue(new Error('Database error'));
      mockStepModel.mockImplementation(() => ({ save: mockSave }));

      await expect(stepService.create(createStepDto)).rejects.toThrow(
        'Database error',
      );
    });

    it('should handle database errors in findByIds', async () => {
      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockRejectedValue(new Error('Connection lost')),
      });

      await expect(stepService.findByIds([mockSteps[0]._id])).rejects.toThrow(
        'Connection lost',
      );
    });

    it('should handle plan update errors in removeById', async () => {
      const stepId = mockSteps[0]._id;

      mockStepModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockSteps[0]),
      });

      mockPlanModel.updateMany.mockRejectedValue(
        new Error('Plan update failed'),
      );

      await expect(stepService.removeById(stepId)).rejects.toThrow(
        'Plan update failed',
      );
    });
  });

  describe('Performance tests', () => {
    it('should handle large arrays in calculateTotalCost efficiently', async () => {
      const largeStepArray = Array.from({ length: 100 }, (_, i) => ({
        _id: `step-${i}`,
        cost: i,
        duration: i * 10,
      }));

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(largeStepArray),
      });

      const stepIds = largeStepArray.map((s) => s._id);
      const result = await stepService.calculateTotalCost(stepIds);

      expect(result).toBe(4950);
    });

    it('should handle large arrays in calculateTotalDuration efficiently', async () => {
      const largeStepArray = Array.from({ length: 50 }, (_, i) => ({
        _id: `step-${i}`,
        cost: 10,
        duration: 60,
      }));

      mockStepModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(largeStepArray),
      });

      const stepIds = largeStepArray.map((s) => s._id);
      const result = await stepService.calculateTotalDuration(stepIds);

      expect(result).toBe(3000);
    });
  });
});
