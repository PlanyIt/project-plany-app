/* eslint-disable prettier/prettier */
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Category, CategoryDocument } from './schemas/category.schema';
import { CreateCategoryDto } from './dto/create-category.dto';
@Injectable()
export class CategoryService {
    constructor(
        @InjectModel(Category.name) private categoryModel: Model<CategoryDocument>,
    ) {}

    async create(createCategoryDto: CreateCategoryDto): Promise<CategoryDocument> {
        const newCategory = new this.categoryModel(createCategoryDto);
        return newCategory.save();
    }

    async findAll(): Promise<CategoryDocument[]> {
        return this.categoryModel.find().exec();
    }

    async removeById(categoryId: string): Promise<CategoryDocument | null> {
        return this.categoryModel.findOneAndDelete({ _id: categoryId }).exec();
    }

    async updateById(
        categoryId: string,
        updateCategoryDto: CreateCategoryDto,
    ): Promise<CategoryDocument | null> {
        return this.categoryModel
            .findOneAndUpdate({ _id: categoryId }, updateCategoryDto, {
                new: true,
            })
            .exec();
    }

    async findById(
        categoryId: string,
    ): Promise<CategoryDocument | undefined> {
        return this.categoryModel.findOne({ _id: categoryId }).exec();
    }

    async findByName(
        name: string,
    ): Promise<CategoryDocument | undefined> {
        return this.categoryModel.findOne({ name }).exec();
    }
}
