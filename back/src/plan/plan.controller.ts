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
} from '@nestjs/common';
import { PlanService } from './plan.service';
import { CreatePlanDto } from './dto/create-plan.dto';
import { FirebaseAuthGuard } from 'src/auth/guards/firebase-auth.guard';

@Controller('api/plans')
export class PlanController {
  constructor(private readonly planService: PlanService) {}

  @Get()
  findAll() {
    return this.planService.findAll();
  }

  @UseGuards(FirebaseAuthGuard)
  @Post()
  async createPlan(@Body() createPlanDto: CreatePlanDto, @Req() req) {
    console.log(req.userId);
    const planData = {
      ...createPlanDto,
      userId: req.userId,
    };
    console.log(planData);
    return this.planService.createPlan(planData);
  }

  @Put(':planId')
  updatePlan(
    @Param('planId') planId: string,
    @Body() updatePlanDto: CreatePlanDto,
    @Body('userId') userId: string,
  ) {
    return this.planService.updateById(planId, updatePlanDto, userId);
  }

  @Delete(':planId')
  removePlan(@Param('planId') planId: string, @Body('userId') userId: string) {
    return this.planService.removeById(planId, userId);
  }
}
