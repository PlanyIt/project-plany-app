import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PlanService } from './plan.service';
import { PlanController } from './plan.controller';
import { Plan, PlanSchema } from './schemas/plan.schema';
import { UserModule } from '../user/user.module';
import { StepModule } from '../step/step.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Plan.name, schema: PlanSchema }]),
    forwardRef(() => UserModule),
    forwardRef(() => StepModule),
  ],
  controllers: [PlanController],
  providers: [PlanService],
  exports: [PlanService, MongooseModule],
})
export class PlanModule {}
