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
import { CategoryService } from './category.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CategoryDto } from './dto/category.dto';
@UseGuards(JwtAuthGuard)
@Controller('api/categories')
export class CategoryController {
  constructor(private readonly categoryService: CategoryService) {}

  @Post()
  async createCategory(@Body() createCategoryDto: CategoryDto) {
    return this.categoryService.create(createCategoryDto);
  }

  @Get()
  async findAll() {
    return this.categoryService.findAll();
  }

  @Get('name/:categoryName')
  async findByName(@Param('categoryName') categoryName: string) {
    return this.categoryService.findByName(categoryName);
  }

  @Get(':categoryId')
  async findById(@Param('categoryId') categoryId: string) {
    return this.categoryService.findById(categoryId);
  }

  @Put(':categoryId')
  async updateCategory(
    @Param('categoryId') categoryId: string,
    @Body() updateCategoryDto: CategoryDto,
  ) {
    return this.categoryService.updateById(categoryId, updateCategoryDto);
  }

  @Delete(':categoryId')
  async removeCategory(@Param('categoryId') categoryId: string) {
    return this.categoryService.removeById(categoryId);
  }
}
