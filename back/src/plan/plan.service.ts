import {
  Injectable,
  NotFoundException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { PlanDto } from './dto/plan.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Plan, PlanDocument } from './schemas/plan.schema';
import { Types, isValidObjectId } from 'mongoose';
import { Model } from 'mongoose';
import { StepService } from '../step/step.service';

@Injectable()
export class PlanService {
  constructor(
    @InjectModel(Plan.name) private planModel: Model<PlanDocument>,
    @Inject(forwardRef(() => StepService))
    private stepService: StepService,
  ) {}

  async createPlan(createPlanDto: PlanDto): Promise<PlanDocument> {
    console.log('📝 Service creating plan with:', createPlanDto);

    const createdPlan = new this.planModel(createPlanDto);
    const savedPlan = await createdPlan.save();

    // Populate the plan with related data before returning
    const populatedPlan = await this.planModel
      .findById(savedPlan._id)
      .populate({
        path: 'user',
        select: 'username email photoUrl followers',
      })
      .populate({
        path: 'category',
        select: 'name icon color',
      })
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();

    console.log('✅ Plan created and populated:', populatedPlan?._id);

    return populatedPlan || savedPlan;
  }

  async findAll(): Promise<PlanDocument[]> {
    const plans = await this.planModel
      .find()
      .populate({
        path: 'user',
        select: 'username email photoUrl followers',
      })
      .populate({
        path: 'category',
        select: 'name icon color',
      })
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();

    // Calculate totals for each plan
    for (const plan of plans) {
      const stepIds = plan.steps
        .filter((step) => step && step._id)
        .map((step) => step._id.toString());
      plan.totalCost = await this.stepService.calculateTotalCost(stepIds);
      plan.totalDuration =
        await this.stepService.calculateTotalDuration(stepIds);
    }

    return plans;
  }

  async removeById(planId: string, userId: string): Promise<PlanDocument> {
    const deletedPlan = await this.planModel
      .findOneAndDelete({ _id: planId, user: userId })
      .exec();
    if (!deletedPlan) {
      throw new NotFoundException(`Plan not found or not owned by user`);
    }
    return deletedPlan;
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
    if (!isValidObjectId(planId)) {
      // Ajout d'une vérification pour éviter l'erreur CastError
      throw new NotFoundException(
        `Plan with ID ${planId} is not a valid ObjectId`,
      );
    }
    const plan = await this.planModel
      .findOne({ _id: planId })
      .populate({
        path: 'user',
        select: 'username email photoUrl followers',
      })
      .populate({
        path: 'category',
        select: 'name icon color',
      })
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();

    if (plan) {
      const stepIds = plan.steps.map((step) => step._id.toString());
      plan.totalCost = await this.stepService.calculateTotalCost(stepIds);
      plan.totalDuration =
        await this.stepService.calculateTotalDuration(stepIds);
    }

    return plan;
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
        select: 'username email photoUrl followers',
      })
      .populate({
        path: 'category',
        select: 'name icon color',
      })
      .populate({
        path: 'steps',
        model: 'Step',
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
    const userObjectId = new Types.ObjectId(userId);
    const plans = await this.planModel
      .find({ user: userObjectId })
      .find()
      .populate({
        path: 'user',
        select: 'username email photoUrl followers',
      })
      .populate({
        path: 'category',
        select: 'name icon color',
      })
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ createdAt: -1 })
      .exec();

    // Calculate totals for each plan
    for (const plan of plans) {
      const stepIds = plan.steps
        .filter((step) => step && step._id)
        .map((step) => step._id.toString());
      plan.totalCost = await this.stepService.calculateTotalCost(stepIds);
      plan.totalDuration =
        await this.stepService.calculateTotalDuration(stepIds);
    }

    return plans;
  }

  async findFavoritesByUserId(userId: string): Promise<PlanDocument[]> {
    const plans = await this.planModel
      .find({ favorites: userId })
      .populate({
        path: 'user',
        select: 'username email photoUrl followers',
      })
      .populate({
        path: 'category',
        select: 'name icon color',
      })
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ createdAt: -1 })
      .exec();

    // Calculate totals for each plan
    for (const plan of plans) {
      const stepIds = plan.steps
        .filter((step) => step && step._id)
        .map((step) => (step._id ? step._id.toString() : null))
        .filter((id) => id !== null);
      plan.totalCost = await this.stepService.calculateTotalCost(stepIds);
      plan.totalDuration =
        await this.stepService.calculateTotalDuration(stepIds);
    }

    return plans;
  }

  async countUserPlans(userId: string): Promise<number> {
    const userObjectId = new Types.ObjectId(userId);
    return this.planModel.countDocuments({ user: userObjectId }).exec();
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
