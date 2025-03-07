import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Put,
  UseGuards,
  Req,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { PlanService } from './plan.service';
import { FirebaseAuthGuard } from 'src/auth/guards/firebase-auth.guard';
import { PlanDto } from './dto/plan.dto';

@Controller('api/plans')
export class PlanController {
  constructor(private readonly planService: PlanService) {}

  @Get()
  findAll() {
    return this.planService.findAll();
  }

  @Get(':planId')
  findById(@Param('planId') planId: string) {
    return this.planService.findById(planId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Post()
  async createPlan(@Body() createPlanDto: PlanDto, @Req() req) {
    try {
      const planData = { ...createPlanDto, userId: req.userId };
      return await this.planService.createPlan(planData);
    } catch (error) {
      console.error('Erreur lors de la création du plan :', error);
      throw new HttpException(
        {
          status: HttpStatus.INTERNAL_SERVER_ERROR,
          error: 'Erreur serveur lors de la création du plan',
          message: error.message,
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Put(':planId')
  updatePlan(
    @Param('planId') planId: string,
    @Body() updatePlanDto: PlanDto,
    @Body('userId') userId: string,
  ) {
    return this.planService.updateById(planId, updatePlanDto, userId);
  }

  @Delete(':planId')
  removePlan(@Param('planId') planId: string, @Body('userId') userId: string) {
    return this.planService.removeById(planId, userId);
  }
}
