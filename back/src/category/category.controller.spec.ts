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
  let controller: CategoryController;
 
  beforeEach(async () => {
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