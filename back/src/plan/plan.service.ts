import { Injectable, NotFoundException } from '@nestjs/common';
import { PlanDto } from './dto/plan.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Plan, PlanDocument } from './schemas/plan.schema';
import { Model } from 'mongoose';
import { StepDto } from 'src/step/dto/step.dto';
import { User } from 'src/user/schemas/user.schema';

@Injectable()
export class PlanService {
  constructor(
    @InjectModel(Plan.name) private planModel: Model<Plan>,
    @InjectModel(User.name) private userModel: Model<User>,
  ) {}

  async createPlan(createPlanDto: PlanDto): Promise<PlanDocument> {
    const createdPlan = new this.planModel(createPlanDto);
    return createdPlan.save();
  }

  async findAll(): Promise<PlanDocument[]> {
    return this.planModel.find().exec();
  }

  async removeById(
    planId: string,
    userId: string,
  ): Promise<PlanDocument | null> {
    return this.planModel.findOneAndDelete({ _id: planId, userId }).exec();
  }

  async updateById(
    planId: string,
    updatePlanDto: PlanDto,
    userId: string,
  ): Promise<PlanDocument | null> {
    return this.planModel
      .findOneAndUpdate({ _id: planId, userId }, updatePlanDto, { new: true })
      .exec();
  }

  async findById(planId: string): Promise<PlanDocument | null> {
    return this.planModel.findOne({ _id: planId }).exec();
  }

  async addStepToPlan(
    planId: string,
    stepDto: StepDto,
  ): Promise<PlanDocument | null> {
    return this.planModel
      .findOneAndUpdate(
        { _id: planId },
        { $push: { steps: stepDto } },
        { new: true },
      )
      .exec();
  }

  async addToFavorites(
    planId: string,
    userId: string,
  ): Promise<PlanDocument | null> {
    try {
      const plan = await this.planModel.findById(planId);
      if (!plan) {
        throw new NotFoundException(`Plan with ID ${planId} not found`);
      }

      if (plan.favorites === null) {
        await this.planModel.updateOne(
          { _id: planId },
          { $set: { favorites: [] } },
        );
      }

      return this.planModel.findByIdAndUpdate(
        planId,
        { $addToSet: { favorites: userId } },
        { new: true },
      );
    } catch (error) {
      console.error(`Error adding favorite: ${error.message}`);
      throw error;
    }
  }

  async removeFromFavorites(
    planId: string,
    userId: string,
  ): Promise<PlanDocument | null> {
    try {
      const plan = await this.planModel.findById(planId);
      if (!plan) {
        throw new NotFoundException(`Plan with ID ${planId} not found`);
      }
      if (plan.favorites === null) {
        return plan;
      }

      return this.planModel.findByIdAndUpdate(
        planId,
        { $pull: { favorites: userId } },
        { new: true },
      );
    } catch (error) {
      console.error(`Error removing favorite: ${error.message}`);
      throw error;
    }
  }

  async findAllByUserId(userId: string): Promise<PlanDocument[]> {
    return this.planModel.find({ userId }).sort({ createdAt: -1 }).exec();
  }

  async findFavoritesByUserId(userId: string): Promise<PlanDocument[]> {
    return this.planModel
      .find({ favorites: userId })
      .sort({ createdAt: -1 })
      .exec();
  }

  async countUserPlans(userId: string): Promise<number> {
    return this.planModel.countDocuments({ userId }).exec();
  }

  async countUserFavorites(userId: string): Promise<number> {
    return this.planModel.countDocuments({ favorites: userId }).exec();
  }

  async fixNullFavorites() {
    const result = await this.planModel.updateMany(
      { favorites: null },
      { $set: { favorites: [] } },
    );

    return result;
  }
}
