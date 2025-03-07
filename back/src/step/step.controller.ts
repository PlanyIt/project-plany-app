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
import { StepDto } from './dto/step.dto';

@Controller('api/steps')
export class StepController {
  constructor(private readonly stepService: StepService) {}

  @UseGuards(FirebaseAuthGuard)
  @Post()
  async createStep(@Body() createStepDto: StepDto, @Req() req) {
    const stepData = { ...createStepDto, userId: req.userId };
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

  @UseGuards(FirebaseAuthGuard)
  @Delete(':stepId')
  async removeStep(@Param('stepId') stepId: string) {
    return this.stepService.removeById(stepId);
  }

  @UseGuards(FirebaseAuthGuard)
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
