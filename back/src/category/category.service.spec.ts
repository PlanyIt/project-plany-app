/* eslint-disable prettier/prettier */
import { Test, TestingModule } from '@nestjs/testing';
import { CategoryService } from './category.service';
import { BadRequestException } from '@nestjs/common';

const mockCategoryModel = {
  find: jest.fn().mockReturnThis(),
  exec: jest.fn(),
  findOne: jest.fn().mockReturnThis(),
  save: jest.fn(),
  findOneAndUpdate: jest.fn().mockReturnThis(),
  findOneAndDelete: jest.fn().mockReturnThis(),
};

const mockPlanModel = {
  countDocuments: jest.fn().mockReturnThis(),
  exec: jest.fn(),
};

describe('CategoryService', () => {
  let categoryService: CategoryService;

  const mockCategories = [
    {
      _id: '507f1f77bcf86cd799439021',
      name: 'Fitness',
      icon: 'dumbbell',
      color: '#FF6B6B',
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z')
    },
    {
      _id: '507f1f77bcf86cd799439022',
      name: 'Travel',
      icon: 'plane',
      color: '#4ECDC4',
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z')
    },
    {
      _id: '507f1f77bcf86cd799439023',
      name: 'Food',
      icon: 'utensils',
      color: '#45B7D1',
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z')
    }
  ];

  const createCategoryDto = {
    name: 'Education',
    icon: 'book',
    color: '#96CEB4'
  };

  const updateCategoryDto = {
    name: 'Updated Fitness',
    icon: 'updated-dumbbell',
    color: '#E74C3C'
  };

  const mockCategoryModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: mockCategories[0]._id,
    createdAt: mockCategories[0].createdAt,
    updatedAt: mockCategories[0].updatedAt,
    save: jest.fn().mockResolvedValue({
      _id: mockCategories[0]._id,
      ...dto,
      createdAt: mockCategories[0].createdAt,
      updatedAt: mockCategories[0].updatedAt,
    }),
  })) as any;

  mockCategoryModel.find = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCategoryModel.findOne = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCategoryModel.findOneAndUpdate = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCategoryModel.findOneAndDelete = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  const mockPlanModel = {
    countDocuments: jest.fn().mockReturnValue({
      exec: jest.fn(),
    }),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CategoryService,
        { provide: 'CategoryModel', useValue: mockCategoryModel },
        { provide: 'PlanModel', useValue: mockPlanModel },
      ],
    }).compile();

    service = module.get<CategoryService>(CategoryService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all categories', async () => {
      const categories = [{ name: 'A' }, { name: 'B' }];
      mockCategoryModel.exec.mockResolvedValueOnce(categories);
      expect(await service.findAll()).toBe(categories);
      expect(mockCategoryModel.find).toHaveBeenCalled();
    });
  });

  describe('findById', () => {
    it('should return a category by id', async () => {
      const category = { _id: '1', name: 'Test' };
      mockCategoryModel.exec.mockResolvedValueOnce(category);
      expect(await service.findById('1')).toBe(category);
      expect(mockCategoryModel.findOne).toHaveBeenCalledWith({ _id: '1' });
    });
  });

  describe('findByName', () => {
    it('should return a category by name', async () => {
      const category = { _id: '2', name: 'Test2' };
      mockCategoryModel.exec.mockResolvedValueOnce(category);
      expect(await service.findByName('Test2')).toBe(category);
      expect(mockCategoryModel.findOne).toHaveBeenCalledWith({ name: 'Test2' });
    });
  });

  describe('create', () => {
    it('should create and return a new category', async () => {
      const dto = { name: 'New', icon: 'icon', color: '#fff' };
      const saveMock = jest.fn().mockResolvedValue(dto);
      // simulate new this.categoryModel(dto)
      (mockCategoryModel as any).constructor = function (d: any) {
        return { ...d, save: saveMock };
      };
      const serviceInstance = new (CategoryService as any)(
        mockCategoryModel.constructor,
        mockPlanModel,
      );
      expect(await serviceInstance.create(dto)).toBe(dto);
      expect(saveMock).toHaveBeenCalled();
    });
  });

  describe('updateById', () => {
    it('should update and return the category', async () => {
      const updated = { _id: '1', name: 'Updated' };
      mockCategoryModel.exec.mockResolvedValueOnce(updated);
      const updateDto = { name: 'Updated', icon: 'icon', color: '#fff' };
      expect(await service.updateById('1', updateDto)).toBe(updated);
      expect(mockCategoryModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: '1' },
        updateDto,
        { new: true },
      );
    });
  });

  describe('removeById', () => {
    it('should throw if plans use the category', async () => {
      mockPlanModel.exec.mockResolvedValueOnce(2);
      await expect(service.removeById('cat1')).rejects.toThrow(
        BadRequestException,
      );
      expect(mockPlanModel.countDocuments).toHaveBeenCalledWith({
        category: 'cat1',
      });
    });

    it('should delete and return the category if not used', async () => {
      mockPlanModel.exec.mockResolvedValueOnce(0);
      const deleted = { _id: 'cat1', name: 'ToDelete' };
      mockCategoryModel.exec.mockResolvedValueOnce(deleted);
      expect(await service.removeById('cat1')).toBe(deleted);
      expect(mockCategoryModel.findOneAndDelete).toHaveBeenCalledWith({
        _id: 'cat1',
      });
    });
  });
});
