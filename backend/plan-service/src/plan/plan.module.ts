import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Plan, PlanSchema } from './plan.schema'; // Assurez-vous d'importer le schéma
import { PlansController } from './plan.controller';
import { PlanService } from './plan.service';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Plan.name, schema: PlanSchema }]), // Configuration correcte
  ],
  controllers: [PlansController],
  providers: [PlanService],
})
export class PlanModule {}
