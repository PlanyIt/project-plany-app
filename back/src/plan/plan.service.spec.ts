import { Test, TestingModule } from '@nestjs/testing';
import { PlanService } from './plan.service';
import { StepService } from '../step/step.service';

// Helper pour chaînage .populate().populate().exec()
function mockQuery(result) {
  return {
    populate: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    exec: jest.fn().mockResolvedValue(result),
  };
}

const mockPlanModel = {
  find: jest.fn(),
  findById: jest.fn(),
  findOne: jest.fn(),
  findOneAndUpdate: jest.fn(),
  findOneAndDelete: jest.fn(),
  findByIdAndUpdate: jest.fn(),
  updateOne: jest.fn(),
  deleteMany: jest.fn(),
  save: jest.fn(),
};
const mockStepModel = {
  deleteMany: jest.fn().mockReturnThis(),
  exec: jest.fn(),
};
const mockCommentModel = {
  deleteMany: jest.fn().mockReturnThis(),
  exec: jest.fn(),
};
const mockDatabaseConnection = {
  startSession: jest.fn().mockResolvedValue({
    withTransaction: jest.fn((cb) => cb()),
    endSession: jest.fn(),
  }),
};
const mockStepService = {
  calculateTotalCost: jest.fn(),
  calculateTotalDuration: jest.fn(),
};

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
        { provide: 'PlanModel', useValue: mockPlanModel },
        { provide: 'StepModel', useValue: mockStepModel },
        { provide: 'CommentModel', useValue: mockCommentModel },
        { provide: 'DatabaseConnection', useValue: mockDatabaseConnection },
        { provide: StepService, useValue: mockStepService },
      ],
    }).compile();

    service = module.get<PlanService>(PlanService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all public plans', async () => {
      const plans = [{ title: 'Plan1' }, { title: 'Plan2' }];
      mockPlanModel.find.mockReturnValue(mockQuery(plans));
      expect(await service.findAll()).toBe(plans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({ isPublic: true });
    });
  });

  describe('findById', () => {
    it('should return a plan by id', async () => {
      const plan = { _id: '1', title: 'Test' };
      mockPlanModel.findById.mockReturnValue(mockQuery(plan));
      expect(await service.findById('507f1f77bcf86cd799439011')).toBe(plan);
      expect(mockPlanModel.findById).toHaveBeenCalledWith(
        '507f1f77bcf86cd799439011',
      );
    });
    it('should throw if id is invalid', async () => {
      await expect(service.findById('invalid')).rejects.toThrow();
    });
  });

  describe('findAllByUserId', () => {
    it('should return all plans for owner', async () => {
      const plans = [{ title: 'Plan1' }];
      mockPlanModel.find.mockReturnValue(mockQuery(plans));
      expect(
        await service.findAllByUserId(
          '507f1f77bcf86cd799439011',
          '507f1f77bcf86cd799439011',
        ),
      ).toBe(plans);
    });
    it('should return only public plans for other users', async () => {
      const plans = [{ title: 'Plan2' }];
      mockPlanModel.find.mockReturnValue(mockQuery(plans));
      expect(
        await service.findAllByUserId('507f1f77bcf86cd799439011', 'other'),
      ).toBe(plans);
    });
  });

  describe('findFavoritesByUserId', () => {
    it('should return favorite plans', async () => {
      const plans = [{ title: 'Fav1' }];
      mockPlanModel.find.mockReturnValue(mockQuery(plans));
      expect(await service.findFavoritesByUserId('user1')).toBe(plans);
      expect(mockPlanModel.find).toHaveBeenCalledWith({ favorites: 'user1' });
    });
  });
});
