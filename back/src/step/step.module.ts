import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Step, StepSchema } from './schemas/step.schema';
import { StepController } from './step.controller';
import { StepService } from './step.service';

@Module({})
@Module({
  imports: [
    MongooseModule.forFeature([{ name: Step.name, schema: StepSchema }]),
  ],
  controllers: [StepController],
  providers: [StepService],
})
export class StepModule {}
