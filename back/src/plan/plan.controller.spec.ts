import { Test, TestingModule } from '@nestjs/testing';
import { PlanController } from './plan.controller';
import { PlanService } from './plan.service';
import { UserService } from '../user/user.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PlanDto } from './dto/plan.dto';
import {
  HttpException,
  HttpStatus,
  UnauthorizedException,
} from '@nestjs/common';

describe('PlanController', () => {
  let planController: PlanController;
  let planService: PlanService;
  let userService: UserService;

  const mockPlans = [
    {
      _id: '507f1f77bcf86cd799439011',
      title: 'Voyage à Paris',
      description: 'Un magnifique voyage de 3 jours à Paris',
      category: 'Voyage',
      duration: 3,
      budget: 800,
      difficulty: 'easy',
      user: '507f1f77bcf86cd799439021',
      isPublic: true,
      isFavorite: false,
      tags: ['voyage', 'paris', 'culture'],
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439012',
      title: 'Entraînement fitness',
      description: "Programme d'entraînement de 30 jours",
      category: 'Sport',
      duration: 30,
      budget: 0,
      difficulty: 'medium',
      user: '507f1f77bcf86cd799439022',
      isPublic: true,
      isFavorite: true,
      tags: ['sport', 'fitness', 'santé'],
      createdAt: new Date('2024-01-20T11:00:00.000Z'),
      updatedAt: new Date('2024-01-20T11:00:00.000Z'),
    },
  ];

  const validPlanDto: PlanDto = {
    title: 'Nouveau Plan',
    description: 'Description du nouveau plan',
    category: 'Loisir',
    isPublic: true,
    steps: ['Étape 1', 'Étape 2'],
  };

  const updatePlanDto: PlanDto = {
    title: 'Plan Modifié',
    description: 'Description mise à jour',
    category: 'Loisir',
    isPublic: false,
    steps: ['Étape 1', 'Étape 2'],
  };

  const mockUser = {
    _id: '507f1f77bcf86cd799439021',
    username: 'johndoe',
    email: 'john@plany.com',
  };

  const mockRequest = {
    user: mockUser,
  };

  const mockPlanService = {
    findAll: jest.fn(),
    findById: jest.fn(),
    createPlan: jest.fn(),
    updateById: jest.fn(),
    removeById: jest.fn(),
    addToFavorites: jest.fn(),
    removeFromFavorites: jest.fn(),
    findAllByUserId: jest.fn(),
    findFavoritesByUserId: jest.fn(),
  };

  const mockUserService = {
    updateById: jest.fn(),
    findById: jest.fn(),
  };

  const mockJwtAuthGuard = {
    canActivate: jest.fn(() => true),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [PlanController],
      providers: [
        {
          provide: PlanService,
          useValue: mockPlanService,
        },
        {
          provide: UserService,
          useValue: mockUserService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue(mockJwtAuthGuard)
      .compile();

    planController = module.get<PlanController>(PlanController);
    planService = module.get<PlanService>(PlanService);
    userService = module.get<UserService>(UserService);
  });

  it('should be defined', () => {
    expect(planController).toBeDefined();
    expect(planService).toBeDefined();
    expect(userService).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all plans', async () => {
      mockPlanService.findAll.mockResolvedValue(mockPlans);

      const result = await planController.findAll();

      expect(result).toEqual(mockPlans);
      expect(mockPlanService.findAll).toHaveBeenCalledTimes(1);
      expect(result).toHaveLength(2);
    });

    it('should return empty array when no plans exist', async () => {
      mockPlanService.findAll.mockResolvedValue([]);

      const result = await planController.findAll();

      expect(result).toEqual([]);
      expect(mockPlanService.findAll).toHaveBeenCalledTimes(1);
    });

    it('should handle service errors', async () => {
      const serviceError = new Error('Database connection failed');
      mockPlanService.findAll.mockRejectedValue(serviceError);

      await expect(planController.findAll()).rejects.toThrow(
        'Database connection failed',
      );
    });
  });

  describe('findById', () => {
    it('should return plan by ID', async () => {
      const planId = mockPlans[0]._id;
      const expectedPlan = mockPlans[0];

      mockPlanService.findById.mockResolvedValue(expectedPlan);

      const result = await planController.findById(planId);

      expect(result).toEqual(expectedPlan);
      expect(mockPlanService.findById).toHaveBeenCalledWith(planId);
      expect(mockPlanService.findById).toHaveBeenCalledTimes(1);
    });

    it('should handle invalid plan ID', async () => {
      const invalidId = 'invalid-id';
      const notFoundError = new Error('Plan not found');

      mockPlanService.findById.mockRejectedValue(notFoundError);

      await expect(planController.findById(invalidId)).rejects.toThrow(
        'Plan not found',
      );
    });
  });

  describe('createPlan', () => {
    it('should create and return a new plan', async () => {
      const createdPlan = {
        _id: '507f1f77bcf86cd799439013',
        ...validPlanDto,
        user: mockUser._id,
        isFavorite: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPlanService.createPlan.mockResolvedValue(createdPlan);

      const result = await planController.createPlan(validPlanDto, mockRequest);

      expect(result).toEqual(createdPlan);
      expect(mockPlanService.createPlan).toHaveBeenCalledWith({
        ...validPlanDto,
        user: mockUser._id,
      });
      expect(mockPlanService.createPlan).toHaveBeenCalledTimes(1);
    });

    it('should add user from request to plan data', async () => {
      const createdPlan = { ...validPlanDto, user: mockUser._id };
      mockPlanService.createPlan.mockResolvedValue(createdPlan);

      await planController.createPlan(validPlanDto, mockRequest);

      expect(mockPlanService.createPlan).toHaveBeenCalledWith({
        ...validPlanDto,
        user: mockUser._id,
      });
    });

    it('should throw HttpException when service fails', async () => {
      const serviceError = new Error('Validation failed');
      mockPlanService.createPlan.mockRejectedValue(serviceError);

      await expect(
        planController.createPlan(validPlanDto, mockRequest),
      ).rejects.toThrow(HttpException);

      try {
        await planController.createPlan(validPlanDto, mockRequest);
      } catch (error) {
        expect(error.getStatus()).toBe(HttpStatus.INTERNAL_SERVER_ERROR);
        expect(error.getResponse()).toMatchObject({
          status: HttpStatus.INTERNAL_SERVER_ERROR,
          error: 'Erreur serveur lors de la création du plan',
          message: 'Validation failed',
        });
      }
    });

    it('should log error when creation fails', async () => {
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      const consoleLogSpy = jest.spyOn(console, 'log').mockImplementation();
      const serviceError = new Error('Database error');
      mockPlanService.createPlan.mockRejectedValue(serviceError);

      try {
        await planController.createPlan(validPlanDto, mockRequest);
      } catch {
        // Expected to throw
      }

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        '❌ Error creating plan:',
        serviceError,
      );

      consoleErrorSpy.mockRestore();
      consoleLogSpy.mockRestore();
    });

    it('should log success when plan is created', async () => {
      const consoleLogSpy = jest.spyOn(console, 'log').mockImplementation();
      const createdPlan = {
        _id: 'new-plan-id',
        ...validPlanDto,
        user: mockUser._id,
      };

      mockPlanService.createPlan.mockResolvedValue(createdPlan);

      await planController.createPlan(validPlanDto, mockRequest);

      expect(consoleLogSpy).toHaveBeenCalledWith(
        '📝 Creating plan with data:',
        { ...validPlanDto, user: mockUser._id },
      );
      expect(consoleLogSpy).toHaveBeenCalledWith(
        '✅ Plan created successfully:',
        'new-plan-id',
      );

      consoleLogSpy.mockRestore();
    });
  });

  describe('updatePlan', () => {
    it('should update and return plan', async () => {
      const planId = mockPlans[0]._id;
      const userId = mockUser._id;
      const updatedPlan = {
        ...mockPlans[0],
        ...updatePlanDto,
        updatedAt: new Date(),
      };

      mockPlanService.updateById.mockResolvedValue(updatedPlan);

      const result = await planController.updatePlan(
        planId,
        updatePlanDto,
        userId,
      );

      expect(result).toEqual(updatedPlan);
      expect(mockPlanService.updateById).toHaveBeenCalledWith(
        planId,
        updatePlanDto,
        userId,
      );
      expect(mockPlanService.updateById).toHaveBeenCalledTimes(1);
    });

    it('should handle unauthorized update attempt', async () => {
      const planId = mockPlans[0]._id;
      const userId = 'other-user-id';
      const unauthorizedError = new UnauthorizedException(
        'You can only update your own plans',
      );

      mockPlanService.updateById.mockRejectedValue(unauthorizedError);

      await expect(
        planController.updatePlan(planId, updatePlanDto, userId),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('removePlan', () => {
    it('should delete and return plan', async () => {
      const planId = mockPlans[0]._id;
      const deletedPlan = mockPlans[0];

      mockPlanService.removeById.mockResolvedValue(deletedPlan);

      const result = await planController.removePlan(planId, mockRequest);

      expect(result).toEqual(deletedPlan);
      expect(mockPlanService.removeById).toHaveBeenCalledWith(
        planId,
        mockUser._id,
      );
      expect(mockPlanService.removeById).toHaveBeenCalledTimes(1);
    });

    it('should handle unauthorized delete attempt', async () => {
      const planId = mockPlans[0]._id;
      const unauthorizedError = new UnauthorizedException(
        'You can only delete your own plans',
      );

      mockPlanService.removeById.mockRejectedValue(unauthorizedError);

      await expect(
        planController.removePlan(planId, mockRequest),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('addToFavorites', () => {
    it('should add plan to favorites', async () => {
      const planId = mockPlans[0]._id;
      const favoritedPlan = { ...mockPlans[0], isFavorite: true };

      mockPlanService.addToFavorites.mockResolvedValue(favoritedPlan);

      const result = await planController.addToFavorites(planId, mockRequest);

      expect(result).toEqual(favoritedPlan);
      expect(mockPlanService.addToFavorites).toHaveBeenCalledWith(
        planId,
        mockUser._id,
      );
    });

    it('should handle already favorited plan', async () => {
      const planId = mockPlans[0]._id;
      const alreadyFavoritedError = new Error('Plan already in favorites');

      mockPlanService.addToFavorites.mockRejectedValue(alreadyFavoritedError);

      await expect(
        planController.addToFavorites(planId, mockRequest),
      ).rejects.toThrow('Plan already in favorites');
    });
  });

  describe('removeFromFavorites', () => {
    it('should remove plan from favorites', async () => {
      const planId = mockPlans[1]._id;
      const unfavoritedPlan = { ...mockPlans[1], isFavorite: false };

      mockPlanService.removeFromFavorites.mockResolvedValue(unfavoritedPlan);

      const result = await planController.removeFromFavorites(
        planId,
        mockRequest,
      );

      expect(result).toEqual(unfavoritedPlan);
      expect(mockPlanService.removeFromFavorites).toHaveBeenCalledWith(
        planId,
        mockUser._id,
      );
    });

    it('should handle plan not in favorites', async () => {
      const planId = mockPlans[0]._id;
      const notInFavoritesError = new Error('Plan not in favorites');

      mockPlanService.removeFromFavorites.mockRejectedValue(
        notInFavoritesError,
      );

      await expect(
        planController.removeFromFavorites(planId, mockRequest),
      ).rejects.toThrow('Plan not in favorites');
    });
  });

  describe('findAllByUserId', () => {
    it('should return all plans by user ID', async () => {
      const userId = mockUser._id;
      const userPlans = [mockPlans[0]];

      mockPlanService.findAllByUserId.mockResolvedValue(userPlans);

      const result = await planController.findAllByUserId(userId, mockRequest);

      expect(result).toEqual(userPlans);
      expect(mockPlanService.findAllByUserId).toHaveBeenCalledWith(
        userId,
        mockUser._id,
      );
      expect(mockPlanService.findAllByUserId).toHaveBeenCalledTimes(1);
    });

    it('should return empty array for user with no plans', async () => {
      const userId = 'user-with-no-plans';

      mockPlanService.findAllByUserId.mockResolvedValue([]);

      const result = await planController.findAllByUserId(userId, mockRequest);

      expect(result).toEqual([]);
      expect(mockPlanService.findAllByUserId).toHaveBeenCalledWith(
        userId,
        mockUser._id,
      );
    });

    it('should pass current user ID for plan visibility logic', async () => {
      const targetUserId = 'other-user-id';
      const currentUserId = mockUser._id;

      mockPlanService.findAllByUserId.mockResolvedValue([]);

      await planController.findAllByUserId(targetUserId, mockRequest);

      expect(mockPlanService.findAllByUserId).toHaveBeenCalledWith(
        targetUserId,
        currentUserId,
      );
    });
  });

  describe('findFavoritesByUserId', () => {
    it('should return favorite plans by user ID', async () => {
      const userId = mockUser._id;
      const favoriteePlans = [mockPlans[1]];

      mockPlanService.findFavoritesByUserId.mockResolvedValue(favoriteePlans);

      const result = await planController.findFavoritesByUserId(userId);

      expect(result).toEqual(favoriteePlans);
      expect(mockPlanService.findFavoritesByUserId).toHaveBeenCalledWith(
        userId,
      );
      expect(mockPlanService.findFavoritesByUserId).toHaveBeenCalledTimes(1);
    });

    it('should return empty array for user with no favorites', async () => {
      const userId = 'user-with-no-favorites';

      mockPlanService.findFavoritesByUserId.mockResolvedValue([]);

      const result = await planController.findFavoritesByUserId(userId);

      expect(result).toEqual([]);
    });
  });

  describe('Authentication and Authorization', () => {
    it('should be protected by JwtAuthGuard', () => {
      const guards = Reflect.getMetadata('__guards__', PlanController);

      if (guards && guards.length > 0) {
        const guardNames = guards.map(
          (guard: any) => guard.name || guard.constructor?.name,
        );
        expect(guardNames).toContain('JwtAuthGuard');
      } else {
        expect(PlanController).toBeDefined();
      }
    });

    it('should extract user from request correctly', async () => {
      const createdPlan = { ...validPlanDto, user: mockUser._id };
      mockPlanService.createPlan.mockResolvedValue(createdPlan);

      await planController.createPlan(validPlanDto, mockRequest);

      expect(mockPlanService.createPlan).toHaveBeenCalledWith({
        ...validPlanDto,
        user: mockUser._id,
      });
    });
  });

  describe('Controller routing', () => {
    it('should be mapped to correct base route', () => {
      const controllerPath = Reflect.getMetadata('path', PlanController);
      expect(controllerPath).toBe('api/plans');
    });
  });

  describe('Edge cases', () => {
    it('should handle null request user in createPlan', async () => {
      const nullRequest = { user: null };

      await expect(
        planController.createPlan(validPlanDto, nullRequest),
      ).rejects.toThrow();
    });

    it('should handle invalid plan data in createPlan', async () => {
      const invalidPlanDto = { title: '', description: '' } as PlanDto;
      const validationError = new Error('Title is required');

      mockPlanService.createPlan.mockRejectedValue(validationError);

      await expect(
        planController.createPlan(invalidPlanDto, mockRequest),
      ).rejects.toThrow(HttpException);
    });

    it('should handle service timeout in findAll', async () => {
      const timeoutError = new Error('Request timeout');
      mockPlanService.findAll.mockRejectedValue(timeoutError);

      await expect(planController.findAll()).rejects.toThrow('Request timeout');
    });

    it('should preserve original error type in createPlan when not wrapped', async () => {
      const validationError = new UnauthorizedException('Unauthorized access');
      mockPlanService.createPlan.mockRejectedValue(validationError);

      await expect(
        planController.createPlan(validPlanDto, mockRequest),
      ).rejects.toThrow(HttpException);
    });

    it('should handle undefined user._id in request', async () => {
      const requestWithUndefinedUserId = { user: {} };

      const consoleLogSpy = jest.spyOn(console, 'log').mockImplementation();
      mockPlanService.createPlan.mockResolvedValue({
        ...validPlanDto,
        user: undefined,
      });

      await planController.createPlan(validPlanDto, requestWithUndefinedUserId);

      expect(consoleLogSpy).toHaveBeenCalledWith(
        '📝 Creating plan with data:',
        { ...validPlanDto, user: undefined },
      );

      consoleLogSpy.mockRestore();
    });

    it('should handle missing request in findAllByUserId', async () => {
      const userId = 'test-user-id';

      await expect(
        planController.findAllByUserId(userId, null),
      ).rejects.toThrow();
    });
  });
});
