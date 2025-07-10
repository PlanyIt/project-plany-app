import { Injectable, NotFoundException } from '@nestjs/common';
import { PlanDto } from './dto/plan.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Plan, PlanDocument } from './schemas/plan.schema';
import { Model } from 'mongoose';
import { User, UserDocument } from 'src/user/schemas/user.schema';

@Injectable()
export class PlanService {
  constructor(
    @InjectModel(Plan.name) private planModel: Model<PlanDocument>,
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  async createPlan(createPlanDto: PlanDto): Promise<PlanDocument> {
    const createdPlan = new this.planModel(createPlanDto);
    return createdPlan.save();
  }

  async findAll(): Promise<PlanDocument[]> {
    return this.planModel
      .find()
      .populate({
        path: 'user',
        select: 'username email photoUrl',
      })
      .populate({
        path: 'steps',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ createdAt: -1 })
      .exec();
  }

  async removeById(planId: string, userId: string): Promise<PlanDocument> {
    return this.planModel
      .findOneAndDelete({ _id: planId, user: userId })
      .exec();
  }

  async updateById(
    planId: string,
    updatePlanDto: PlanDto,
    userId: string,
  ): Promise<PlanDocument> {
    return this.planModel
      .findOneAndUpdate({ _id: planId, user: userId }, updatePlanDto, {
        new: true,
      })
      .exec();
  }

  async findById(planId: string): Promise<PlanDocument | undefined> {
    return this.planModel
      .findOne({ _id: planId })
      .populate({
        path: 'user',
        select: 'username email photoUrl',
      })
      .populate({
        path: 'steps',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();
  }

  async addStepToPlan(
    planId: string,
    stepId: string,
  ): Promise<PlanDocument | undefined> {
    return this.planModel
      .findOneAndUpdate(
        { _id: planId },
        { $push: { steps: stepId } },
        { new: true },
      )
      .populate({
        path: 'user',
        select: 'username email photoUrl',
      })
      .populate({
        path: 'steps',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();
  }

  async addToFavorites(planId: string, userId: string): Promise<PlanDocument> {
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
  ): Promise<PlanDocument> {
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
    return this.planModel
      .find({ user: userId })
      .populate({
        path: 'steps',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ createdAt: -1 })
      .exec();
  }

  async findFavoritesByUserId(userId: string): Promise<PlanDocument[]> {
    return this.planModel
      .find({ favorites: userId })
      .populate({
        path: 'user',
        select: 'username email photoUrl',
      })
      .populate({
        path: 'steps',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ createdAt: -1 })
      .exec();
  }

  async countUserPlans(userId: string): Promise<number> {
    return this.planModel.countDocuments({ user: userId }).exec();
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
