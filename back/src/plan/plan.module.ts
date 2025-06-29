import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PlanController } from './plan.controller';
import { PlanService } from './plan.service';
import { Plan, PlanSchema } from './schemas/plan.schema';
import { User, UserSchema } from '../user/schemas/user.schema';
import { UserModule } from '../user/user.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Plan.name, schema: PlanSchema },
      { name: User.name, schema: UserSchema },
    ]),
    forwardRef(() => UserModule),
  ],
  controllers: [PlanController],
  providers: [PlanService],
  exports: [PlanService],
})
export class PlanModule {}
