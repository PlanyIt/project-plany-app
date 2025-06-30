import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { CategoryService } from './category.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CategoryDto } from './dto/category.dto';

@ApiTags('Categories')
@Controller('api/categories')
export class CategoryController {
  constructor(private readonly categoryService: CategoryService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Create a new category',
    description: 'Create a new category with name, icon and color',
  })
  @ApiBody({
    type: CategoryDto,
    description: 'Category data',
    examples: {
      'Travel Category': {
        value: {
          name: 'Travel',
          icon: '✈️',
          color: '#4CAF50',
        },
      },
      'Fitness Category': {
        value: {
          name: 'Fitness',
          icon: '💪',
          color: '#FF5722',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Category created successfully',
    schema: {
      type: 'object',
      properties: {
        _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
        name: { type: 'string', example: 'Travel' },
        icon: { type: 'string', example: '✈️' },
        color: { type: 'string', example: '#4CAF50' },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid category data',
    schema: {
      example: {
        statusCode: 400,
        message: ['name should not be empty', 'icon should not be empty'],
        error: 'Bad Request',
      },
    },
  })
  async createCategory(@Body() createCategoryDto: CategoryDto) {
    return this.categoryService.create(createCategoryDto);
  }

  @Get()
  @ApiOperation({
    summary: 'Get all categories',
    description: 'Retrieve all categories available in the system',
  })
  @ApiResponse({
    status: 200,
    description: 'Categories retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
          name: { type: 'string', example: 'Travel' },
          icon: { type: 'string', example: '✈️' },
          color: { type: 'string', example: '#4CAF50' },
        },
      },
    },
  })
  async findAll() {
    return this.categoryService.findAll();
  }

  @Get('name/:categoryName')
  @ApiOperation({
    summary: 'Get category by name',
    description: 'Retrieve a specific category by its name',
  })
  @ApiParam({
    name: 'categoryName',
    description: 'The name of the category',
    example: 'Travel',
  })
  @ApiResponse({
    status: 200,
    description: 'Category retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
        name: { type: 'string', example: 'Travel' },
        icon: { type: 'string', example: '✈️' },
        color: { type: 'string', example: '#4CAF50' },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Category not found',
  })
  async findByName(@Param('categoryName') categoryName: string) {
    return this.categoryService.findByName(categoryName);
  }

  @Get(':categoryId')
  @ApiOperation({
    summary: 'Get category by ID',
    description: 'Retrieve a specific category by its unique identifier',
  })
  @ApiParam({
    name: 'categoryId',
    description: 'The unique identifier of the category',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Category retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
        name: { type: 'string', example: 'Travel' },
        icon: { type: 'string', example: '✈️' },
        color: { type: 'string', example: '#4CAF50' },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Category not found',
  })
  async findById(@Param('categoryId') categoryId: string) {
    return this.categoryService.findById(categoryId);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':categoryId')
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Update a category',
    description:
      'Update an existing category by its ID (requires authentication)',
  })
  @ApiParam({
    name: 'categoryId',
    description: 'The unique identifier of the category to update',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiBody({
    type: CategoryDto,
    description: 'Updated category data',
    examples: {
      'Update Category': {
        value: {
          name: 'Adventure Travel',
          icon: '🏔️',
          color: '#2196F3',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Category updated successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'Category not found',
  })
  async updateCategory(
    @Param('categoryId') categoryId: string,
    @Body() updateCategoryDto: CategoryDto,
  ) {
    return this.categoryService.updateById(categoryId, updateCategoryDto);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':categoryId')
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Delete a category',
    description: 'Delete a category by its ID (requires authentication)',
  })
  @ApiParam({
    name: 'categoryId',
    description: 'The unique identifier of the category to delete',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Category deleted successfully',
    schema: {
      example: {
        message: 'Category deleted successfully',
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Category not found',
  })
  async removeCategory(@Param('categoryId') categoryId: string) {
    return this.categoryService.removeById(categoryId);
  }
}
