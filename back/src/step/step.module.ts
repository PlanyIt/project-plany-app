import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Step, StepSchema } from './schemas/step.schema';
import { StepController } from './step.controller';
import { StepService } from './step.service';
import { PlanModule } from '../plan/plan.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Step.name, schema: StepSchema }]),
    forwardRef(() => PlanModule),
  ],
  controllers: [StepController],
  providers: [StepService],
  exports: [StepService, MongooseModule],
})
export class StepModule {}
