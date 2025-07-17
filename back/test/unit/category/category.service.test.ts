import { Test, TestingModule } from '@nestjs/testing';
import { CategoryService } from '../../../src/category/category.service';
import { getModelToken } from '@nestjs/mongoose';
import * as categoryFixtures from '../../__fixtures__/categories.json';

describe('CategoryService', () => {
  let categoryService: CategoryService;

  const { validCategories, createCategoryDtos, updateCategoryDtos } =
    categoryFixtures;

  const mockCategoryModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: validCategories[0]._id,
    createdAt: new Date(validCategories[0].createdAt),
    updatedAt: new Date(validCategories[0].updatedAt),
    save: jest.fn().mockResolvedValue({
      _id: validCategories[0]._id,
      ...dto,
      createdAt: new Date(validCategories[0].createdAt),
      updatedAt: new Date(validCategories[0].updatedAt),
    }),
  })) as any;

  mockCategoryModel.find = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCategoryModel.findOne = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCategoryModel.findById = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCategoryModel.findOneAndUpdate = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCategoryModel.findOneAndDelete = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  const mockPlanModel = {
    find: jest.fn().mockReturnValue({
      exec: jest.fn(),
    }),
    findOne: jest.fn().mockReturnValue({
      exec: jest.fn(),
    }),
    findById: jest.fn().mockReturnValue({
      exec: jest.fn(),
    }),
    countDocuments: jest.fn().mockReturnValue({
      exec: jest.fn().mockResolvedValue(0),
    }),
    create: jest.fn(),
    save: jest.fn(),
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
      const createData = createCategoryDtos.validCreate;

      const result = await categoryService.create(createData);

      expect(mockCategoryModel).toHaveBeenCalledWith(createData);
      expect(result._id).toBe(validCategories[0]._id);
      expect(result.name).toBe(createData.name);
      expect(result.icon).toBe(createData.icon);
      expect(result.color).toBe(createData.color);
    });

    it('should create category with minimal data', async () => {
      const createData = createCategoryDtos.minimalCreate;

      const result = await categoryService.create(createData);

      expect(result.name).toBe(createData.name);
      expect(result.icon).toBe(createData.icon);
      expect(result.color).toBe(createData.color);
    });
  });

  describe('findAll', () => {
    it('should return all categories', async () => {
      mockCategoryModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(validCategories),
      });

      const result = await categoryService.findAll();

      expect(result).toEqual(validCategories);
      expect(result).toHaveLength(3);
      expect(mockCategoryModel.find).toHaveBeenCalled();
    });
  });

  describe('findById', () => {
    it('should return category when found', async () => {
      const categoryId = validCategories[0]._id;
      const expectedCategory = validCategories[0];

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

  describe('updateById', () => {
    it('should update and return category', async () => {
      const categoryId = validCategories[0]._id;
      const updateData = updateCategoryDtos.partialUpdate;

      const updatedCategory = {
        ...validCategories[0],
        ...updateData,
      };

      mockCategoryModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedCategory),
      });

      const result = await categoryService.updateById(categoryId, updateData);

      expect(result).toEqual(updatedCategory);
      expect(result.name).toBe(updateData.name);
      expect(result.color).toBe(updateData.color);
    });

    it('should return null when category not found', async () => {
      mockCategoryModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await categoryService.updateById(
        'nonexistent',
        updateCategoryDtos.partialUpdate,
      );

      expect(result).toBeNull();
    });
  });

  describe('removeById', () => {
    it('should delete and return category', async () => {
      const categoryId = validCategories[0]._id;
      const deletedCategory = validCategories[0];

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

    it('should throw BadRequestException when plans use this category', async () => {
      const categoryId = validCategories[0]._id;

      mockPlanModel.countDocuments.mockReturnValue({
        exec: jest.fn().mockResolvedValue(3),
      });

      await expect(categoryService.removeById(categoryId)).rejects.toThrow(
        "Impossible de supprimer cette catégorie. 3 plan(s) l'utilise(nt) encore.",
      );

      expect(mockPlanModel.countDocuments).toHaveBeenCalledWith({
        category: categoryId,
      });
      expect(mockCategoryModel.findOneAndDelete).not.toHaveBeenCalled();
    });
  });

  describe('findByName', () => {
    it('should return category by name', async () => {
      const categoryName = validCategories[0].name;
      const expectedCategory = validCategories[0];

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
});
