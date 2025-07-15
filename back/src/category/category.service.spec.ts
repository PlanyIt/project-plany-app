/* eslint-disable prettier/prettier */
import { Test, TestingModule } from '@nestjs/testing';
import { CategoryService } from './category.service';
import { getModelToken } from '@nestjs/mongoose';

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

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CategoryService,
        {
          provide: getModelToken('Category'),
          useValue: mockCategoryModel,
        },
      ],
    }).compile();

    categoryService = module.get<CategoryService>(CategoryService);
  });

  it('should be defined', () => {
    expect(categoryService).toBeDefined();
  });

  describe('create', () => {
    it('should create and return new category', async () => {
      const result = await categoryService.create(createCategoryDto);

      expect(mockCategoryModel).toHaveBeenCalledWith(createCategoryDto);
      expect(result._id).toBe(mockCategories[0]._id);
      expect(result.name).toBe(createCategoryDto.name);
      expect(result.icon).toBe(createCategoryDto.icon);
      expect(result.color).toBe(createCategoryDto.color);
    });
  });

  describe('findAll', () => {
    it('should return all categories', async () => {
      mockCategoryModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockCategories),
      });

      const result = await categoryService.findAll();

      expect(result).toEqual(mockCategories);
      expect(result).toHaveLength(3);
      expect(mockCategoryModel.find).toHaveBeenCalled();
    });

    it('should return empty array when no categories', async () => {
      mockCategoryModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await categoryService.findAll();

      expect(result).toEqual([]);
      expect(result).toHaveLength(0);
    });
  });

  describe('findById', () => {
    it('should return category when found', async () => {
      const categoryId = mockCategories[0]._id;
      const expectedCategory = mockCategories[0];

      mockCategoryModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedCategory),
      });

      const result = await categoryService.findById(categoryId);

      expect(result).toEqual(expectedCategory);
      expect(mockCategoryModel.findOne).toHaveBeenCalledWith({
        _id: categoryId,
      });
    });

    it('should return null when category not found', async () => {
      mockCategoryModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await categoryService.findById('nonexistent');

      expect(result).toBeNull();
    });
  });

  describe('findByName', () => {
    it('should return category by name', async () => {
      const categoryName = mockCategories[0].name;
      const expectedCategory = mockCategories[0];

      mockCategoryModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedCategory),
      });

      const result = await categoryService.findByName(categoryName);

      expect(result).toEqual(expectedCategory);
      expect(mockCategoryModel.findOne).toHaveBeenCalledWith({
        name: categoryName,
      });
    });

    it('should return null when category name not found', async () => {
      mockCategoryModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await categoryService.findByName('NonExistent');

      expect(result).toBeNull();
    });
  });

  describe('updateById', () => {
    it('should update and return category', async () => {
      const categoryId = mockCategories[0]._id;
      const updatedCategory = {
        ...mockCategories[0],
        ...updateCategoryDto,
      };

      mockCategoryModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedCategory),
      });

      const result = await categoryService.updateById(categoryId, updateCategoryDto);

      expect(result).toEqual(updatedCategory);
      expect(result.name).toBe(updateCategoryDto.name);
      expect(result.icon).toBe(updateCategoryDto.icon);
      expect(result.color).toBe(updateCategoryDto.color);
      expect(mockCategoryModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: categoryId },
        updateCategoryDto,
        { new: true }
      );
    });

    it('should return null when category not found', async () => {
      mockCategoryModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await categoryService.updateById('nonexistent', updateCategoryDto);

      expect(result).toBeNull();
    });
  });

  describe('removeById', () => {
    it('should delete and return category', async () => {
      const categoryId = mockCategories[0]._id;
      const deletedCategory = mockCategories[0];

      mockCategoryModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedCategory),
      });

      const result = await categoryService.removeById(categoryId);

      expect(result).toEqual(deletedCategory);
      expect(mockCategoryModel.findOneAndDelete).toHaveBeenCalledWith({
        _id: categoryId,
      });
    });

    it('should return null when category not found', async () => {
      mockCategoryModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await categoryService.removeById('nonexistent');

      expect(result).toBeNull();
    });
  });
});
