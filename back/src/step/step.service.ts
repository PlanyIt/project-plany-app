import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Step, StepDocument } from './schemas/step.schema';
import { StepDto } from './dto/step.dto';
@Injectable()
export class StepService {
  constructor(
    @InjectModel(Step.name) private stepModel: Model<StepDocument>,
    @InjectModel('Plan') private planModel: Model<any>,
  ) {}

  async findAll(): Promise<StepDocument[]> {
    return this.stepModel.find().exec();
  }

  async create(createStepDto: StepDto): Promise<StepDocument> {
    const newStep = new this.stepModel(createStepDto);
    return newStep.save();
  }

  async findByIds(stepIds: string[]): Promise<StepDocument[]> {
    return this.stepModel
      .find({ _id: { $in: stepIds } })
      .sort({ order: 1 })
      .exec();
  }

  async removeById(stepId: string): Promise<StepDocument | null> {
    const step = await this.stepModel.findOneAndDelete({ _id: stepId }).exec();

    if (step) {
      await this.planModel.updateMany(
        { steps: stepId },
        { $pull: { steps: stepId } },
      );
    }

    return step;
  }

  async updateById(
    stepId: string,
    updateStepDto: StepDto,
    userId: string,
  ): Promise<StepDocument | null> {
    return this.stepModel
      .findOneAndUpdate({ _id: stepId, userId }, updateStepDto, {
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

  /**
   * Calculate total cost for a list of steps
   */
  async calculateTotalCost(stepIds: string[]): Promise<number> {
    const steps = await this.findByIds(stepIds);
    return steps.reduce((total, step) => total + (step.cost || 0), 0);
  }

  /**
   * Calculate total duration for a list of steps in minutes
   */
  async calculateTotalDuration(stepIds: string[]): Promise<number> {
    const steps = await this.findByIds(stepIds);
    return steps.reduce((total, step) => {
      if (!step.duration) return total;
      return total + step.duration;
    }, 0);
  }
}
