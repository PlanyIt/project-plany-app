/* eslint-disable prettier/prettier */
import { Test, TestingModule } from '@nestjs/testing';
import { CategoryService } from './category.service';
import { getModelToken } from '@nestjs/mongoose';
import { BadRequestException } from '@nestjs/common';

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
        {
          provide: getModelToken('Category'),
          useValue: mockCategoryModel,
        },
        {
          provide: getModelToken('Plan'),
          useValue: mockPlanModel,
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
    it('should delete and return category when no plans use it', async () => {
      const categoryId = mockCategories[0]._id;
      const deletedCategory = mockCategories[0];

      mockPlanModel.countDocuments.mockReturnValue({
        exec: jest.fn().mockResolvedValue(0),
      });

      mockCategoryModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedCategory),
      });

      const result = await categoryService.removeById(categoryId);

      expect(result).toEqual(deletedCategory);
      expect(mockPlanModel.countDocuments).toHaveBeenCalledWith({
        category: categoryId,
      });
      expect(mockCategoryModel.findOneAndDelete).toHaveBeenCalledWith({
        _id: categoryId,
      });
    });

    it('should return null when category not found', async () => {
      mockPlanModel.countDocuments.mockReturnValue({
        exec: jest.fn().mockResolvedValue(0),
      });

      mockCategoryModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await categoryService.removeById('nonexistent');

      expect(result).toBeNull();
    });

    it('should throw BadRequestException when category is used by plans', async () => {
      const categoryId = mockCategories[0]._id;

      mockPlanModel.countDocuments.mockReturnValue({
        exec: jest.fn().mockResolvedValue(3),
      });

      await expect(categoryService.removeById(categoryId)).rejects.toThrow(
        BadRequestException,
      );
      await expect(categoryService.removeById(categoryId)).rejects.toThrow(
        'Impossible de supprimer cette catégorie. 3 plan(s) l\'utilise(nt) encore.',
      );

      expect(mockPlanModel.countDocuments).toHaveBeenCalledWith({
        category: categoryId,
      });
      expect(mockCategoryModel.findOneAndDelete).not.toHaveBeenCalled();
    });
  });

  describe('Database errors', () => {
    it('should handle database errors in create', async () => {
      const mockSave = jest.fn().mockRejectedValue(new Error('Database connection failed'));
      mockCategoryModel.mockImplementation(() => ({ save: mockSave }));

      await expect(categoryService.create(createCategoryDto)).rejects.toThrow(
        'Database connection failed',
      );
    });

    it('should handle duplicate key error in create', async () => {
      const duplicateError = new Error('Duplicate key error');
      Object.assign(duplicateError, { code: 11000, keyPattern: { name: 1 } });
      
      const mockSave = jest.fn().mockRejectedValue(duplicateError);
      
      jest.clearAllMocks();
      mockCategoryModel.mockImplementation(() => ({ save: mockSave }));

      await expect(categoryService.create(createCategoryDto)).rejects.toThrow();
    });

    it('should handle database errors in findAll', async () => {
      mockCategoryModel.find.mockReturnValue({
        exec: jest.fn().mockRejectedValue(new Error('Database error')),
      });

      await expect(categoryService.findAll()).rejects.toThrow('Database error');
    });
  });
});
