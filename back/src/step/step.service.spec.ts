import { Test, TestingModule } from '@nestjs/testing';
import { StepService } from './step.service';

const mockStepModel = {
  find: jest.fn().mockReturnThis(),
  findOne: jest.fn().mockReturnThis(),
  findOneAndUpdate: jest.fn().mockReturnThis(),
  findOneAndDelete: jest.fn().mockReturnThis(),
  updateMany: jest.fn(),
  save: jest.fn(),
  sort: jest.fn().mockReturnThis(),
  exec: jest.fn(),
};
const mockPlanModel = {
  updateMany: jest.fn(),
};

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
        { provide: 'StepModel', useValue: mockStepModel },
        { provide: 'PlanModel', useValue: mockPlanModel },
      ],
    }).compile();

    service = module.get<StepService>(StepService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all steps', async () => {
      const steps = [{ title: 'Step1' }, { title: 'Step2' }];
      mockStepModel.exec.mockResolvedValueOnce(steps);
      expect(await service.findAll()).toBe(steps);
      expect(mockStepModel.find).toHaveBeenCalled();
    });
  });

  describe('findById', () => {
    it('should return a step by id', async () => {
      const step = { _id: '1', title: 'Test' };
      mockStepModel.exec.mockResolvedValueOnce(step);
      expect(await service.findById('1')).toBe(step);
      expect(mockStepModel.findOne).toHaveBeenCalledWith({ _id: '1' });
    });
    it('should return undefined if not found', async () => {
      mockStepModel.exec.mockResolvedValueOnce(undefined);
      expect(await service.findById('notfound')).toBeUndefined();
    });
  });

  describe('findByIds', () => {
    it('should return steps by ids', async () => {
      const steps = [{ _id: '1' }, { _id: '2' }];
      mockStepModel.exec.mockResolvedValueOnce(steps);
      expect(await service.findByIds(['1', '2'])).toBe(steps);
      expect(mockStepModel.find).toHaveBeenCalledWith({
        _id: { $in: ['1', '2'] },
      });
      expect(mockStepModel.sort).toHaveBeenCalledWith({ order: 1 });
    });
  });

  describe('calculateTotalCost', () => {
    it('should sum cost of steps', async () => {
      const steps = [{ cost: 10 }, { cost: 5 }, { cost: undefined }];
      jest.spyOn(service, 'findByIds').mockResolvedValueOnce(steps as any);
      expect(await service.calculateTotalCost(['1', '2', '3'])).toBe(15);
    });
  });

  describe('calculateTotalDuration', () => {
    it('should sum duration of steps', async () => {
      const steps = [
        { duration: 30 },
        { duration: 15 },
        { duration: undefined },
      ];
      jest.spyOn(service, 'findByIds').mockResolvedValueOnce(steps as any);
      expect(await service.calculateTotalDuration(['1', '2', '3'])).toBe(45);
    });
  });
});
