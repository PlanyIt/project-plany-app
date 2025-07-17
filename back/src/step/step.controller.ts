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
@UseGuards(JwtAuthGuard)
@Controller('api/steps')
export class StepController {
  constructor(private readonly stepService: StepService) {}

  @Post()
  async createStep(@Body() createStepDto: StepDto, @Req() req) {
    const stepData = { ...createStepDto, userId: req.user._id };
    return this.stepService.create(stepData);
  }

  @Post('batch')
  async findByIds(@Body('stepIds') stepIds: string[]) {
    return this.stepService.findByIds(stepIds);
  }

  @Get()
  async findAll() {
    return this.stepService.findAll();
  }

  @Get(':stepId')
  async findById(@Param('stepId') stepId: string) {
    return this.stepService.findById(stepId);
  }

  @Delete(':stepId')
  async removeStep(@Param('stepId') stepId: string) {
    return this.stepService.removeById(stepId);
  }

  @Put(':stepId')
  async updateStep(
    @Param('stepId') stepId: string,
    @Body() updateStepDto: StepDto,
    @Req() req,
  ) {
    return this.stepService.updateById(stepId, updateStepDto, req.user._id);
  }
}
