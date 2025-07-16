/* eslint-disable prettier/prettier */
import { Test, TestingModule } from '@nestjs/testing';
import { CategoryController } from './category.controller';
import { CategoryService } from './category.service';

const mockCategoryService = {
  create: jest.fn(),
  findAll: jest.fn(),
  findById: jest.fn(),
  findByName: jest.fn(),
  updateById: jest.fn(),
  removeById: jest.fn(),
};

describe('CategoryController', () => {
  let categoryController: CategoryController;
  let categoryService: CategoryService;

  const mockCategories = [
    {
      _id: '507f1f77bcf86cd799439011',
      name: 'Voyage',
      description: 'Catégorie pour les plans de voyage',
      color: '#FF6B6B',
      icon: 'travel',
      isActive: true,
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439012',
      name: 'Sport',
      description: 'Catégorie pour les activités sportives',
      color: '#4ECDC4',
      icon: 'fitness',
      isActive: true,
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439013',
      name: 'Cuisine',
      description: 'Catégorie pour les recettes et plans culinaires',
      color: '#45B7D1',
      icon: 'restaurant',
      isActive: true,
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
  ];

  const validCategoryDto: CategoryDto = {
    name: 'Travail',
    color: '#96CEB4',
    icon: 'work',
  };

  const updateCategoryDto: CategoryDto = {
    name: 'Travail Modifié',
    color: '#FFEAA7',
    icon: 'work_outline',
  };

  const mockCategoryService = {
    create: jest.fn(),
    findAll: jest.fn(),
    findByName: jest.fn(),
    findById: jest.fn(),
    updateById: jest.fn(),
    removeById: jest.fn(),
  };

  const mockJwtAuthGuard = {
    canActivate: jest.fn(() => true),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [CategoryController],
      providers: [{ provide: CategoryService, useValue: mockCategoryService }],
    }).compile();

    controller = module.get<CategoryController>(CategoryController);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should create a category', async () => {
    const dto = { name: 'Test', icon: 'icon', color: '#fff' };
    const created = { ...dto, _id: '1' };
    mockCategoryService.create.mockResolvedValueOnce(created);
    expect(await controller.createCategory(dto)).toBe(created);
    expect(mockCategoryService.create).toHaveBeenCalledWith(dto);
  });

  it('should return all categories', async () => {
    const categories = [{ name: 'A' }, { name: 'B' }];
    mockCategoryService.findAll.mockResolvedValueOnce(categories);
    expect(await controller.findAll()).toBe(categories);
    expect(mockCategoryService.findAll).toHaveBeenCalled();
  });

  it('should return category by id', async () => {
    const category = { _id: '1', name: 'Test' };
    mockCategoryService.findById.mockResolvedValueOnce(category);
    expect(await controller.findById('1')).toBe(category);
    expect(mockCategoryService.findById).toHaveBeenCalledWith('1');
  });

  it('should return category by name', async () => {
    const category = { _id: '2', name: 'Test2' };
    mockCategoryService.findByName.mockResolvedValueOnce(category);
    expect(await controller.findByName('Test2')).toBe(category);
    expect(mockCategoryService.findByName).toHaveBeenCalledWith('Test2');
  });

  it('should update a category', async () => {
    const dto = { name: 'Updated', icon: 'icon', color: '#000' };
    const updated = { ...dto, _id: '1' };
    mockCategoryService.updateById.mockResolvedValueOnce(updated);
    expect(await controller.updateCategory('1', dto)).toBe(updated);
    expect(mockCategoryService.updateById).toHaveBeenCalledWith('1', dto);
  });

  it('should remove a category', async () => {
    const removed = { _id: '1', name: 'ToDelete' };
    mockCategoryService.removeById.mockResolvedValueOnce(removed);
    expect(await controller.removeCategory('1')).toBe(removed);
    expect(mockCategoryService.removeById).toHaveBeenCalledWith('1');
  });
});
