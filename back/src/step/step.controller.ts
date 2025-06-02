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
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { StepDto } from './dto/step.dto';

@Controller('api/steps')
export class StepController {
  constructor(private readonly stepService: StepService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  async createStep(@Body() createStepDto: StepDto, @Req() req) {
    const stepData = { ...createStepDto, userId: req.user._id };
    return this.stepService.create(stepData);
  }

  @Get()
  async findAll() {
    return this.stepService.findAll();
  }

  @Get(':stepId')
  async findById(@Param('stepId') stepId: string) {
    return this.stepService.findById(stepId);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':stepId')
  async removeStep(@Param('stepId') stepId: string) {
    return this.stepService.removeById(stepId);
  }

  @Get('plan/:planId')
  async findAllByPlanId(@Param('planId') planId: string) {
    return this.stepService.findAllByPlanId(planId);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':stepId')
  async updateStep(
    @Param('stepId') stepId: string,
    @Body() updateStepDto: StepDto,
    @Body('userId') userId: string,
    @Body('planId') planId: string,
  ) {
    return this.stepService.updateById(stepId, updateStepDto, userId, planId);
  }
}
