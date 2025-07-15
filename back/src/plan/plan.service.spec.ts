import { Test, TestingModule } from '@nestjs/testing';
import { PlanService } from './plan.service';
import { getModelToken, getConnectionToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';
import { StepService } from '../step/step.service';

describe('PlanService', () => {
  let planService: PlanService;
  let stepService: StepService;

  const mockPlans = [
    {
      _id: '507f1f77bcf86cd799439041',
      title: 'Voyage à Paris',
      description: 'Un merveilleux voyage de 3 jours à Paris',
      user: '507f1f77bcf86cd799439011',
      isPublic: true,
      category: '507f1f77bcf86cd799439031',
      steps: ['507f1f77bcf86cd799439051', '507f1f77bcf86cd799439052'],
      favorites: ['507f1f77bcf86cd799439012'],
      totalCost: 40,
      totalDuration: 300,
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439042',
      title: 'Programme Fitness',
      description: "Plan d'entraînement pour débutants",
      user: '507f1f77bcf86cd799439012',
      isPublic: true,
      category: '507f1f77bcf86cd799439032',
      steps: ['507f1f77bcf86cd799439053'],
      favorites: [],
      totalCost: 0,
      totalDuration: 60,
      createdAt: new Date('2024-01-20T11:00:00.000Z'),
      updatedAt: new Date('2024-01-20T11:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439043',
      title: 'Plan Privé',
      description: 'Mon plan personnel',
      user: '507f1f77bcf86cd799439011',
      isPublic: false,
      category: '507f1f77bcf86cd799439033',
      steps: [],
      favorites: null,
      totalCost: 0,
      totalDuration: 0,
      createdAt: new Date('2024-01-20T12:00:00.000Z'),
      updatedAt: new Date('2024-01-20T12:00:00.000Z'),
    },
  ];

  const mockUsers = [
    {
      _id: '507f1f77bcf86cd799439011',
      username: 'johndoe',
      email: 'john@plany.com',
      photoUrl: 'https://example.com/john.jpg',
      followers: 10,
    },
    {
      _id: '507f1f77bcf86cd799439012',
      username: 'janedoe',
      email: 'jane@plany.com',
      photoUrl: 'https://example.com/jane.jpg',
      followers: 5,
    },
  ];

  const mockCategories = [
    {
      _id: '507f1f77bcf86cd799439031',
      name: 'Voyage',
      icon: 'plane',
      color: '#FF6B6B',
    },
    {
      _id: '507f1f77bcf86cd799439032',
      name: 'Sport',
      icon: 'dumbbell',
      color: '#4ECDC4',
    },
  ];

  const mockSteps = [
    {
      _id: '507f1f77bcf86cd799439051',
      title: 'Visite de la Tour Eiffel',
      description: 'Montée au sommet',
      image: 'eiffel.jpg',
      order: 1,
      duration: 120,
      cost: 25,
      longitude: 2.2945,
      latitude: 48.8584,
    },
    {
      _id: '507f1f77bcf86cd799439052',
      title: 'Musée du Louvre',
      description: 'Visite guidée',
      image: 'louvre.jpg',
      order: 2,
      duration: 180,
      cost: 15,
      longitude: 2.3376,
      latitude: 48.8606,
    },
  ];

  const createPlanDto = {
    title: 'Nouveau Plan',
    description: 'Description du nouveau plan',
    user: '507f1f77bcf86cd799439011',
    isPublic: true,
    category: '507f1f77bcf86cd799439031',
    steps: ['507f1f77bcf86cd799439051', '507f1f77bcf86cd799439052'],
  };

  const updatePlanDto = {
    title: 'Plan Mis à Jour',
    description: 'Description mise à jour',
    user: '507f1f77bcf86cd799439011',
    isPublic: false,
    category: '507f1f77bcf86cd799439032',
    steps: ['507f1f77bcf86cd799439051'],
  };

  const mockPlanModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: mockPlans[0]._id,
    createdAt: mockPlans[0].createdAt,
    updatedAt: mockPlans[0].updatedAt,
    save: jest.fn().mockResolvedValue({
      _id: mockPlans[0]._id,
      ...dto,
      createdAt: mockPlans[0].createdAt,
      updatedAt: mockPlans[0].updatedAt,
    }),
  })) as any;

  mockPlanModel.find = jest.fn().mockReturnValue({
    populate: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockPlanModel.findOne = jest.fn().mockReturnValue({
    populate: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockPlanModel.findById = jest.fn().mockReturnValue({
    populate: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockPlanModel.findOneAndUpdate = jest.fn().mockReturnValue({
    populate: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockPlanModel.findOneAndDelete = jest.fn().mockReturnValue({
    exec: jest.fn(),
    session: jest.fn().mockReturnThis(),
  });

  mockPlanModel.findByIdAndUpdate = jest.fn().mockReturnValue({
    populate: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockPlanModel.updateOne = jest.fn();
  mockPlanModel.updateMany = jest.fn();
  mockPlanModel.countDocuments = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  const mockStepModel = {
    deleteMany: jest.fn().mockReturnValue({
      session: jest.fn().mockReturnThis(),
    }),
  };

  const mockCommentModel = {
    deleteMany: jest.fn().mockReturnValue({
      session: jest.fn().mockReturnThis(),
    }),
  };

  const mockUserModel = {
    findById: jest.fn().mockReturnValue({
      exec: jest.fn(),
    }),
  };

  const mockStepService = {
    calculateTotalCost: jest.fn(),
    calculateTotalDuration: jest.fn(),
  };

  const mockConnection = {
    startSession: jest.fn().mockResolvedValue({
      withTransaction: jest.fn(),
      endSession: jest.fn(),
    }),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PlanService,
        {
          provide: getModelToken('Plan'),
          useValue: mockPlanModel,
        },
        {
          provide: getModelToken('Step'),
          useValue: mockStepModel,
        },
        {
          provide: getModelToken('Comment'),
          useValue: mockCommentModel,
        },
        {
          provide: getModelToken('User'),
          useValue: mockUserModel,
        },
        {
          provide: getConnectionToken(),
          useValue: mockConnection,
        },
        {
          provide: StepService,
          useValue: mockStepService,
        },
      ],
    }).compile();

    planService = module.get<PlanService>(PlanService);
    stepService = module.get<StepService>(StepService);
  });

  it('should be defined', () => {
    expect(planService).toBeDefined();
    expect(stepService).toBeDefined();
  });

  describe('createPlan', () => {
    it('should create plan with calculated totals', async () => {
      const calculatedTotalCost = 40;
      const calculatedTotalDuration = 300;

      mockStepService.calculateTotalCost.mockResolvedValue(calculatedTotalCost);
      mockStepService.calculateTotalDuration.mockResolvedValue(
        calculatedTotalDuration,
      );

      const expectedPlan = {
        ...createPlanDto,
        _id: mockPlans[0]._id,
        totalCost: calculatedTotalCost,
        totalDuration: calculatedTotalDuration,
        user: mockUsers[0],
        category: mockCategories[0],
        steps: mockSteps,
        createdAt: mockPlans[0].createdAt,
        updatedAt: mockPlans[0].updatedAt,
      };

      mockPlanModel.findById.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(expectedPlan),
      });

      const result = await planService.createPlan(createPlanDto);

      expect(mockStepService.calculateTotalCost).toHaveBeenCalledWith([
        '507f1f77bcf86cd799439051',
        '507f1f77bcf86cd799439052',
      ]);
      expect(mockStepService.calculateTotalDuration).toHaveBeenCalledWith([
        '507f1f77bcf86cd799439051',
        '507f1f77bcf86cd799439052',
      ]);

      expect(mockPlanModel).toHaveBeenCalledWith({
        ...createPlanDto,
        totalCost: calculatedTotalCost,
        totalDuration: calculatedTotalDuration,
      });

      expect(result).toEqual(expectedPlan);
    });

    it('should handle empty steps array', async () => {
      const planWithoutSteps = { ...createPlanDto, steps: [] };

      mockStepService.calculateTotalCost.mockResolvedValue(0);
      mockStepService.calculateTotalDuration.mockResolvedValue(0);

      mockPlanModel.findById.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue({
          ...planWithoutSteps,
          totalCost: 0,
          totalDuration: 0,
        }),
      });

      await planService.createPlan(planWithoutSteps);

      expect(mockStepService.calculateTotalCost).toHaveBeenCalledWith([]);
      expect(mockStepService.calculateTotalDuration).toHaveBeenCalledWith([]);
    });

    it('should handle step calculation errors', async () => {
      const calculationError = new Error('Failed to calculate step totals');
      mockStepService.calculateTotalCost.mockRejectedValue(calculationError);

      await expect(planService.createPlan(createPlanDto)).rejects.toThrow(
        'Failed to calculate step totals',
      );
    });
  });

  describe('findAll', () => {
    it('should return only public plans sorted by favorites', async () => {
      const publicPlans = mockPlans
        .filter((plan) => plan.isPublic)
        .map((plan) => ({
          ...plan,
          user: mockUsers.find((u) => u._id === plan.user),
          category: mockCategories.find((c) => c._id === plan.category),
          steps: mockSteps.filter((s) => plan.steps.includes(s._id)),
        }));

      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(publicPlans),
      });

      const result = await planService.findAll();

      expect(result).toEqual(publicPlans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({ isPublic: true });

      const sortCall = mockPlanModel.find().sort;
      expect(sortCall).toHaveBeenCalledWith({ favorites: -1 });
    });

    it('should return empty array when no public plans', async () => {
      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await planService.findAll();

      expect(result).toEqual([]);
    });
  });

  describe('findById', () => {
    it('should return plan when found with valid ObjectId', async () => {
      const planId = mockPlans[0]._id;
      const expectedPlan = {
        ...mockPlans[0],
        user: mockUsers[0],
        category: mockCategories[0],
        steps: mockSteps,
      };

      mockPlanModel.findById.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(expectedPlan),
      });

      const result = await planService.findById(planId);

      expect(result).toEqual(expectedPlan);
      expect(mockPlanModel.findById).toHaveBeenCalledWith(planId);
    });

    it('should return null when plan not found', async () => {
      mockPlanModel.findById.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await planService.findById('507f1f77bcf86cd799999999');

      expect(result).toBeNull();
    });

    it('should throw NotFoundException for invalid ObjectId', async () => {
      const invalidId = 'invalid-objectid';

      await expect(planService.findById(invalidId)).rejects.toThrow(
        NotFoundException,
      );
      await expect(planService.findById(invalidId)).rejects.toThrow(
        `Plan with ID ${invalidId} is not a valid ObjectId`,
      );
    });
  });

  describe('findAllByUserId', () => {
    it('should return all plans (public and private) for plan owner', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const viewerId = '507f1f77bcf86cd799439011';
      const userPlans = mockPlans.filter((plan) => plan.user === userId);

      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(userPlans),
      });

      const result = await planService.findAllByUserId(userId, viewerId);

      expect(result).toEqual(userPlans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({
        user: expect.any(Object),
      });
    });

    it('should return only public plans for other users', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const viewerId = '507f1f77bcf86cd799439012';
      const publicUserPlans = mockPlans.filter(
        (plan) => plan.user === userId && plan.isPublic,
      );

      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(publicUserPlans),
      });

      const result = await planService.findAllByUserId(userId, viewerId);

      expect(result).toEqual(publicUserPlans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({
        user: expect.any(Object),
        isPublic: true,
      });
    });

    it('should return only public plans when no viewerId provided', async () => {
      const userId = '507f1f77bcf86cd799439011';

      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      });

      await planService.findAllByUserId(userId);

      expect(mockPlanModel.find).toHaveBeenCalledWith({
        user: expect.any(Object),
        isPublic: true,
      });
    });

    it('should sort plans by creation date descending', async () => {
      const userId = '507f1f77bcf86cd799439011';

      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      });

      await planService.findAllByUserId(userId);

      const sortCall = mockPlanModel.find().sort;
      expect(sortCall).toHaveBeenCalledWith({ createdAt: -1 });
    });
  });

  describe('findFavoritesByUserId', () => {
    it('should return user favorite plans', async () => {
      const userId = '507f1f77bcf86cd799439012';
      const favoritePlans = mockPlans.filter(
        (plan) => plan.favorites && plan.favorites.includes(userId),
      );

      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(favoritePlans),
      });

      const result = await planService.findFavoritesByUserId(userId);

      expect(result).toEqual(favoritePlans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({ favorites: userId });
    });

    it('should return empty array for user with no favorites', async () => {
      const userId = 'user-with-no-favorites';

      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await planService.findFavoritesByUserId(userId);

      expect(result).toEqual([]);
    });
  });

  describe('updateById', () => {
    it('should update plan and recalculate totals when steps are modified', async () => {
      const planId = mockPlans[0]._id;
      const userId = mockPlans[0].user;
      const newTotalCost = 25;
      const newTotalDuration = 120;

      mockStepService.calculateTotalCost.mockResolvedValue(newTotalCost);
      mockStepService.calculateTotalDuration.mockResolvedValue(
        newTotalDuration,
      );

      const updatedPlan = {
        ...mockPlans[0],
        ...updatePlanDto,
        totalCost: newTotalCost,
        totalDuration: newTotalDuration,
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(updatedPlan),
      });

      const result = await planService.updateById(
        planId,
        updatePlanDto,
        userId,
      );

      expect(result).toEqual(updatedPlan);

      expect(mockStepService.calculateTotalCost).toHaveBeenCalledWith([
        '507f1f77bcf86cd799439051',
      ]);
      expect(mockStepService.calculateTotalDuration).toHaveBeenCalledWith([
        '507f1f77bcf86cd799439051',
      ]);

      expect(mockPlanModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: planId, user: userId },
        {
          ...updatePlanDto,
          totalCost: newTotalCost,
          totalDuration: newTotalDuration,
        },
        { new: true },
      );
    });

    it('should update plan without recalculating when steps not modified', async () => {
      const planId = mockPlans[0]._id;
      const userId = mockPlans[0].user;

      const updateWithoutSteps = {
        title: 'Updated Title',
        description: 'Updated Description',
        category: '507f1f77bcf86cd799439032',
        steps: undefined,
      };

      const updatedPlan = {
        ...mockPlans[0],
        ...updateWithoutSteps,
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(updatedPlan),
      });

      await planService.updateById(planId, updateWithoutSteps, userId);

      expect(mockStepService.calculateTotalCost).not.toHaveBeenCalled();
      expect(mockStepService.calculateTotalDuration).not.toHaveBeenCalled();

      expect(mockPlanModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: planId, user: userId },
        updateWithoutSteps,
        { new: true },
      );
    });

    it('should return null when plan not found or user unauthorized', async () => {
      mockPlanModel.findOneAndUpdate.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await planService.updateById(
        'nonexistent',
        updatePlanDto,
        'unauthorized',
      );

      expect(result).toBeNull();
    });
  });

  describe('removeById', () => {
    it('should delete plan and associated data with transaction', async () => {
      const planId = mockPlans[0]._id;
      const userId = mockPlans[0].user;
      const planToDelete = mockPlans[0];

      const mockSession = {
        withTransaction: jest.fn().mockImplementation(async (callback) => {
          return await callback();
        }),
        endSession: jest.fn(),
      };

      mockConnection.startSession.mockResolvedValue(mockSession);

      mockPlanModel.findOne = jest.fn().mockReturnValue({
        session: jest.fn().mockResolvedValue(planToDelete),
      });

      mockStepModel.deleteMany.mockReturnValue({
        session: jest.fn().mockResolvedValue({ deletedCount: 2 }),
      });

      mockCommentModel.deleteMany.mockReturnValue({
        session: jest.fn().mockResolvedValue({ deletedCount: 5 }),
      });

      mockPlanModel.findOneAndDelete.mockReturnValue({
        session: jest.fn().mockResolvedValue(planToDelete),
      });

      const result = await planService.removeById(planId, userId);

      expect(result).toEqual(planToDelete);
      expect(mockConnection.startSession).toHaveBeenCalled();
      expect(mockSession.withTransaction).toHaveBeenCalled();
      expect(mockSession.endSession).toHaveBeenCalled();
    });

    it('should throw NotFoundException when plan not found or unauthorized', async () => {
      const mockSession = {
        withTransaction: jest.fn().mockImplementation(async (callback) => {
          return await callback();
        }),
        endSession: jest.fn(),
      };

      mockConnection.startSession.mockResolvedValue(mockSession);

      mockPlanModel.findOne = jest.fn().mockReturnValue({
        session: jest.fn().mockResolvedValue(null),
      });

      await expect(
        planService.removeById('nonexistent', 'unauthorized'),
      ).rejects.toThrow(NotFoundException);
      await expect(
        planService.removeById('nonexistent', 'unauthorized'),
      ).rejects.toThrow('Plan not found or not owned by user');
    });

    it('should handle plan with no steps', async () => {
      const planId = mockPlans[2]._id;
      const userId = mockPlans[2].user;
      const planWithoutSteps = { ...mockPlans[2], steps: [] };

      const mockSession = {
        withTransaction: jest.fn().mockImplementation(async (callback) => {
          return await callback();
        }),
        endSession: jest.fn(),
      };

      mockConnection.startSession.mockResolvedValue(mockSession);

      mockPlanModel.findOne = jest.fn().mockReturnValue({
        session: jest.fn().mockResolvedValue(planWithoutSteps),
      });

      mockCommentModel.deleteMany.mockReturnValue({
        session: jest.fn().mockResolvedValue({ deletedCount: 0 }),
      });

      mockPlanModel.findOneAndDelete.mockReturnValue({
        session: jest.fn().mockResolvedValue(planWithoutSteps),
      });

      const result = await planService.removeById(planId, userId);

      expect(result).toEqual(planWithoutSteps);
      expect(mockStepModel.deleteMany).not.toHaveBeenCalled();
    });
  });

  describe('addToFavorites', () => {
    it('should add user to favorites', async () => {
      const planId = mockPlans[1]._id;
      const userId = '507f1f77bcf86cd799439013';
      const plan = mockPlans[1];
      const updatedPlan = {
        ...plan,
        favorites: [...plan.favorites, userId],
      };

      mockPlanModel.findById.mockResolvedValue(plan);
      mockPlanModel.findByIdAndUpdate.mockResolvedValue(updatedPlan);

      const result = await planService.addToFavorites(planId, userId);

      expect(result).toEqual(updatedPlan);
      expect(mockPlanModel.findById).toHaveBeenCalledWith(planId);
      expect(mockPlanModel.findByIdAndUpdate).toHaveBeenCalledWith(
        planId,
        { $addToSet: { favorites: userId } },
        { new: true },
      );
    });

    it('should handle null favorites array', async () => {
      const planId = mockPlans[2]._id;
      const userId = '507f1f77bcf86cd799439013';
      const planWithNullFavorites = mockPlans[2];
      const updatedPlan = {
        ...planWithNullFavorites,
        favorites: [userId],
      };

      mockPlanModel.findById.mockResolvedValue(planWithNullFavorites);
      mockPlanModel.updateOne.mockResolvedValue({ modifiedCount: 1 });
      mockPlanModel.findByIdAndUpdate.mockResolvedValue(updatedPlan);

      const result = await planService.addToFavorites(planId, userId);

      expect(result).toEqual(updatedPlan);
      expect(mockPlanModel.updateOne).toHaveBeenCalledWith(
        { _id: planId },
        { $set: { favorites: [] } },
      );
    });

    it('should throw NotFoundException when plan not found', async () => {
      mockPlanModel.findById.mockResolvedValue(null);

      await expect(
        planService.addToFavorites('nonexistent', 'userId'),
      ).rejects.toThrow(NotFoundException);
      await expect(
        planService.addToFavorites('nonexistent', 'userId'),
      ).rejects.toThrow('Plan with ID nonexistent not found');
    });
  });

  describe('removeFromFavorites', () => {
    it('should remove user from favorites', async () => {
      const planId = mockPlans[0]._id;
      const userId = mockPlans[0].favorites[0];
      const plan = mockPlans[0];
      const updatedPlan = {
        ...plan,
        favorites: [],
      };

      mockPlanModel.findById.mockResolvedValue(plan);
      mockPlanModel.findByIdAndUpdate.mockResolvedValue(updatedPlan);

      const result = await planService.removeFromFavorites(planId, userId);

      expect(result).toEqual(updatedPlan);
      expect(mockPlanModel.findByIdAndUpdate).toHaveBeenCalledWith(
        planId,
        { $pull: { favorites: userId } },
        { new: true },
      );
    });

    it('should return plan unchanged when favorites is null', async () => {
      const planId = mockPlans[2]._id;
      const userId = 'anyUserId';
      const planWithNullFavorites = mockPlans[2];

      mockPlanModel.findById.mockResolvedValue(planWithNullFavorites);

      const result = await planService.removeFromFavorites(planId, userId);

      expect(result).toEqual(planWithNullFavorites);
      expect(mockPlanModel.findByIdAndUpdate).not.toHaveBeenCalled();
    });

    it('should throw NotFoundException when plan not found', async () => {
      mockPlanModel.findById.mockResolvedValue(null);

      await expect(
        planService.removeFromFavorites('nonexistent', 'userId'),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('Database errors', () => {
    it('should handle save errors in createPlan', async () => {
      mockStepService.calculateTotalCost.mockResolvedValue(0);
      mockStepService.calculateTotalDuration.mockResolvedValue(0);

      const originalInstance = new mockPlanModel(createPlanDto);
      originalInstance.save = jest
        .fn()
        .mockRejectedValue(new Error('Database error'));

      mockPlanModel.mockImplementation(() => originalInstance);

      await expect(planService.createPlan(createPlanDto)).rejects.toThrow(
        'Database error',
      );
    });

    it('should handle transaction errors in removeById', async () => {
      const transactionError = new Error('Transaction failed');
      const mockSession = {
        withTransaction: jest.fn().mockRejectedValue(transactionError),
        endSession: jest.fn(),
      };

      mockConnection.startSession.mockResolvedValue(mockSession);

      await expect(planService.removeById('planId', 'userId')).rejects.toThrow(
        'Transaction failed',
      );

      expect(mockSession.endSession).toHaveBeenCalled();
    });

    it('should handle populate errors', async () => {
      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockRejectedValue(new Error('Populate error')),
      });

      await expect(planService.findAll()).rejects.toThrow('Populate error');
    });
  });

  describe('Edge cases', () => {
    it('should handle very large step arrays in createPlan', async () => {
      const largeStepArray = Array.from({ length: 100 }, (_, i) => `step-${i}`);
      const planWithManySteps = { ...createPlanDto, steps: largeStepArray };

      mockPlanModel.mockImplementation((dto) => ({
        ...dto,
        _id: mockPlans[0]._id,
        createdAt: mockPlans[0].createdAt,
        updatedAt: mockPlans[0].updatedAt,
        save: jest.fn().mockResolvedValue({
          _id: mockPlans[0]._id,
          ...dto,
          createdAt: mockPlans[0].createdAt,
          updatedAt: mockPlans[0].updatedAt,
        }),
      }));

      mockStepService.calculateTotalCost.mockResolvedValue(1000);
      mockStepService.calculateTotalDuration.mockResolvedValue(6000);

      mockPlanModel.findById.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(planWithManySteps),
      });

      await planService.createPlan(planWithManySteps);

      expect(mockStepService.calculateTotalCost).toHaveBeenCalledWith(
        largeStepArray,
      );
    });

    it('should handle concurrent favorites operations', async () => {
      const planId = mockPlans[0]._id;
      const userId1 = 'user1';
      const userId2 = 'user2';

      mockPlanModel.findById.mockResolvedValue(mockPlans[0]);
      mockPlanModel.findByIdAndUpdate.mockResolvedValue({
        ...mockPlans[0],
        favorites: [userId1, userId2],
      });

      const promises = [
        planService.addToFavorites(planId, userId1),
        planService.addToFavorites(planId, userId2),
      ];

      const results = await Promise.all(promises);

      expect(results).toHaveLength(2);
      expect(mockPlanModel.findByIdAndUpdate).toHaveBeenCalledTimes(2);
    });
  });
});
