import { Injectable } from '@nestjs/common';
import { PlanDto } from './dto/plan.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Plan, PlanDocument } from './schemas/plan.schema';
import { Model } from 'mongoose';
import { StepDto } from 'src/step/dto/step.dto';

@Injectable()
export class PlanService {
  constructor(@InjectModel(Plan.name) private planModel: Model<PlanDocument>) {}

  // Création de plan avec userId
  async createPlan(createPlanDto: PlanDto): Promise<PlanDocument> {
    const createdPlan = new this.planModel(createPlanDto);
    return createdPlan.save();
  }

  // Récupérer tous les plans
  async findAll(): Promise<PlanDocument[]> {
    return this.planModel.find().exec();
  }

  // Supprimer un plan par son ID et userId
  async removeById(planId: string, userId: string): Promise<PlanDocument> {
    return this.planModel.findOneAndDelete({ _id: planId, userId }).exec();
  }

  // Mettre à jour un plan par son ID et userId
  async updateById(
    planId: string,
    updatePlanDto: PlanDto,
    userId: string,
  ): Promise<PlanDocument> {
    return this.planModel
      .findOneAndUpdate({ _id: planId, userId }, updatePlanDto, { new: true })
      .exec();
  }

  // Récupérer un plan par son ID
  async findById(planId: string): Promise<PlanDocument | undefined> {
    return this.planModel.findOne({ _id: planId }).exec();
  }

  /// ajouter les steps dans le plan
  async addStepToPlan(
    planId: string,
    stepDto: StepDto,
  ): Promise<PlanDocument | undefined> {
    return this.planModel
      .findOneAndUpdate(
        { _id: planId },
        { $push: { steps: stepDto } },
        { new: true },
      )
      .exec();
  }
}
