import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Plan } from './plan.schema';
import { CreatePlanDto } from './dto/create-plan.dto';
import { UpdatePlanDto } from './dto/update-plan.dto';

@Injectable()
export class PlanService {
  constructor(
    @InjectModel(Plan.name) private planModel: Model<Plan>, // Injecte le modèle de Plan
  ) {}

  // Créer un nouveau plan
  async createPlan(createPlanDto: CreatePlanDto): Promise<Plan> {
    const createdPlan = new this.planModel(createPlanDto);
    return createdPlan.save();
  }

  // Obtenir tous les plans
  async findAll(): Promise<Plan[]> {
    return this.planModel.find().exec();
  }

  // Obtenir un plan par son ID
  async findOne(planId: string): Promise<Plan> {
    const plan = await this.planModel.findById(planId).exec();
    if (!plan) {
      throw new NotFoundException(`Plan with ID ${planId} not found`);
    }
    return plan;
  }

  // Mettre à jour un plan
  async updatePlan(
    planId: string,
    updatePlanDto: UpdatePlanDto,
  ): Promise<Plan> {
    const updatedPlan = await this.planModel
      .findByIdAndUpdate(planId, updatePlanDto, { new: true })
      .exec();
    if (!updatedPlan) {
      throw new NotFoundException(`Plan with ID ${planId} not found`);
    }
    return updatedPlan;
  }

  // Supprimer un plan
  async deletePlan(planId: string): Promise<void> {
    const result = await this.planModel.findByIdAndDelete(planId).exec();
    if (!result) {
      throw new NotFoundException(`Plan with ID ${planId} not found`);
    }
  }

  // Ajouter un collaborateur au plan
  async addCollaborator(planId: string, userId: string): Promise<Plan> {
    const plan = await this.findOne(planId);
    if (!plan.collaborators.includes(userId)) {
      plan.collaborators.push(userId);
    }
    return plan.save();
  }

  // Supprimer un collaborateur
  async removeCollaborator(planId: string, userId: string): Promise<Plan> {
    const plan = await this.findOne(planId);
    plan.collaborators = plan.collaborators.filter(
      (collabId) => collabId !== userId,
    );
    return plan.save();
  }

  // Incrémenter les "likes"
  async likePlan(planId: string): Promise<Plan> {
    const plan = await this.findOne(planId);
    plan.likes += 1;
    return plan.save();
  }
}
