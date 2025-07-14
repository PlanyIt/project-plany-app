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
    const stepIds = createPlanDto.steps.map((stepId) => stepId.toString());

    const totalCost = await this.stepService.calculateTotalCost(stepIds);
    const totalDuration =
      await this.stepService.calculateTotalDuration(stepIds);

    const createdPlan = new this.planModel({
      ...createPlanDto,
      totalCost,
      totalDuration,
    });

    const savedPlan = await createdPlan.save();

    return this.planModel
      .findById(savedPlan._id)
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();
  }

  async findAll(): Promise<PlanDocument[]> {
    return this.planModel
      .find({ isPublic: true })
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ favorites: -1 })
      .exec();
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
    if (updatePlanDto.steps) {
      const stepIds = updatePlanDto.steps.map((stepId) => stepId.toString());
      updatePlanDto.totalCost =
        await this.stepService.calculateTotalCost(stepIds);
      updatePlanDto.totalDuration =
        await this.stepService.calculateTotalDuration(stepIds);
    }

    return this.planModel
      .findOneAndUpdate({ _id: planId, user: userId }, updatePlanDto, {
        new: true,
      })
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();
  }

  async findById(planId: string): Promise<PlanDocument | undefined> {
    if (!isValidObjectId(planId)) {
      throw new NotFoundException(
        `Plan with ID ${planId} is not a valid ObjectId`,
      );
    }
    return this.planModel
      .findById(planId)
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();
  }

  async addStepToPlan(
    planId: string,
    stepId: string,
  ): Promise<PlanDocument | undefined> {
    const updatedPlan = await this.planModel
      .findOneAndUpdate(
        { _id: planId },
        { $push: { steps: stepId } },
        { new: true },
      )
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .exec();

    if (updatedPlan) {
      const stepIds = updatedPlan.steps.map((s) => s._id.toString());
      updatedPlan.totalCost =
        await this.stepService.calculateTotalCost(stepIds);
      updatedPlan.totalDuration =
        await this.stepService.calculateTotalDuration(stepIds);
      await updatedPlan.save();
    }

    return updatedPlan;
  }

  async addToFavorites(planId: string, userId: string): Promise<PlanDocument> {
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
  }

  async removeFromFavorites(
    planId: string,
    userId: string,
  ): Promise<PlanDocument> {
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
  }

  async findAllByUserId(
    userId: string,
    viewerId?: string,
  ): Promise<PlanDocument[]> {
    const userObjectId = new Types.ObjectId(userId);
    const query: any = { user: userObjectId };

    const isOwner = viewerId?.toString() === userId.toString();
    if (!isOwner) {
      query.isPublic = true;
    }

    return this.planModel
      .find(query)
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ createdAt: -1 })
      .exec();
  }

  async findFavoritesByUserId(userId: string): Promise<PlanDocument[]> {
    return this.planModel
      .find({ favorites: userId })
      .populate('user', 'username email photoUrl followers')
      .populate('category', 'name icon color')
      .populate({
        path: 'steps',
        model: 'Step',
        select:
          'title description image order duration cost longitude latitude',
      })
      .sort({ createdAt: -1 })
      .exec();
  }

  async countUserPlans(userId: string): Promise<number> {
    const userObjectId = new Types.ObjectId(userId);
    return this.planModel.countDocuments({ user: userObjectId }).exec();
  }

  async countUserFavorites(userId: string): Promise<number> {
    return this.planModel.countDocuments({ favorites: userId }).exec();
  }

  async fixNullFavorites() {
    return this.planModel.updateMany(
      { favorites: null },
      { $set: { favorites: [] } },
    );
  }
}
