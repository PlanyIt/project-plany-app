import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
} from '@nestjs/common';
import { PlanService } from './plan.service';
import { CreatePlanDto } from './dto/create-plan.dto';
import { UpdatePlanDto } from './dto/update-plan.dto';

@Controller('plans')
export class PlansController {
  constructor(private readonly planService: PlanService) {}

  // Créer un plan
  @Post()
  async create(@Body() createPlanDto: CreatePlanDto) {
    return this.planService.createPlan(createPlanDto);
  }

  // Obtenir tous les plans
  @Get()
  async findAll() {
    return this.planService.findAll();
  }

  // Obtenir un plan par son ID
  @Get(':planId')
  async findOne(@Param('planId') planId: string) {
    return this.planService.findOne(planId);
  }

  // Mettre à jour un plan
  @Put(':planId')
  async update(
    @Param('planId') planId: string,
    @Body() updatePlanDto: UpdatePlanDto,
  ) {
    return this.planService.updatePlan(planId, updatePlanDto);
  }

  // Supprimer un plan
  @Delete(':planId')
  async delete(@Param('planId') planId: string) {
    return this.planService.deletePlan(planId);
  }

  // Ajouter un collaborateur
  @Post(':planId/collaborators/:userId')
  async addCollaborator(
    @Param('planId') planId: string,
    @Param('userId') userId: string,
  ) {
    return this.planService.addCollaborator(planId, userId);
  }

  // Supprimer un collaborateur
  @Delete(':planId/collaborators/:userId')
  async removeCollaborator(
    @Param('planId') planId: string,
    @Param('userId') userId: string,
  ) {
    return this.planService.removeCollaborator(planId, userId);
  }

  // Incrémenter les "likes"
  @Post(':planId/like')
  async likePlan(@Param('planId') planId: string) {
    return this.planService.likePlan(planId);
  }
}
