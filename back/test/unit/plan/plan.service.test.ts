import { Test, TestingModule } from '@nestjs/testing';
import { PlanService } from '../../../src/plan/plan.service';
import { getModelToken, getConnectionToken } from '@nestjs/mongoose';
import * as planFixtures from '../../__fixtures__/plans.json';
import { StepService } from '../../../src/step/step.service';

describe('PlanService', () => {
  let planService: PlanService;

  const {
    validPlans,
    publicPlans,
    createPlanDtos,
    updatePlanDtos,
    planWithSteps,
    favoriteOperations,
    users,
    specialCases,
  } = planFixtures;

  const mockPlanModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: validPlans[0]._id,
    createdAt: new Date(validPlans[0].createdAt),
    updatedAt: new Date(validPlans[0].updatedAt),
    save: jest.fn().mockResolvedValue({
      _id: validPlans[0]._id,
      ...dto,
      createdAt: new Date(validPlans[0].createdAt),
      updatedAt: new Date(validPlans[0].updatedAt),
    }),
  })) as any;

  const mockUserModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: users[0]._id,
    save: jest.fn().mockResolvedValue({
      _id: users[0]._id,
      ...dto,
    }),
  })) as any;

  const mockStepModel = {
    deleteMany: jest.fn().mockReturnValue({
      session: jest.fn().mockReturnThis(),
      exec: jest.fn().mockResolvedValue({ deletedCount: 2 }),
    }),
  };

  const mockCommentModel = {
    deleteMany: jest.fn().mockReturnValue({
      session: jest.fn().mockReturnThis(),
      exec: jest.fn().mockResolvedValue({ deletedCount: 5 }),
    }),
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

  const createMockQuery = (resolveValue) => ({
    populate: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    session: jest.fn().mockReturnThis(),
    exec: jest.fn().mockResolvedValue(resolveValue),
  });

  mockPlanModel.find = jest.fn();
  mockPlanModel.findOne = jest.fn();
  mockPlanModel.findById = jest.fn();
  mockPlanModel.findByIdAndUpdate = jest.fn();
  mockPlanModel.findOneAndUpdate = jest.fn();
  mockPlanModel.findOneAndDelete = jest.fn();
  mockPlanModel.countDocuments = jest.fn();
  mockPlanModel.updateOne = jest.fn();
  mockPlanModel.updateMany = jest.fn();
  mockPlanModel.populate = jest.fn();
  mockPlanModel.sort = jest.fn();
  mockPlanModel.exec = jest.fn();

  mockUserModel.find = jest.fn();
  mockUserModel.findById = jest.fn();
  mockUserModel.exec = jest.fn();

  beforeEach(async () => {
    jest.clearAllMocks();

    mockStepModel.deleteMany.mockReturnValue({
      session: jest.fn().mockReturnThis(),
      exec: jest.fn().mockResolvedValue({ deletedCount: 2 }),
    });

    mockCommentModel.deleteMany.mockReturnValue({
      session: jest.fn().mockReturnThis(),
      exec: jest.fn().mockResolvedValue({ deletedCount: 5 }),
    });

    mockPlanModel.find.mockReturnValue(createMockQuery([]));
    mockPlanModel.findById.mockReturnValue(createMockQuery(null));
    mockPlanModel.findOne.mockReturnValue(createMockQuery(null));
    mockPlanModel.findByIdAndUpdate.mockReturnValue(createMockQuery(null));
    mockPlanModel.findOneAndUpdate.mockReturnValue(createMockQuery(null));
    mockPlanModel.findOneAndDelete.mockReturnValue(createMockQuery(null));
    mockPlanModel.findOneAndUpdate.mockReturnValue(createMockQuery(null));

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PlanService,
        {
          provide: getModelToken('Plan'),
          useValue: mockPlanModel,
        },
        {
          provide: getModelToken('User'),
          useValue: mockUserModel,
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
  });

  afterEach(() => {
    jest.clearAllMocks();
    mockPlanModel.find.mockReset();
    mockPlanModel.findOne.mockReset();
    mockPlanModel.findById.mockReset();
    mockPlanModel.findByIdAndUpdate.mockReset();
    mockPlanModel.findOneAndUpdate.mockReset();
    mockPlanModel.findOneAndDelete.mockReset();
    mockPlanModel.countDocuments.mockReset();
    mockPlanModel.updateOne.mockReset();
    mockPlanModel.updateMany.mockReset();
  });

  it('should be defined', () => {
    expect(planService).toBeDefined();
  });

  describe('createPlan', () => {
    it('should create and return new plan', async () => {
      mockStepService.calculateTotalCost.mockResolvedValue(150);
      mockStepService.calculateTotalDuration.mockResolvedValue(240);

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue({
          ...createPlanDtos.validCreate,
          _id: validPlans[0]._id,
          totalCost: 150,
          totalDuration: 240,
        }),
      };

      mockPlanModel.findById.mockReturnValue(mockChain);

      const result = await planService.createPlan(createPlanDtos.validCreate);

      expect(mockPlanModel).toHaveBeenCalledWith({
        ...createPlanDtos.validCreate,
        totalCost: 150,
        totalDuration: 240,
      });
      expect(result.totalCost).toBe(150);
      expect(result.totalDuration).toBe(240);
    });

    it('should create plan with default values', async () => {
      mockStepService.calculateTotalCost.mockResolvedValue(0);
      mockStepService.calculateTotalDuration.mockResolvedValue(0);

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue({
          ...createPlanDtos.minimalCreate,
          _id: validPlans[0]._id,
          totalCost: 0,
          totalDuration: 0,
          user: {
            _id: createPlanDtos.minimalCreate.user,
            username: 'testuser',
          },
          category: {
            _id: createPlanDtos.minimalCreate.category,
            name: 'Test Category',
          },
        }),
      };

      mockPlanModel.findById.mockReturnValue(mockChain);

      const result = await planService.createPlan(createPlanDtos.minimalCreate);

      expect(result.title).toBe(createPlanDtos.minimalCreate.title);
      expect(result.description).toBe(createPlanDtos.minimalCreate.description);
      expect(result.category).toBeDefined();
      expect(result.user).toBeDefined();
    });

    it('should create private plan', async () => {
      mockStepService.calculateTotalCost.mockResolvedValue(0);
      mockStepService.calculateTotalDuration.mockResolvedValue(0);

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue({
          ...createPlanDtos.privateCreate,
          _id: validPlans[0]._id,
          totalCost: 0,
          totalDuration: 0,
          user: {
            _id: createPlanDtos.privateCreate.user,
            username: 'testuser',
          },
          category: {
            _id: createPlanDtos.privateCreate.category,
            name: 'Test Category',
          },
        }),
      };

      mockPlanModel.findById.mockReturnValue(mockChain);

      const result = await planService.createPlan(createPlanDtos.privateCreate);

      expect(result.isPublic).toBe(createPlanDtos.privateCreate.isPublic);
      expect(result.category).toBeDefined();
    });

    it('should create plan with steps', async () => {
      mockStepService.calculateTotalCost.mockResolvedValue(150);
      mockStepService.calculateTotalDuration.mockResolvedValue(240);

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue({
          ...createPlanDtos.withStepsCreate,
          _id: validPlans[0]._id,
          totalCost: 150,
          totalDuration: 240,
          user: {
            _id: createPlanDtos.withStepsCreate.user,
            username: 'testuser',
          },
          category: {
            _id: createPlanDtos.withStepsCreate.category,
            name: 'Test Category',
          },
        }),
      };

      mockPlanModel.findById.mockReturnValue(mockChain);

      const result = await planService.createPlan(
        createPlanDtos.withStepsCreate,
      );

      expect(result.steps).toEqual(createPlanDtos.withStepsCreate.steps);
      expect(result.favorites).toEqual(
        createPlanDtos.withStepsCreate.favorites,
      );
      expect(Array.isArray(result.steps)).toBe(true);
      expect(Array.isArray(result.favorites)).toBe(true);
    });
  });

  describe('findAll', () => {
    it('should return all plans with populated user and steps', async () => {
      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(publicPlans),
      };

      mockPlanModel.find.mockReturnValue(mockChain);

      const result = await planService.findAll();

      expect(result).toEqual(publicPlans);
      expect(result).toHaveLength(publicPlans.length);
      expect(result[0].category).toBe(publicPlans[0].category);
      expect(result[0].isPublic).toBe(publicPlans[0].isPublic);
      expect(result[0].steps).toHaveLength(publicPlans[0].steps.length);
      expect(result[0].favorites).toEqual(publicPlans[0].favorites);
    });

    it('should return empty array when no plans', async () => {
      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      };

      mockPlanModel.find.mockReturnValue(mockChain);

      const result = await planService.findAll();

      expect(result).toEqual([]);
      expect(result).toHaveLength(0);
    });
  });

  describe('findById', () => {
    it('should throw NotFoundException for invalid ObjectId', async () => {
      const invalidId = 'invalid-object-id';

      await expect(planService.findById(invalidId)).rejects.toThrow(
        'Plan with ID invalid-object-id is not a valid ObjectId',
      );
    });

    it('should return plan when found', async () => {
      const planId = planWithSteps._id;

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(planWithSteps),
      };

      mockPlanModel.findById.mockReturnValue(mockChain);

      const result = await planService.findById(planId);

      expect(result).toEqual(planWithSteps);
    });
  });

  describe('addToFavorites', () => {
    it('should add user to favorites array', async () => {
      const planId = favoriteOperations.beforeAddFavorite._id;
      const userId = favoriteOperations.afterAddFavorite.favorites[1];

      mockPlanModel.findById.mockResolvedValue(
        favoriteOperations.beforeAddFavorite,
      );
      mockPlanModel.findByIdAndUpdate.mockResolvedValue(
        favoriteOperations.afterAddFavorite,
      );

      const result = await planService.addToFavorites(planId, userId);

      expect(result).toEqual(favoriteOperations.afterAddFavorite);
      expect(result.favorites).toContain(userId);
      expect(result.favorites).toHaveLength(2);
      expect(mockPlanModel.findByIdAndUpdate).toHaveBeenCalledWith(
        planId,
        { $addToSet: { favorites: userId } },
        { new: true },
      );
    });

    it('should initialize empty favorites array when null', async () => {
      const planId = favoriteOperations.withNullFavorites._id;
      const userId = favoriteOperations.afterInitFavorites.favorites[0];

      mockPlanModel.findById.mockResolvedValue(
        favoriteOperations.withNullFavorites,
      );
      mockPlanModel.updateOne.mockResolvedValue({ acknowledged: true });
      mockPlanModel.findByIdAndUpdate.mockResolvedValue(
        favoriteOperations.afterInitFavorites,
      );

      const result = await planService.addToFavorites(planId, userId);

      expect(mockPlanModel.updateOne).toHaveBeenCalledWith(
        { _id: planId },
        { $set: { favorites: [] } },
      );
      expect(result.favorites).toEqual([userId]);
    });
  });

  describe('removeFromFavorites', () => {
    it('should remove user from favorites array', async () => {
      const planId = favoriteOperations.beforeRemoveFavorite._id;
      const userId = favoriteOperations.beforeRemoveFavorite.favorites[0];

      mockPlanModel.findById.mockResolvedValue(
        favoriteOperations.beforeRemoveFavorite,
      );
      mockPlanModel.findByIdAndUpdate.mockResolvedValue(
        favoriteOperations.afterRemoveFavorite,
      );

      const result = await planService.removeFromFavorites(planId, userId);

      expect(result).toEqual(favoriteOperations.afterRemoveFavorite);
      expect(result.favorites).not.toContain(userId);
      expect(result.favorites).toHaveLength(1);
      expect(mockPlanModel.findByIdAndUpdate).toHaveBeenCalledWith(
        planId,
        { $pull: { favorites: userId } },
        { new: true },
      );
    });

    it('should handle empty favorites array', async () => {
      const planId = favoriteOperations.emptyFavorites._id;
      const userId = users[0]._id;

      mockPlanModel.findById.mockResolvedValue(
        favoriteOperations.emptyFavorites,
      );
      mockPlanModel.findByIdAndUpdate.mockResolvedValue(
        favoriteOperations.emptyFavorites,
      );

      const result = await planService.removeFromFavorites(planId, userId);

      expect(result.favorites).toEqual([]);
      expect(result.favorites).toHaveLength(0);
    });
  });

  describe('updateById', () => {
    it('should update plan with new category and public status', async () => {
      const planId = validPlans[0]._id;
      const userId = validPlans[0].user;
      const updateData = updatePlanDtos.fullUpdate;

      const updatedPlan = {
        _id: planId,
        ...updateData,
        user: { _id: userId, username: 'testuser' },
        category: { _id: 'cat1', name: 'Test Category' },
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue(
        createMockQuery(updatedPlan),
      );

      const result = await planService.updateById(planId, updateData, userId);

      expect(result).toEqual(updatedPlan);
      expect(result.category).toBeDefined();
      expect(result.user).toBeDefined();
      expect(mockPlanModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: planId, user: userId },
        updateData,
        { new: true },
      );
    });

    it('should handle partial updates', async () => {
      const planId = validPlans[0]._id;
      const userId = validPlans[0].user;
      const updateData = updatePlanDtos.partialUpdate;

      const updatedPlan = {
        _id: planId,
        title: updateData.title,
        description: validPlans[0].description,
        category: { _id: updateData.category, name: 'Test Category' },
        user: { _id: userId, username: 'testuser' },
        isPublic: validPlans[0].isPublic,
        steps: validPlans[0].steps,
        favorites: validPlans[0].favorites,
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue(
        createMockQuery(updatedPlan),
      );

      const result = await planService.updateById(planId, updateData, userId);

      expect(result.title).toBe(updateData.title);
      expect(result.category).toBeDefined();
      expect(result.user).toBeDefined();
    });

    it('should return null when plan not found or user not owner', async () => {
      const planId = validPlans[0]._id;
      const wrongUserId = '507f1f77bcf86cd799439999';
      const updateData = updatePlanDtos.partialUpdate;

      mockPlanModel.findOneAndUpdate.mockReturnValue(createMockQuery(null));

      const result = await planService.updateById(
        planId,
        updateData,
        wrongUserId,
      );

      expect(result).toBeNull();
    });
  });

  describe('removeById', () => {
    it('should throw NotFoundException when user is not the owner', async () => {
      const planId = validPlans[0]._id;
      const wrongUserId = '507f1f77bcf86cd799439999';

      mockPlanModel.findOne.mockReturnValue({
        session: jest.fn().mockResolvedValue(null),
      });

      await expect(planService.removeById(planId, wrongUserId)).rejects.toThrow(
        'Plan not found or not owned by user',
      );
    });

    it('should throw NotFoundException when plan not found', async () => {
      const planId = '507f1f77bcf86cd799439999';
      const userId = validPlans[0].user;

      mockPlanModel.findOne.mockReturnValue({
        session: jest.fn().mockResolvedValue(null),
      });

      await expect(planService.removeById(planId, userId)).rejects.toThrow(
        'Plan not found or not owned by user',
      );
    });

    it('should delete plan when found and user is owner', async () => {
      const planId = validPlans[0]._id;
      const userId = validPlans[0].user;
      const deletedPlan = validPlans[0];

      mockPlanModel.findOne.mockReturnValue({
        session: jest.fn().mockResolvedValue(deletedPlan),
      });

      mockPlanModel.findOneAndDelete.mockReturnValue({
        session: jest.fn().mockResolvedValue(deletedPlan),
      });

      const result = await planService.removeById(planId, userId);

      expect(result).toEqual(deletedPlan);
    });
  });

  describe('special cases', () => {
    it('should handle plan with long title', async () => {
      const longTitlePlan = specialCases.longTitle;

      mockStepService.calculateTotalCost.mockResolvedValue(0);
      mockStepService.calculateTotalDuration.mockResolvedValue(0);

      mockPlanModel.mockImplementation((dto) => ({
        ...dto,
        _id: validPlans[0]._id,
        save: jest.fn().mockResolvedValue({ _id: validPlans[0]._id, ...dto }),
      }));

      mockPlanModel.findById.mockReturnValue(
        createMockQuery({
          _id: validPlans[0]._id,
          title: longTitlePlan.title,
          description: longTitlePlan.description,
          user: { _id: longTitlePlan.user, username: 'testuser' },
          category: { _id: 'cat1', name: 'Test Category' },
          isPublic: longTitlePlan.isPublic,
          steps: longTitlePlan.steps || [],
          favorites: longTitlePlan.favorites || [],
          totalCost: 0,
          totalDuration: 0,
        }),
      );

      const result = await planService.createPlan({
        title: longTitlePlan.title,
        description: longTitlePlan.description,
        user: longTitlePlan.user,
        category: longTitlePlan.category,
        isPublic: longTitlePlan.isPublic,
        steps: longTitlePlan.steps,
        favorites: longTitlePlan.favorites,
      });

      expect(result).toBeDefined();
      expect(result.title).toBe(longTitlePlan.title);
      expect(result.title.length).toBeGreaterThan(50);
    });

    it('should handle plan with empty steps array', async () => {
      const emptyStepsPlan = specialCases.emptySteps;

      mockStepService.calculateTotalCost.mockResolvedValue(0);
      mockStepService.calculateTotalDuration.mockResolvedValue(0);

      mockPlanModel.mockImplementation((dto) => ({
        ...dto,
        _id: validPlans[0]._id,
        save: jest.fn().mockResolvedValue({
          _id: validPlans[0]._id,
          ...dto,
        }),
      }));

      mockPlanModel.findById.mockReturnValue(
        createMockQuery({
          _id: validPlans[0]._id,
          title: emptyStepsPlan.title,
          description: emptyStepsPlan.description,
          user: { _id: emptyStepsPlan.user, username: 'testuser' },
          category: { _id: 'cat1', name: 'Test Category' },
          isPublic: emptyStepsPlan.isPublic,
          steps: [],
          favorites: emptyStepsPlan.favorites || [],
          totalCost: 0,
          totalDuration: 0,
        }),
      );

      const result = await planService.createPlan({
        title: emptyStepsPlan.title,
        description: emptyStepsPlan.description,
        user: emptyStepsPlan.user,
        category: emptyStepsPlan.category,
        isPublic: emptyStepsPlan.isPublic,
        steps: emptyStepsPlan.steps,
        favorites: emptyStepsPlan.favorites,
      });

      expect(result).toBeDefined();
      expect(result.steps).toEqual([]);
      expect(Array.isArray(result.steps)).toBe(true);
      expect(result.steps).toHaveLength(0);
    });

    it('should handle plan with many favorites', async () => {
      const popularPlan = specialCases.manyFavorites;

      const mockSavedPlan = {
        _id: validPlans[0]._id,
        ...popularPlan,
      };

      mockPlanModel.mockImplementation((dto) => ({
        ...dto,
        _id: validPlans[0]._id,
        save: jest.fn().mockResolvedValue(mockSavedPlan),
      }));

      mockPlanModel.findById.mockReturnValue(
        createMockQuery({
          ...mockSavedPlan,
          user: { _id: popularPlan.user, username: 'testuser' },
          category: { _id: 'cat1', name: 'Test Category' },
          steps: popularPlan.steps,
        }),
      );

      const result = await planService.createPlan({
        title: popularPlan.title,
        description: popularPlan.description,
        user: popularPlan.user,
        category: popularPlan.category,
        isPublic: popularPlan.isPublic,
        steps: popularPlan.steps,
        favorites: popularPlan.favorites,
      });

      expect(result.favorites).toHaveLength(5);
      expect(result.favorites).toEqual(popularPlan.favorites);
    });
  });

  describe('findAllByUserId', () => {
    it('should return all plans for owner', async () => {
      const userId = users[0]._id;
      const viewerId = userId;

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(validPlans),
      };

      mockPlanModel.find.mockReturnValue(mockChain);

      const result = await planService.findAllByUserId(userId, viewerId);

      expect(result).toEqual(validPlans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({
        user: expect.any(Object),
      });
    });

    it('should return only public plans for other users', async () => {
      const userId = users[0]._id;
      const viewerId = users[1]._id;

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(publicPlans),
      };

      mockPlanModel.find.mockReturnValue(mockChain);

      const result = await planService.findAllByUserId(userId, viewerId);

      expect(result).toEqual(publicPlans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({
        user: expect.any(Object),
        isPublic: true,
      });
    });
  });

  describe('findFavoritesByUserId', () => {
    it('should return favorite plans for user', async () => {
      const userId = users[0]._id;

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(publicPlans),
      };

      mockPlanModel.find.mockReturnValue(mockChain);

      const result = await planService.findFavoritesByUserId(userId);

      expect(result).toEqual(publicPlans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({ favorites: userId });
    });
  });
});
