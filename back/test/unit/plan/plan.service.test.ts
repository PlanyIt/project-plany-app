import { Test, TestingModule } from '@nestjs/testing';
import { PlanService } from '../../../src/plan/plan.service';
import { getModelToken } from '@nestjs/mongoose';
import * as planFixtures from '../../__fixtures__/plans.json';

describe('PlanService', () => {
  let planService: PlanService;

  const {
    validPlans,
    publicPlans,
    createPlanDtos,
    updatePlanDtos,
    planWithSteps,
    planOperations,
    favoriteOperations,
    users,
    specialCases,
    updateResults,
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
      const result = await planService.createPlan(createPlanDtos.validCreate);

      expect(mockPlanModel).toHaveBeenCalledWith(createPlanDtos.validCreate);
      expect(result._id).toBe(validPlans[0]._id);
      expect(result.title).toBe(createPlanDtos.validCreate.title);
      expect(result.description).toBe(createPlanDtos.validCreate.description);
      expect(result.user).toBe(createPlanDtos.validCreate.user);
      expect(result.category).toBe(createPlanDtos.validCreate.category);
      expect(result.isPublic).toBe(createPlanDtos.validCreate.isPublic);
    });

    it('should create private plan', async () => {
      const result = await planService.createPlan(createPlanDtos.privateCreate);

      expect(result.isPublic).toBe(createPlanDtos.privateCreate.isPublic);
      expect(result.category).toBe(createPlanDtos.privateCreate.category);
    });

    it('should create plan with default values', async () => {
      const result = await planService.createPlan(createPlanDtos.minimalCreate);

      expect(result.title).toBe(createPlanDtos.minimalCreate.title);
      expect(result.description).toBe(createPlanDtos.minimalCreate.description);
      expect(result.category).toBe(createPlanDtos.minimalCreate.category);
      expect(result.user).toBe(createPlanDtos.minimalCreate.user);
    });

    it('should create plan with steps', async () => {
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
    it('should return plan with populated data when found', async () => {
      const planId = planWithSteps._id;

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(planWithSteps),
      };

      mockPlanModel.findOne.mockReturnValue(mockChain);

      const result = await planService.findById(planId);

      expect(result).toEqual(planWithSteps);
      expect(result.category).toBe(planWithSteps.category);
      expect(result.isPublic).toBe(planWithSteps.isPublic);
      expect(result.favorites).toHaveLength(planWithSteps.favorites.length);
      expect(result.steps).toHaveLength(planWithSteps.steps.length);
    });

    it('should return null when plan not found', async () => {
      const planId = '507f1f77bcf86cd799439999';

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(null),
      };

      mockPlanModel.findOne.mockReturnValue(mockChain);

      const result = await planService.findById(planId);

      expect(result).toBeNull();
    });
  });

  describe('addStepToPlan', () => {
    it('should add step to plan steps array', async () => {
      const planId = planOperations.afterAddStep._id;
      const stepId = planOperations.afterAddStep.steps[0];

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(planOperations.afterAddStep),
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue(mockChain);

      const result = await planService.addStepToPlan(planId, stepId);

      expect(result).toEqual(planOperations.afterAddStep);
      expect(mockPlanModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: planId },
        { $push: { steps: stepId } },
        { new: true },
      );
      expect(result.steps).toContain(stepId);
      expect(result.steps).toHaveLength(1);
    });

    it('should add multiple steps to existing steps array', async () => {
      const planId = planOperations.afterAddMultipleSteps._id;
      const newStepId = planOperations.afterAddMultipleSteps.steps[1];

      const mockChain = {
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(planOperations.afterAddMultipleSteps),
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue(mockChain);

      const result = await planService.addStepToPlan(planId, newStepId);

      expect(result.steps).toHaveLength(2);
      expect(result.steps).toContain(newStepId);
      expect(result.steps).toContain(
        planOperations.afterAddMultipleSteps.steps[0],
      );
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
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedPlan),
      });

      const result = await planService.updateById(planId, updateData, userId);

      expect(result).toEqual(updatedPlan);
      expect(result.category).toBe(updateData.category);
      expect(result.isPublic).toBe(updateData.isPublic);
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
        category: updateData.category,
        user: userId,
        isPublic: validPlans[0].isPublic,
        steps: validPlans[0].steps,
        favorites: validPlans[0].favorites,
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedPlan),
      });

      const result = await planService.updateById(planId, updateData, userId);

      expect(result.title).toBe(updateData.title);
      expect(result.category).toBe(updateData.category);
      expect(result.description).toBe(validPlans[0].description);
    });

    it('should return null when plan not found or user not owner', async () => {
      const planId = validPlans[0]._id;
      const wrongUserId = '507f1f77bcf86cd799439999';
      const updateData = updatePlanDtos.partialUpdate;

      mockPlanModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await planService.updateById(
        planId,
        updateData,
        wrongUserId,
      );

      expect(result).toBeNull();
    });
  });

  describe('fixNullFavorites', () => {
    it('should fix all plans with null favorites to empty array', async () => {
      mockPlanModel.updateMany.mockResolvedValue(
        updateResults.fixNullFavorites,
      );

      const result = await planService.fixNullFavorites();

      expect(result).toEqual(updateResults.fixNullFavorites);
      expect(result.modifiedCount).toBe(5);
      expect(mockPlanModel.updateMany).toHaveBeenCalledWith(
        { favorites: null },
        { $set: { favorites: [] } },
      );
    });

    it('should return zero modified when no plans have null favorites', async () => {
      const noModifiedResult = {
        acknowledged: true,
        modifiedCount: 0,
        upsertedId: null,
        upsertedCount: 0,
        matchedCount: 0,
      };

      mockPlanModel.updateMany.mockResolvedValue(noModifiedResult);

      const result = await planService.fixNullFavorites();

      expect(result.modifiedCount).toBe(0);
      expect(result.acknowledged).toBe(true);
    });
  });

  describe('removeById', () => {
    it('should delete plan when found and user is owner', async () => {
      const planId = validPlans[0]._id;
      const userId = validPlans[0].user;
      const deletedPlan = validPlans[0];

      mockPlanModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedPlan),
      });

      const result = await planService.removeById(planId, userId);

      expect(result).toEqual(deletedPlan);
      expect(mockPlanModel.findOneAndDelete).toHaveBeenCalledWith({
        _id: planId,
        user: userId,
      });
    });

    it('should return null when plan not found', async () => {
      const planId = '507f1f77bcf86cd799439999';
      const userId = validPlans[0].user;

      mockPlanModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await planService.removeById(planId, userId);

      expect(result).toBeNull();
    });

    it('should return null when user is not the owner', async () => {
      const planId = validPlans[0]._id;
      const wrongUserId = '507f1f77bcf86cd799439999';

      mockPlanModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await planService.removeById(planId, wrongUserId);

      expect(result).toBeNull();
      expect(mockPlanModel.findOneAndDelete).toHaveBeenCalledWith({
        _id: planId,
        user: wrongUserId,
      });
    });
  });

  describe('special cases', () => {
    it('should handle plan with long title', async () => {
      const longTitlePlan = specialCases.longTitle;

      const result = await planService.createPlan({
        title: longTitlePlan.title,
        description: longTitlePlan.description,
        user: longTitlePlan.user,
        category: longTitlePlan.category,
        isPublic: longTitlePlan.isPublic,
        steps: longTitlePlan.steps,
        favorites: longTitlePlan.favorites,
      });

      expect(result.title).toBe(longTitlePlan.title);
      expect(result.title.length).toBeGreaterThan(50);
    });

    it('should handle plan with empty steps array', async () => {
      const emptyStepsPlan = specialCases.emptySteps;

      const result = await planService.createPlan({
        title: emptyStepsPlan.title,
        description: emptyStepsPlan.description,
        user: emptyStepsPlan.user,
        category: emptyStepsPlan.category,
        isPublic: emptyStepsPlan.isPublic,
        steps: emptyStepsPlan.steps,
        favorites: emptyStepsPlan.favorites,
      });

      expect(result.steps).toEqual([]);
      expect(Array.isArray(result.steps)).toBe(true);
      expect(result.steps).toHaveLength(0);
    });

    it('should handle plan with many favorites', async () => {
      const popularPlan = specialCases.manyFavorites;

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
});
