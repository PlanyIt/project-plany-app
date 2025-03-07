import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Tag, TagDocument } from './schemas/tag-schema';
import { TagDto } from './dto/tag.dto';

@Injectable()
export class TagService {
  constructor(@InjectModel(Tag.name) private tagModel: Model<TagDocument>) {}

  async create(tag: Tag): Promise<TagDocument> {
    const newTag = new this.tagModel(tag);
    return newTag.save();
  }

  async findAll(): Promise<TagDocument[]> {
    return this.tagModel.find().exec();
  }

  async removeById(tagId: string): Promise<TagDocument | null> {
    return this.tagModel.findOneAndDelete({ _id: tagId }).exec();
  }

  async updateById(
    tagId: string,
    updateTagDto: TagDto,
  ): Promise<TagDocument | null> {
    return this.tagModel
      .findOneAndUpdate({ _id: tagId }, updateTagDto, {
        new: true,
      })
      .exec();
  }

  async findById(tagId: string): Promise<TagDocument | undefined> {
    return this.tagModel.findOne({ _id: tagId }).exec();
  }

  async findByName(name: string): Promise<TagDocument | undefined> {
    return this.tagModel.findOne({ name }).exec();
  }
}
