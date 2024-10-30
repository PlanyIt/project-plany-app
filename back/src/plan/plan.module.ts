import { Module } from '@nestjs/common';
import { PlanController } from './plan.controller';
import { PlanService } from './plan.service';
import { AuthModule } from 'src/auth/auth.module';
import { MongooseModule } from '@nestjs/mongoose';
import { PlanSchema } from './schemas/plan.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: 'Plan', schema: PlanSchema }]),
    AuthModule,
  ],
  controllers: [PlanController],
  providers: [PlanService],
})
export class PlanModule {}
