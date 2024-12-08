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
import { StepService } from './step.service';
import { FirebaseAuthGuard } from 'src/auth/guards/firebase-auth.guard';
import { CreateStepDto } from './dto/create-step.dto';

@Controller('api/steps')
export class StepController {
  constructor(private readonly stepService: StepService) {}

  @UseGuards(FirebaseAuthGuard)
  @Post()
  async createStep(@Body() createStepDto: CreateStepDto, @Req() req) {
    const stepData = { ...createStepDto, userId: req.userId };
    return this.stepService.create(stepData);
  }

  @Get(':planId')
  async findAllByPlanId(@Param('planId') planId: string) {
    return this.stepService.findAllByPlanId(planId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Delete(':stepId')
  async removeStep(@Param('stepId') stepId: string) {
    return this.stepService.removeById(stepId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Put(':stepId')
  async updateStep(
    @Param('stepId') stepId: string,
    @Body() updateStepDto: CreateStepDto,
    @Body('userId') userId: string,
    @Body('planId') planId: string,
  ) {
    return this.stepService.updateById(
        stepId,
        updateStepDto,
        userId,
        planId
    );
  }
}