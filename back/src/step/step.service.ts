import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Step, StepDocument } from './schemas/step.schema';
import { StepDto } from './dto/step.dto';
@Injectable()
export class StepService {
  constructor(@InjectModel(Step.name) private stepModel: Model<StepDocument>) {}

  async findAll(): Promise<StepDocument[]> {
    return this.stepModel.find().exec();
  }

  async create(createStepDto: StepDto): Promise<StepDocument> {
    const newStep = new this.stepModel(createStepDto);
    return newStep.save();
  }

  async removeById(stepId: string): Promise<StepDocument | null> {
    return this.stepModel.findOneAndDelete({ _id: stepId }).exec();
  }

  async updateById(
    stepId: string,
    updateStepDto: StepDto,
    userId: string,
    planId: string,
  ): Promise<StepDocument | null> {
    return this.stepModel
      .findOneAndUpdate({ _id: stepId, userId, planId }, updateStepDto, {
        new: true,
      })
      .exec();
  }

  async findById(stepId: string): Promise<StepDocument | undefined> {
    const step = await this.stepModel.findOne({ _id: stepId }).exec();
    if (!step) {
      return undefined;
    }
    return step;
  }
}
