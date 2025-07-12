import { Test, TestingModule } from '@nestjs/testing';
import { PlanService } from './plan.service';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';

describe('PlanService', () => {
  let planService: PlanService;

  const mockPlans = [
    {
      _id: '507f1f77bcf86cd799439041',
      title: 'Voyage à Paris',
      description: 'Un merveilleux voyage de 3 jours à Paris',
      user: '507f1f77bcf86cd799439011',
      isPublic: true,
      category: 'Travel',
      steps: ['507f1f77bcf86cd799439051', '507f1f77bcf86cd799439052'],
      favorites: ['507f1f77bcf86cd799439012'],
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439042',
      title: 'Programme Fitness',
      description: "Plan d'entraînement pour débutants",
      user: '507f1f77bcf86cd799439012',
      isPublic: true,
      category: 'Fitness',
      steps: ['507f1f77bcf86cd799439053'],
      favorites: [],
      createdAt: new Date('2024-01-20T11:00:00.000Z'),
      updatedAt: new Date('2024-01-20T11:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439043',
      title: 'Plan Privé',
      description: 'Mon plan personnel',
      user: '507f1f77bcf86cd799439011',
      isPublic: false,
      category: 'Personal',
      steps: [],
      favorites: null,
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
    },
    {
      _id: '507f1f77bcf86cd799439012',
      username: 'janedoe',
      email: 'jane@plany.com',
      photoUrl: 'https://example.com/jane.jpg',
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
    category: 'Education',
    steps: [],
    favorites: [],
  };

  const updatePlanDto = {
    title: 'Plan Mis à Jour',
    description: 'Description mise à jour',
    user: '507f1f77bcf86cd799439011',
    isPublic: false,
    category: 'Work',
    steps: [],
    favorites: [],
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

  const mockUserModel = {
    findById: jest.fn().mockReturnValue({
      exec: jest.fn(),
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
          provide: getModelToken('User'),
          useValue: mockUserModel,
        },
      ],
    }).compile();

    planService = module.get<PlanService>(PlanService);
  });

  it('should be defined', () => {
    expect(planService).toBeDefined();
  });

  describe('createPlan', () => {
    it('should create and return new plan', async () => {
      const result = await planService.createPlan(createPlanDto);

      expect(mockPlanModel).toHaveBeenCalledWith(createPlanDto);
      expect(result._id).toBe(mockPlans[0]._id);
      expect(result.title).toBe(createPlanDto.title);
      expect(result.description).toBe(createPlanDto.description);
      expect(result.category).toBe(createPlanDto.category);
    });
  });

  describe('findAll', () => {
    it('should return all plans with populated user and steps', async () => {
      const plansWithPopulated = mockPlans.map((plan) => ({
        ...plan,
        user: mockUsers.find((u) => u._id === plan.user),
        steps: mockSteps.filter((s) => plan.steps.includes(s._id)),
      }));

      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(plansWithPopulated),
      });

      const result = await planService.findAll();

      expect(result).toEqual(plansWithPopulated);
      expect(mockPlanModel.find).toHaveBeenCalled();
    });

    it('should return empty array when no plans', async () => {
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
    it('should return plan when found', async () => {
      const planId = mockPlans[0]._id;
      const expectedPlan = {
        ...mockPlans[0],
        user: mockUsers[0],
        steps: mockSteps,
      };

      mockPlanModel.findOne.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(expectedPlan),
      });

      const result = await planService.findById(planId);

      expect(result).toEqual(expectedPlan);
      expect(mockPlanModel.findOne).toHaveBeenCalledWith({ _id: planId });
    });

    it('should return null when plan not found', async () => {
      mockPlanModel.findOne.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await planService.findById('nonexistent');

      expect(result).toBeNull();
    });
  });

  describe('findAllByUserId', () => {
    it('should return user plans', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const userPlans = mockPlans.filter((plan) => plan.user === userId);

      mockPlanModel.find.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        sort: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(userPlans),
      });

      const result = await planService.findAllByUserId(userId);

      expect(result).toEqual(userPlans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({ user: userId });
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
  });

  describe('updateById', () => {
    it('should update and return plan', async () => {
      const planId = mockPlans[0]._id;
      const userId = mockPlans[0].user;
      const updatedPlan = {
        ...mockPlans[0],
        ...updatePlanDto,
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedPlan),
      });

      const result = await planService.updateById(
        planId,
        updatePlanDto,
        userId,
      );

      expect(result).toEqual(updatedPlan);
      expect(mockPlanModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: planId, user: userId },
        updatePlanDto,
        { new: true },
      );
    });

    it('should return null when plan not found or user unauthorized', async () => {
      mockPlanModel.findOneAndUpdate.mockReturnValue({
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
    it('should delete and return plan', async () => {
      const planId = mockPlans[0]._id;
      const userId = mockPlans[0].user;
      const deletedPlan = mockPlans[0];

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

    it('should return null when plan not found or user unauthorized', async () => {
      mockPlanModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await planService.removeById(
        'nonexistent',
        'unauthorized',
      );

      expect(result).toBeNull();
    });
  });

  describe('addStepToPlan', () => {
    it('should add step to plan', async () => {
      const planId = mockPlans[0]._id;
      const stepId = '507f1f77bcf86cd799439054';
      const updatedPlan = {
        ...mockPlans[0],
        steps: [...mockPlans[0].steps, stepId],
      };

      mockPlanModel.findOneAndUpdate.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(updatedPlan),
      });

      const result = await planService.addStepToPlan(planId, stepId);

      expect(result).toEqual(updatedPlan);
      expect(mockPlanModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: planId },
        { $push: { steps: stepId } },
        { new: true },
      );
    });

    it('should return null when plan not found', async () => {
      mockPlanModel.findOneAndUpdate.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await planService.addStepToPlan('nonexistent', 'stepId');

      expect(result).toBeNull();
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

  describe('countUserPlans', () => {
    it('should return count of user plans', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const count = 2;

      mockPlanModel.countDocuments.mockReturnValue({
        exec: jest.fn().mockResolvedValue(count),
      });

      const result = await planService.countUserPlans(userId);

      expect(result).toBe(count);
      expect(mockPlanModel.countDocuments).toHaveBeenCalledWith({
        user: userId,
      });
    });
  });

  describe('countUserFavorites', () => {
    it('should return count of user favorites', async () => {
      const userId = '507f1f77bcf86cd799439012';
      const count = 1;

      mockPlanModel.countDocuments.mockReturnValue({
        exec: jest.fn().mockResolvedValue(count),
      });

      const result = await planService.countUserFavorites(userId);

      expect(result).toBe(count);
      expect(mockPlanModel.countDocuments).toHaveBeenCalledWith({
        favorites: userId,
      });
    });
  });

  describe('fixNullFavorites', () => {
    it('should fix null favorites arrays', async () => {
      const updateResult = { modifiedCount: 3 };

      mockPlanModel.updateMany.mockResolvedValue(updateResult);

      const result = await planService.fixNullFavorites();

      expect(result).toEqual(updateResult);
      expect(mockPlanModel.updateMany).toHaveBeenCalledWith(
        { favorites: null },
        { $set: { favorites: [] } },
      );
    });
  });
});
