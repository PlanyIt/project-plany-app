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

    // Retirer de tous les plans qui le référencent
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
      return total + this.parseDurationToMinutes(step.duration);
    }, 0);
  }

  /**
   * Parse duration string to minutes
   */
  private parseDurationToMinutes(durationStr: string): number {
    if (!durationStr) return 0;

    const parts = durationStr.toLowerCase().split(' ');
    if (parts.length < 2) return 0;

    try {
      const value = parseInt(parts[0]);
      const unit = parts[1];

      if (unit.includes('seconde')) {
        return Math.ceil(value / 60); // Convert seconds to minutes, rounding up
      } else if (unit.includes('minute')) {
        return value;
      } else if (unit.includes('heure')) {
        return value * 60; // Convert hours to minutes
      } else if (unit.includes('jour')) {
        return value * 8 * 60; // Convert days to minutes (8 hour workday)
      } else if (unit.includes('semaine')) {
        return value * 5 * 8 * 60; // Convert weeks to minutes (5 day work week)
      }
    } catch (e) {
      console.error(`Error parsing duration: ${durationStr}`, e);
      return 0;
    }

    return 0;
  }

  /**
   * Format minutes to human readable duration
   */
  formatDuration(totalMinutes: number): string {
    if (totalMinutes === 0) return '0 minute';

    const weeks = Math.floor(totalMinutes / (5 * 8 * 60));
    const days = Math.floor((totalMinutes % (5 * 8 * 60)) / (8 * 60));
    const hours = Math.floor((totalMinutes % (8 * 60)) / 60);
    const minutes = totalMinutes % 60;

    const parts: string[] = [];

    if (weeks > 0) parts.push(`${weeks} semaine${weeks > 1 ? 's' : ''}`);
    if (days > 0) parts.push(`${days} jour${days > 1 ? 's' : ''}`);
    if (hours > 0) parts.push(`${hours} heure${hours > 1 ? 's' : ''}`);
    if (minutes > 0) parts.push(`${minutes} minute${minutes > 1 ? 's' : ''}`);

    if (parts.length > 1) {
      return `${parts.slice(0, -1).join(', ')} et ${parts[parts.length - 1]}`;
    }
    return parts[0];
  }
}
