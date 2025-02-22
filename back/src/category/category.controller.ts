/* eslint-disable prettier/prettier */
import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { CategoryService } from './category.service';
import { FirebaseAuthGuard } from 'src/auth/guards/firebase-auth.guard';
import { CreateCategoryDto } from './dto/create-category.dto';

@Controller('api/categories')
export class CategoryController {
    constructor(private readonly categoryService: CategoryService) {}

    @UseGuards(FirebaseAuthGuard)
    @Post()
    async createCategory(@Body() createCategoryDto: CreateCategoryDto) {
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

    @UseGuards(FirebaseAuthGuard)
    @Put(':categoryId')
    async updateCategory(
        @Param('categoryId') categoryId: string,
        @Body() updateCategoryDto: CreateCategoryDto,
    ) {
        return this.categoryService.updateById(categoryId, updateCategoryDto);
    }

    @UseGuards(FirebaseAuthGuard)
    @Delete(':categoryId')
    async removeCategory(@Param('categoryId') categoryId: string) {
        return this.categoryService.removeById(categoryId);
    }
    
}
