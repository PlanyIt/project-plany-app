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
  NotFoundException,
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
    console.log(`Fetching step for ID: ${stepId}`);
    const step = await this.stepService.findById(stepId);
    if (!step) {
      console.log(`Step not found for ID: ${stepId}`);
      throw new NotFoundException(`Step with ID ${stepId} not found`);
    }
    console.log(`Found step for ID: ${stepId}`);
    return step;
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
