import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Category, CategoryDocument } from './schemas/category.schema';
import { CategoryDto } from './dto/category.dto';
@Injectable()
export class CategoryService {
  constructor(
    @InjectModel(Category.name) private categoryModel: Model<CategoryDocument>,
  ) {}

  async create(createCategoryDto: CategoryDto): Promise<CategoryDocument> {
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
    updateCategoryDto: CategoryDto,
  ): Promise<CategoryDocument | null> {
    return this.categoryModel
      .findOneAndUpdate({ _id: categoryId }, updateCategoryDto, {
        new: true,
      })
      .exec();
  }

  async findById(categoryId: string): Promise<CategoryDocument | null> {
    return this.categoryModel.findOne({ _id: categoryId }).exec();
  }

  async findByName(name: string): Promise<CategoryDocument | null> {
    return this.categoryModel.findOne({ name }).exec();
  }

  async count(): Promise<number> {
    return this.categoryModel.countDocuments().exec();
  }
}
