import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { User, UserSchema } from './schemas/user.schema';
import { Plan, PlanSchema } from '../plan/schemas/plan.schema';
import { PlanModule } from '../plan/plan.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Plan.name, schema: PlanSchema },
    ]),
    forwardRef(() => PlanModule),
  ],
  controllers: [UserController],
  providers: [UserService],
  exports: [UserService], // Important: exporter UserService
})
export class UserModule {}
