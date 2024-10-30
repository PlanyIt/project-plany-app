import { Injectable } from '@nestjs/common';
import { CreatePlanDto } from './dto/create-plan.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Plan, PlanDocument } from './schemas/plan.schema';
import { Model } from 'mongoose';

@Injectable()
export class PlanService {
  constructor(@InjectModel(Plan.name) private planModel: Model<PlanDocument>) {}

  // Création de plan avec userId
  async createPlan(createPlanDto: CreatePlanDto): Promise<PlanDocument> {
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
    updatePlanDto: CreatePlanDto,
    userId: string,
  ): Promise<PlanDocument> {
    return this.planModel
      .findOneAndUpdate({ _id: planId, userId }, updatePlanDto, { new: true })
      .exec();
  }
}
