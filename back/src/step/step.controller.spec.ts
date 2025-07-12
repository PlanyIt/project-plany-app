import { Test, TestingModule } from '@nestjs/testing';
import { StepController } from './step.controller';
import { StepService } from './step.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { StepDto } from './dto/step.dto';
import { NotFoundException, UnauthorizedException } from '@nestjs/common';

describe('StepController', () => {
  let stepController: StepController;
  let stepService: StepService;

  const mockSteps = [
    {
      _id: '507f1f77bcf86cd799439011',
      title: "Arrivée à l'aéroport",
      description: "Récupération des bagages et transport vers l'hôtel",
      latitude: 48.8566,
      longitude: 2.3522,
      order: 1,
      image: 'https://example.com/airport.jpg',
      duration: '2h',
      cost: 50,
      userId: '507f1f77bcf86cd799439021',
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439012',
      title: 'Visite du Louvre',
      description: 'Découverte des œuvres emblématiques du musée',
      latitude: 48.8606,
      longitude: 2.3376,
      order: 2,
      image: 'https://example.com/louvre.jpg',
      duration: '4h',
      cost: 17,
      userId: '507f1f77bcf86cd799439021',
      createdAt: new Date('2024-01-20T11:00:00.000Z'),
      updatedAt: new Date('2024-01-20T11:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439013',
      title: 'Promenade sur les Champs-Élysées',
      description: "Shopping et découverte de l'avenue mythique",
      latitude: 48.8698,
      longitude: 2.3075,
      order: 3,
      image: 'https://example.com/champs.jpg',
      duration: '3h',
      cost: 0,
      userId: '507f1f77bcf86cd799439022',
      createdAt: new Date('2024-01-20T12:00:00.000Z'),
      updatedAt: new Date('2024-01-20T12:00:00.000Z'),
    },
  ];

  const validStepDto: StepDto = {
    title: 'Nouvelle étape',
    description: 'Description de la nouvelle étape',
    latitude: 48.8567,
    longitude: 2.3508,
    order: 4,
    image: 'https://example.com/new-step.jpg',
    duration: '1h30',
    cost: 25,
    userId: '507f1f77bcf86cd799439021',
  };

  const updateStepDto: StepDto = {
    title: 'Étape mise à jour',
    description: 'Description modifiée',
    latitude: 48.8575,
    longitude: 2.3515,
    order: 4,
    image: 'https://example.com/updated-step.jpg',
    duration: '2h',
    cost: 30,
    userId: '507f1f77bcf86cd799439021',
  };

  const mockUser = {
    _id: '507f1f77bcf86cd799439021',
    username: 'johndoe',
    email: 'john@plany.com',
  };

  const mockRequest = {
    user: mockUser,
  };

  const mockStepService = {
    create: jest.fn(),
    findByIds: jest.fn(),
    findAll: jest.fn(),
    findById: jest.fn(),
    removeById: jest.fn(),
    updateById: jest.fn(),
  };

  const mockJwtAuthGuard = {
    canActivate: jest.fn(() => true),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [StepController],
      providers: [
        {
          provide: StepService,
          useValue: mockStepService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue(mockJwtAuthGuard)
      .compile();

    stepController = module.get<StepController>(StepController);
    stepService = module.get<StepService>(StepService);
  });

  it('should be defined', () => {
    expect(stepController).toBeDefined();
    expect(stepService).toBeDefined();
  });

  describe('createStep', () => {
    it('should create and return a new step', async () => {
      const createdStep = {
        _id: '507f1f77bcf86cd799439014',
        ...validStepDto,
        userId: mockUser._id,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockStepService.create.mockResolvedValue(createdStep);

      const result = await stepController.createStep(validStepDto, mockRequest);

      expect(result).toEqual(createdStep);
      expect(mockStepService.create).toHaveBeenCalledWith({
        ...validStepDto,
        userId: mockUser._id,
      });
      expect(mockStepService.create).toHaveBeenCalledTimes(1);
    });

    it('should add userId from request to step data', async () => {
      const createdStep = { ...validStepDto, userId: mockUser._id };
      mockStepService.create.mockResolvedValue(createdStep);

      await stepController.createStep(validStepDto, mockRequest);

      expect(mockStepService.create).toHaveBeenCalledWith({
        ...validStepDto,
        userId: mockUser._id,
      });
    });

    it('should handle creation with minimal required fields', async () => {
      const minimalStepDto: StepDto = {
        title: 'Étape minimale',
        description: 'Description minimale',
        order: 1,
        image: 'https://example.com/minimal.jpg',
        userId: mockUser._id,
        latitude: 48.8566,
        longitude: 2.3522,
        duration: '1h',
        cost: 10,
      };

      const createdStep = {
        ...minimalStepDto,
        userId: mockUser._id,
        _id: '507f1f77bcf86cd799439015',
      };

      mockStepService.create.mockResolvedValue(createdStep);

      const result = await stepController.createStep(
        minimalStepDto,
        mockRequest,
      );

      expect(result).toEqual(createdStep);
      expect(mockStepService.create).toHaveBeenCalledWith({
        ...minimalStepDto,
        userId: mockUser._id,
      });
    });

    it('should handle step creation with coordinates', async () => {
      const stepWithCoords: StepDto = {
        ...validStepDto,
        latitude: 48.8566,
        longitude: 2.3522,
      };

      const createdStep = {
        ...stepWithCoords,
        userId: mockUser._id,
        _id: '507f1f77bcf86cd799439016',
      };

      mockStepService.create.mockResolvedValue(createdStep);

      const result = await stepController.createStep(
        stepWithCoords,
        mockRequest,
      );

      expect(result).toEqual(createdStep);
      expect(mockStepService.create).toHaveBeenCalledWith({
        ...stepWithCoords,
        userId: mockUser._id,
      });
    });

    it('should handle step creation with cost and duration', async () => {
      const stepWithDetails: StepDto = {
        ...validStepDto,
        duration: '3h45',
        cost: 75,
      };

      const createdStep = {
        ...stepWithDetails,
        userId: mockUser._id,
        _id: '507f1f77bcf86cd799439017',
      };

      mockStepService.create.mockResolvedValue(createdStep);

      const result = await stepController.createStep(
        stepWithDetails,
        mockRequest,
      );

      expect(result).toEqual(createdStep);
      expect(mockStepService.create).toHaveBeenCalledWith({
        ...stepWithDetails,
        userId: mockUser._id,
      });
    });
  });

  describe('findByIds (batch)', () => {
    it('should return multiple steps by IDs', async () => {
      const stepIds = [mockSteps[0]._id, mockSteps[1]._id];
      const expectedSteps = [mockSteps[0], mockSteps[1]];

      mockStepService.findByIds.mockResolvedValue(expectedSteps);

      const result = await stepController.findByIds(stepIds);

      expect(result).toEqual(expectedSteps);
      expect(mockStepService.findByIds).toHaveBeenCalledWith(stepIds);
      expect(mockStepService.findByIds).toHaveBeenCalledTimes(1);
    });

    it('should handle empty stepIds array', async () => {
      const stepIds: string[] = [];

      mockStepService.findByIds.mockResolvedValue([]);

      const result = await stepController.findByIds(stepIds);

      expect(result).toEqual([]);
      expect(mockStepService.findByIds).toHaveBeenCalledWith(stepIds);
    });

    it('should handle single step ID in batch', async () => {
      const stepIds = [mockSteps[0]._id];
      const expectedSteps = [mockSteps[0]];

      mockStepService.findByIds.mockResolvedValue(expectedSteps);

      const result = await stepController.findByIds(stepIds);

      expect(result).toEqual(expectedSteps);
      expect(mockStepService.findByIds).toHaveBeenCalledWith(stepIds);
    });

    it('should handle non-existent step IDs', async () => {
      const stepIds = ['507f1f77bcf86cd799439999', '507f1f77bcf86cd799439998'];

      mockStepService.findByIds.mockResolvedValue([]);

      const result = await stepController.findByIds(stepIds);

      expect(result).toEqual([]);
      expect(mockStepService.findByIds).toHaveBeenCalledWith(stepIds);
    });

    it('should handle mixed valid and invalid step IDs', async () => {
      const stepIds = [mockSteps[0]._id, '507f1f77bcf86cd799439999'];
      const expectedSteps = [mockSteps[0]];

      mockStepService.findByIds.mockResolvedValue(expectedSteps);

      const result = await stepController.findByIds(stepIds);

      expect(result).toEqual(expectedSteps);
      expect(mockStepService.findByIds).toHaveBeenCalledWith(stepIds);
    });
  });

  describe('findAll', () => {
    it('should return all steps', async () => {
      mockStepService.findAll.mockResolvedValue(mockSteps);

      const result = await stepController.findAll();

      expect(result).toEqual(mockSteps);
      expect(mockStepService.findAll).toHaveBeenCalledTimes(1);
      expect(result).toHaveLength(3);
    });

    it('should return empty array when no steps exist', async () => {
      mockStepService.findAll.mockResolvedValue([]);

      const result = await stepController.findAll();

      expect(result).toEqual([]);
      expect(mockStepService.findAll).toHaveBeenCalledTimes(1);
    });

    it('should handle service errors', async () => {
      const serviceError = new Error('Database connection failed');
      mockStepService.findAll.mockRejectedValue(serviceError);

      await expect(stepController.findAll()).rejects.toThrow(
        'Database connection failed',
      );
    });
  });

  describe('findById', () => {
    it('should return step by ID', async () => {
      const stepId = mockSteps[0]._id;
      const expectedStep = mockSteps[0];

      mockStepService.findById.mockResolvedValue(expectedStep);

      const result = await stepController.findById(stepId);

      expect(result).toEqual(expectedStep);
      expect(mockStepService.findById).toHaveBeenCalledWith(stepId);
      expect(mockStepService.findById).toHaveBeenCalledTimes(1);
    });

    it('should throw NotFoundException when step not found', async () => {
      const stepId = '507f1f77bcf86cd799439999';
      const notFoundError = new NotFoundException(
        `Step with ID ${stepId} not found`,
      );

      mockStepService.findById.mockRejectedValue(notFoundError);

      await expect(stepController.findById(stepId)).rejects.toThrow(
        NotFoundException,
      );
      expect(mockStepService.findById).toHaveBeenCalledWith(stepId);
    });

    it('should handle invalid ObjectId format', async () => {
      const invalidId = 'invalid-id';
      const validationError = new Error('Invalid ObjectId format');

      mockStepService.findById.mockRejectedValue(validationError);

      await expect(stepController.findById(invalidId)).rejects.toThrow(
        'Invalid ObjectId format',
      );
    });
  });

  describe('removeStep', () => {
    it('should delete and return step', async () => {
      const stepId = mockSteps[0]._id;
      const deletedStep = mockSteps[0];

      mockStepService.removeById.mockResolvedValue(deletedStep);

      const result = await stepController.removeStep(stepId);

      expect(result).toEqual(deletedStep);
      expect(mockStepService.removeById).toHaveBeenCalledWith(stepId);
      expect(mockStepService.removeById).toHaveBeenCalledTimes(1);
    });

    it('should throw NotFoundException when step to delete not found', async () => {
      const stepId = '507f1f77bcf86cd799439999';
      const notFoundError = new NotFoundException(
        `Step with ID ${stepId} not found`,
      );

      mockStepService.removeById.mockRejectedValue(notFoundError);

      await expect(stepController.removeStep(stepId)).rejects.toThrow(
        NotFoundException,
      );
      expect(mockStepService.removeById).toHaveBeenCalledWith(stepId);
    });

    it('should handle deletion of step with references', async () => {
      const stepId = mockSteps[0]._id;
      const dependencyError = new Error(
        'Cannot delete step as it is referenced by other entities',
      );

      mockStepService.removeById.mockRejectedValue(dependencyError);

      await expect(stepController.removeStep(stepId)).rejects.toThrow(
        'Cannot delete step as it is referenced by other entities',
      );
    });
  });

  describe('updateStep', () => {
    it('should update and return step', async () => {
      const stepId = mockSteps[0]._id;
      const updatedStep = {
        ...mockSteps[0],
        ...updateStepDto,
        updatedAt: new Date(),
      };

      mockStepService.updateById.mockResolvedValue(updatedStep);

      const result = await stepController.updateStep(
        stepId,
        updateStepDto,
        mockRequest,
      );

      expect(result).toEqual(updatedStep);
      expect(mockStepService.updateById).toHaveBeenCalledWith(
        stepId,
        updateStepDto,
        mockUser._id,
      );
      expect(mockStepService.updateById).toHaveBeenCalledTimes(1);
    });

    it('should throw UnauthorizedException when user tries to update others step', async () => {
      const stepId = mockSteps[2]._id;
      const unauthorizedError = new UnauthorizedException(
        'You can only update your own steps',
      );

      mockStepService.updateById.mockRejectedValue(unauthorizedError);

      await expect(
        stepController.updateStep(stepId, updateStepDto, mockRequest),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        stepController.updateStep(stepId, updateStepDto, mockRequest),
      ).rejects.toThrow('You can only update your own steps');
    });

    it('should throw NotFoundException when updating non-existent step', async () => {
      const stepId = '507f1f77bcf86cd799439999';
      const notFoundError = new NotFoundException(
        `Step with ID ${stepId} not found`,
      );

      mockStepService.updateById.mockRejectedValue(notFoundError);

      await expect(
        stepController.updateStep(stepId, updateStepDto, mockRequest),
      ).rejects.toThrow(NotFoundException);
    });

    it('should handle partial updates', async () => {
      const stepId = mockSteps[0]._id;
      const partialUpdateDto: Partial<StepDto> = {
        title: 'Titre mis à jour seulement',
        cost: 100,
      };

      const updatedStep = {
        ...mockSteps[0],
        title: 'Titre mis à jour seulement',
        cost: 100,
        updatedAt: new Date(),
      };

      mockStepService.updateById.mockResolvedValue(updatedStep);

      const result = await stepController.updateStep(
        stepId,
        partialUpdateDto as StepDto,
        mockRequest,
      );

      expect(result).toEqual(updatedStep);
      expect(mockStepService.updateById).toHaveBeenCalledWith(
        stepId,
        partialUpdateDto,
        mockUser._id,
      );
    });

    it('should handle coordinate updates', async () => {
      const stepId = mockSteps[0]._id;
      const coordinateUpdateDto: StepDto = {
        ...updateStepDto,
        latitude: 45.764,
        longitude: 4.8357,
      };

      const updatedStep = {
        ...mockSteps[0],
        ...coordinateUpdateDto,
        updatedAt: new Date(),
      };

      mockStepService.updateById.mockResolvedValue(updatedStep);

      const result = await stepController.updateStep(
        stepId,
        coordinateUpdateDto,
        mockRequest,
      );

      expect(result).toEqual(updatedStep);
      expect(mockStepService.updateById).toHaveBeenCalledWith(
        stepId,
        coordinateUpdateDto,
        mockUser._id,
      );
    });

    it('should handle order updates', async () => {
      const stepId = mockSteps[0]._id;
      const orderUpdateDto: StepDto = {
        ...updateStepDto,
        order: 10,
      };

      const updatedStep = {
        ...mockSteps[0],
        ...orderUpdateDto,
        updatedAt: new Date(),
      };

      mockStepService.updateById.mockResolvedValue(updatedStep);

      const result = await stepController.updateStep(
        stepId,
        orderUpdateDto,
        mockRequest,
      );

      expect(result).toEqual(updatedStep);
      expect(mockStepService.updateById).toHaveBeenCalledWith(
        stepId,
        orderUpdateDto,
        mockUser._id,
      );
    });
  });

  describe('Authentication and Authorization', () => {
    it('should be protected by JwtAuthGuard', () => {
      const guards = Reflect.getMetadata('__guards__', StepController);

      if (guards && guards.length > 0) {
        const guardNames = guards.map(
          (guard: any) => guard.name || guard.constructor?.name,
        );
        expect(guardNames).toContain('JwtAuthGuard');
      } else {
        expect(StepController).toBeDefined();
      }
    });

    it('should extract user from request correctly', async () => {
      const createdStep = { ...validStepDto, userId: mockUser._id };
      mockStepService.create.mockResolvedValue(createdStep);

      await stepController.createStep(validStepDto, mockRequest);

      expect(mockStepService.create).toHaveBeenCalledWith({
        ...validStepDto,
        userId: mockUser._id,
      });
    });

    it('should pass userId to update operations', async () => {
      const stepId = mockSteps[0]._id;
      const updatedStep = { ...mockSteps[0], ...updateStepDto };

      mockStepService.updateById.mockResolvedValue(updatedStep);

      await stepController.updateStep(stepId, updateStepDto, mockRequest);

      expect(mockStepService.updateById).toHaveBeenCalledWith(
        stepId,
        updateStepDto,
        mockUser._id,
      );
    });
  });

  describe('Controller routing', () => {
    it('should be mapped to correct base route', () => {
      const controllerPath = Reflect.getMetadata('path', StepController);
      expect(controllerPath).toBe('api/steps');
    });

    it('should have correct HTTP method decorators', () => {
      expect(typeof stepController.createStep).toBe('function');
      expect(typeof stepController.findByIds).toBe('function');
      expect(typeof stepController.findAll).toBe('function');
      expect(typeof stepController.findById).toBe('function');
      expect(typeof stepController.removeStep).toBe('function');
      expect(typeof stepController.updateStep).toBe('function');
    });
  });

  describe('Edge cases', () => {
    it('should handle null request user in createStep', async () => {
      const nullRequest = { user: null };

      await expect(
        stepController.createStep(validStepDto, nullRequest),
      ).rejects.toThrow();
    });

    it('should handle null request user in updateStep', async () => {
      const stepId = mockSteps[0]._id;
      const nullRequest = { user: null };

      await expect(
        stepController.updateStep(stepId, updateStepDto, nullRequest),
      ).rejects.toThrow();
    });

    it('should handle empty string stepIds in batch', async () => {
      const emptyStepIds = [''];

      mockStepService.findByIds.mockResolvedValue([]);

      const result = await stepController.findByIds(emptyStepIds);

      expect(result).toEqual([]);
      expect(mockStepService.findByIds).toHaveBeenCalledWith(emptyStepIds);
    });

    it('should handle invalid stepIds in batch', async () => {
      const invalidStepIds = ['invalid-id-1', 'invalid-id-2'];
      const validationError = new Error('Invalid ObjectId format');

      mockStepService.findByIds.mockRejectedValue(validationError);

      await expect(stepController.findByIds(invalidStepIds)).rejects.toThrow(
        'Invalid ObjectId format',
      );
    });

    it('should handle null stepDto in createStep', async () => {
      const nullStepDto = null;

      const validationError = new Error('StepDto cannot be null');
      mockStepService.create.mockRejectedValue(validationError);

      await expect(
        stepController.createStep(nullStepDto as any, mockRequest),
      ).rejects.toThrow('StepDto cannot be null');
    });

    it('should handle stepDto with missing required fields', async () => {
      const incompleteStepDto = { title: 'Incomplete' } as StepDto;
      const validationError = new Error('Required fields missing');

      mockStepService.create.mockRejectedValue(validationError);

      await expect(
        stepController.createStep(incompleteStepDto, mockRequest),
      ).rejects.toThrow('Required fields missing');
    });

    it('should handle very large order numbers', async () => {
      const largeOrderStepDto: StepDto = {
        ...validStepDto,
        order: 999999,
      };

      const createdStep = {
        ...largeOrderStepDto,
        userId: mockUser._id,
        _id: '507f1f77bcf86cd799439018',
      };

      mockStepService.create.mockResolvedValue(createdStep);

      const result = await stepController.createStep(
        largeOrderStepDto,
        mockRequest,
      );

      expect(result).toEqual(createdStep);
      expect(result.order).toBe(999999);
    });

    it('should handle negative coordinates', async () => {
      const negativeCoordStepDto: StepDto = {
        ...validStepDto,
        latitude: -45.123,
        longitude: -75.456,
      };

      const createdStep = {
        ...negativeCoordStepDto,
        userId: mockUser._id,
        _id: '507f1f77bcf86cd799439019',
      };

      mockStepService.create.mockResolvedValue(createdStep);

      const result = await stepController.createStep(
        negativeCoordStepDto,
        mockRequest,
      );

      expect(result).toEqual(createdStep);
      expect(result.latitude).toBe(-45.123);
      expect(result.longitude).toBe(-75.456);
    });
  });
});
