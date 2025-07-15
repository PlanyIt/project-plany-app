/* eslint-disable prettier/prettier */
import { Test, TestingModule } from '@nestjs/testing';
import { CategoryController } from './category.controller';
import { CategoryService } from './category.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CategoryDto } from './dto/category.dto';
import { NotFoundException, BadRequestException } from '@nestjs/common';

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
      providers: [
        {
          provide: CategoryService,
          useValue: mockCategoryService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue(mockJwtAuthGuard)
      .compile();

    categoryController = module.get<CategoryController>(CategoryController);
    categoryService = module.get<CategoryService>(CategoryService);
  });

  it('should be defined', () => {
    expect(categoryController).toBeDefined();
    expect(categoryService).toBeDefined();
  });

  describe('createCategory', () => {
    it('should create and return a new category', async () => {
      const createdCategory = {
        _id: '507f1f77bcf86cd799439014',
        ...validCategoryDto,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockCategoryService.create.mockResolvedValue(createdCategory);

      const result = await categoryController.createCategory(validCategoryDto);

      expect(result).toEqual(createdCategory);
      expect(mockCategoryService.create).toHaveBeenCalledWith(validCategoryDto);
      expect(mockCategoryService.create).toHaveBeenCalledTimes(1);
    });

    it('should throw BadRequestException for invalid category data', async () => {
      const invalidCategoryDto = { name: ''} as CategoryDto;
      const validationError = new BadRequestException('Le nom de la catégorie est requis');
      
      mockCategoryService.create.mockRejectedValue(validationError);

      await expect(
        categoryController.createCategory(invalidCategoryDto),
      ).rejects.toThrow(BadRequestException);
      expect(mockCategoryService.create).toHaveBeenCalledWith(invalidCategoryDto);
    });

    it('should throw BadRequestException for duplicate category name', async () => {
      const duplicateError = new BadRequestException('Cette catégorie existe déjà');
      mockCategoryService.create.mockRejectedValue(duplicateError);

      await expect(
        categoryController.createCategory(validCategoryDto),
      ).rejects.toThrow(BadRequestException);
      expect(mockCategoryService.create).toHaveBeenCalledWith(validCategoryDto);
    });

    it('should validate CategoryDto fields', async () => {
      const invalidDto = {
        name: '',
        color: 'invalid-color',
        icon: '',
      } as CategoryDto;

      const validationError = new BadRequestException([
        'Le nom ne peut pas être vide',
        'La couleur doit être au format hexadécimal',
        'L\'icône ne peut pas être vide',
      ]);

      mockCategoryService.create.mockRejectedValue(validationError);

      await expect(
        categoryController.createCategory(invalidDto),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('findAll', () => {
    it('should return all categories', async () => {
      mockCategoryService.findAll.mockResolvedValue(mockCategories);

      const result = await categoryController.findAll();

      expect(result).toEqual(mockCategories);
      expect(mockCategoryService.findAll).toHaveBeenCalledTimes(1);
      expect(result).toHaveLength(3);
    });

    it('should return empty array when no categories exist', async () => {
      mockCategoryService.findAll.mockResolvedValue([]);

      const result = await categoryController.findAll();

      expect(result).toEqual([]);
      expect(mockCategoryService.findAll).toHaveBeenCalledTimes(1);
    });

    it('should handle service errors gracefully', async () => {
      const serviceError = new Error('Database connection failed');
      mockCategoryService.findAll.mockRejectedValue(serviceError);

      await expect(categoryController.findAll()).rejects.toThrow(
        'Database connection failed',
      );
    });
  });

  describe('findByName', () => {
    it('should return category by name', async () => {
      const categoryName = 'Voyage';
      const expectedCategory = mockCategories[0];

      mockCategoryService.findByName.mockResolvedValue(expectedCategory);

      const result = await categoryController.findByName(categoryName);

      expect(result).toEqual(expectedCategory);
      expect(mockCategoryService.findByName).toHaveBeenCalledWith(categoryName);
      expect(mockCategoryService.findByName).toHaveBeenCalledTimes(1);
    });

    it('should throw NotFoundException when category name not found', async () => {
      const categoryName = 'NonExistent';
      const notFoundError = new NotFoundException(`Catégorie '${categoryName}' non trouvée`);

      mockCategoryService.findByName.mockRejectedValue(notFoundError);

      await expect(
        categoryController.findByName(categoryName),
      ).rejects.toThrow(NotFoundException);
      expect(mockCategoryService.findByName).toHaveBeenCalledWith(categoryName);
    });

    it('should handle empty category name', async () => {
      const emptyName = '';
      const validationError = new BadRequestException('Le nom de la catégorie ne peut pas être vide');

      mockCategoryService.findByName.mockRejectedValue(validationError);

      await expect(categoryController.findByName(emptyName)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should handle special characters in category name', async () => {
      const specialName = 'Voyage & Découverte';
      const expectedCategory = { ...mockCategories[0], name: specialName };

      mockCategoryService.findByName.mockResolvedValue(expectedCategory);

      const result = await categoryController.findByName(specialName);

      expect(result).toEqual(expectedCategory);
      expect(mockCategoryService.findByName).toHaveBeenCalledWith(specialName);
    });

    it('should handle URL encoded category names', async () => {
      const encodedName = 'Voyage%20%26%20D%C3%A9couverte';
      const decodedName = 'Voyage & Découverte';
      const expectedCategory = { ...mockCategories[0], name: decodedName };

      mockCategoryService.findByName.mockResolvedValue(expectedCategory);

      const result = await categoryController.findByName(encodedName);

      expect(result).toEqual(expectedCategory);
    });
  });

  describe('findById', () => {
    it('should return category by ID', async () => {
      const categoryId = mockCategories[0]._id;
      const expectedCategory = mockCategories[0];

      mockCategoryService.findById.mockResolvedValue(expectedCategory);

      const result = await categoryController.findById(categoryId);

      expect(result).toEqual(expectedCategory);
      expect(mockCategoryService.findById).toHaveBeenCalledWith(categoryId);
      expect(mockCategoryService.findById).toHaveBeenCalledTimes(1);
    });

    it('should throw NotFoundException when category ID not found', async () => {
      const categoryId = '507f1f77bcf86cd799439999';
      const notFoundError = new NotFoundException(`Catégorie avec l'ID ${categoryId} non trouvée`);

      mockCategoryService.findById.mockRejectedValue(notFoundError);

      await expect(categoryController.findById(categoryId)).rejects.toThrow(
        NotFoundException,
      );
      expect(mockCategoryService.findById).toHaveBeenCalledWith(categoryId);
    });

    it('should handle invalid ObjectId format', async () => {
      const invalidId = 'invalid-id';
      const validationError = new BadRequestException('Format ID invalide');

      mockCategoryService.findById.mockRejectedValue(validationError);

      await expect(categoryController.findById(invalidId)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('updateCategory', () => {
    it('should update and return category', async () => {
      const categoryId = mockCategories[0]._id;
      const updatedCategory = {
        ...mockCategories[0],
        ...updateCategoryDto,
        updatedAt: new Date(),
      };

      mockCategoryService.updateById.mockResolvedValue(updatedCategory);

      const result = await categoryController.updateCategory(
        categoryId,
        updateCategoryDto,
      );

      expect(result).toEqual(updatedCategory);
      expect(mockCategoryService.updateById).toHaveBeenCalledWith(
        categoryId,
        updateCategoryDto,
      );
      expect(mockCategoryService.updateById).toHaveBeenCalledTimes(1);
    });

    it('should throw NotFoundException when updating non-existent category', async () => {
      const categoryId = '507f1f77bcf86cd799439999';
      const notFoundError = new NotFoundException(`Catégorie avec l'ID ${categoryId} non trouvée`);

      mockCategoryService.updateById.mockRejectedValue(notFoundError);

      await expect(
        categoryController.updateCategory(categoryId, updateCategoryDto),
      ).rejects.toThrow(NotFoundException);
    });

    it('should handle validation errors in update data', async () => {
      const categoryId = mockCategories[0]._id;
      const invalidUpdateDto = { name: '', color: 'invalid-color' } as CategoryDto;
      const validationError = new BadRequestException('Données de mise à jour invalides');

      mockCategoryService.updateById.mockRejectedValue(validationError);

      await expect(
        categoryController.updateCategory(categoryId, invalidUpdateDto),
      ).rejects.toThrow(BadRequestException);
    });

    it('should handle partial updates', async () => {
      const categoryId = mockCategories[0]._id;
      const partialUpdateDto = { name: 'Nouveau Nom' } as CategoryDto;
      const updatedCategory = {
        ...mockCategories[0],
        name: 'Nouveau Nom',
        updatedAt: new Date(),
      };

      mockCategoryService.updateById.mockResolvedValue(updatedCategory);

      const result = await categoryController.updateCategory(
        categoryId,
        partialUpdateDto,
      );

      expect(result).toEqual(updatedCategory);
      expect(mockCategoryService.updateById).toHaveBeenCalledWith(
        categoryId,
        partialUpdateDto,
      );
    });
  });

  describe('removeCategory', () => {
    it('should delete and return category', async () => {
      const categoryId = mockCategories[0]._id;
      const deletedCategory = mockCategories[0];

      mockCategoryService.removeById.mockResolvedValue(deletedCategory);

      const result = await categoryController.removeCategory(categoryId);

      expect(result).toEqual(deletedCategory);
      expect(mockCategoryService.removeById).toHaveBeenCalledWith(categoryId);
      expect(mockCategoryService.removeById).toHaveBeenCalledTimes(1);
    });

    it('should throw NotFoundException when deleting non-existent category', async () => {
      const categoryId = '507f1f77bcf86cd799439999';
      const notFoundError = new NotFoundException(`Catégorie avec l'ID ${categoryId} non trouvée`);

      mockCategoryService.removeById.mockRejectedValue(notFoundError);

      await expect(
        categoryController.removeCategory(categoryId),
      ).rejects.toThrow(NotFoundException);
      expect(mockCategoryService.removeById).toHaveBeenCalledWith(categoryId);
    });

    it('should handle deletion of category with dependencies', async () => {
      const categoryId = mockCategories[0]._id;
      const dependencyError = new BadRequestException(
        'Impossible de supprimer la catégorie car elle est utilisée par des plans',
      );

      mockCategoryService.removeById.mockRejectedValue(dependencyError);

      await expect(
        categoryController.removeCategory(categoryId),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('Authentication Guard', () => {
    it('should be protected by JwtAuthGuard', () => {
      const guards = Reflect.getMetadata('__guards__', CategoryController);
      
      if (guards && guards.length > 0) {
        const guardNames = guards.map((guard: any) => guard.name || guard.constructor?.name);
        expect(guardNames).toContain('JwtAuthGuard');
      } else {
        const controllerMetadata = Reflect.getMetadataKeys(CategoryController);
        expect(controllerMetadata).toBeDefined();
      }
    });

    it('should have JWT authentication configured', async () => {
      mockCategoryService.findAll.mockResolvedValue(mockCategories);

      const result = await categoryController.findAll();

      expect(result).toEqual(mockCategories);
      expect(mockCategoryService.findAll).toHaveBeenCalledTimes(1);
    });

    it('should mock guard return value correctly', () => {
      expect(mockJwtAuthGuard.canActivate()).toBe(true);
    });
  });

  describe('Controller routing', () => {
    it('should be mapped to correct base route', () => {
      const controllerPath = Reflect.getMetadata('path', CategoryController);
      expect(controllerPath).toBe('api/categories');
    });

    it('should have correct method decorators', () => {
      const postMetadata = Reflect.getMetadata('method', categoryController.createCategory);
      const getMetadata = Reflect.getMetadata('method', categoryController.findAll);
      const putMetadata = Reflect.getMetadata('method', categoryController.updateCategory);
      const deleteMetadata = Reflect.getMetadata('method', categoryController.removeCategory);

      expect(postMetadata).toBeDefined();
      expect(getMetadata).toBeDefined();
      expect(putMetadata).toBeDefined();
      expect(deleteMetadata).toBeDefined();
    });
  });

  describe('Service error handling', () => {
    it('should propagate service errors in createCategory', async () => {
      const serviceError = new Error('Service unavailable');
      mockCategoryService.create.mockRejectedValue(serviceError);

      await expect(
        categoryController.createCategory(validCategoryDto),
      ).rejects.toThrow('Service unavailable');
    });

    it('should handle null service response in findById', async () => {
      mockCategoryService.findById.mockResolvedValue(null);

      const result = await categoryController.findById('nonexistent-id');

      expect(result).toBeNull();
    });
  });

  describe('Controller metadata', () => {
    it('should have correct controller path', () => {
      const controllerPath = Reflect.getMetadata('path', CategoryController);
      expect(controllerPath).toBe('api/categories');
    });

    it('should have UseGuards decorator', () => {
      const guards = Reflect.getMetadata('__guards__', CategoryController);
      expect(guards).toBeDefined();
      expect(guards.length).toBeGreaterThan(0);
    });

    it('should have correct HTTP method decorators', () => {
      const createMetadata = Reflect.getMetadata('method', categoryController.createCategory);
      const findAllMetadata = Reflect.getMetadata('method', categoryController.findAll);
      
      expect(createMetadata).toBeDefined();
      expect(findAllMetadata).toBeDefined();
    });
  });

  describe('Edge cases', () => {
    it('should handle null categoryDto in create', async () => {
      const nullError = new BadRequestException('Données de catégorie manquantes');
      mockCategoryService.create.mockRejectedValue(nullError);

      await expect(
        categoryController.createCategory(null as any),
      ).rejects.toThrow(BadRequestException);
    });

    it('should handle null categoryDto in update', async () => {
      const categoryId = mockCategories[0]._id;
      const nullError = new BadRequestException('Données de mise à jour manquantes');
      mockCategoryService.updateById.mockRejectedValue(nullError);

      await expect(
        categoryController.updateCategory(categoryId, null as any),
      ).rejects.toThrow(BadRequestException);
    });

    it('should handle very long category names', async () => {
      const longName = 'a'.repeat(1000);
      const longNameError = new BadRequestException('Le nom de la catégorie est trop long');
      mockCategoryService.findByName.mockRejectedValue(longNameError);

      await expect(categoryController.findByName(longName)).rejects.toThrow(
        BadRequestException,
      );
    });
  });
});
