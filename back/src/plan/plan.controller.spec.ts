import { Test, TestingModule } from '@nestjs/testing';
import { PlanController } from './plan.controller';
import { PlanService } from './plan.service';
import { UserService } from '../user/user.service';

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
const mockUserService = {};

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
        { provide: PlanService, useValue: mockPlanService },
        { provide: UserService, useValue: mockUserService },
      ],
    }).compile();

    controller = module.get<PlanController>(PlanController);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should return all plans', async () => {
    mockPlanService.findAll.mockResolvedValue(['plan1', 'plan2']);
    expect(await controller.findAll()).toEqual(['plan1', 'plan2']);
  });

  it('should return plan by id', async () => {
    mockPlanService.findById.mockResolvedValue({ _id: '1' });
    expect(await controller.findById('1')).toEqual({ _id: '1' });
  });

  it('should create a plan', async () => {
    const dto = { title: 't', steps: [], category: 'c' };
    const req = { user: { _id: 'u1' } };
    mockPlanService.createPlan.mockResolvedValue({ _id: 'p1' });
    expect(await controller.createPlan(dto as any, req)).toEqual({ _id: 'p1' });
    expect(mockPlanService.createPlan).toHaveBeenCalledWith({
      ...dto,
      user: 'u1',
    });
  });

  it('should update a plan', async () => {
    const dto = { title: 't', steps: [], category: 'c' };
    mockPlanService.updateById.mockResolvedValue({ _id: 'p1', title: 't' });
    expect(await controller.updatePlan('p1', dto as any, 'u1')).toEqual({
      _id: 'p1',
      title: 't',
    });
    expect(mockPlanService.updateById).toHaveBeenCalledWith('p1', dto, 'u1');
  });

  it('should remove a plan', async () => {
    mockPlanService.removeById.mockResolvedValue({ _id: 'p1' });
    const req = { user: { _id: 'u1' } };
    expect(await controller.removePlan('p1', req)).toEqual({ _id: 'p1' });
    expect(mockPlanService.removeById).toHaveBeenCalledWith('p1', 'u1');
  });

  it('should add to favorites', async () => {
    mockPlanService.addToFavorites.mockResolvedValue({
      _id: 'p1',
      favorites: ['u1'],
    });
    const req = { user: { _id: 'u1' } };
    expect(await controller.addToFavorites('p1', req)).toEqual({
      _id: 'p1',
      favorites: ['u1'],
    });
    expect(mockPlanService.addToFavorites).toHaveBeenCalledWith('p1', 'u1');
  });

  it('should remove from favorites', async () => {
    mockPlanService.removeFromFavorites.mockResolvedValue({
      _id: 'p1',
      favorites: [],
    });
    const req = { user: { _id: 'u1' } };
    expect(await controller.removeFromFavorites('p1', req)).toEqual({
      _id: 'p1',
      favorites: [],
    });
    expect(mockPlanService.removeFromFavorites).toHaveBeenCalledWith(
      'p1',
      'u1',
    );
  });

  it('should return all plans by user id', async () => {
    mockPlanService.findAllByUserId.mockResolvedValue(['plan1']);
    const req = { user: { _id: 'u1' } };
    expect(await controller.findAllByUserId('u1', req)).toEqual(['plan1']);
    expect(mockPlanService.findAllByUserId).toHaveBeenCalledWith('u1', 'u1');
  });

  it('should return favorites by user id', async () => {
    mockPlanService.findFavoritesByUserId.mockResolvedValue(['fav1']);
    expect(await controller.findFavoritesByUserId('u1')).toEqual(['fav1']);
    expect(mockPlanService.findFavoritesByUserId).toHaveBeenCalledWith('u1');
  });
});
