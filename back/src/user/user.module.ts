import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { User, UserSchema } from './schemas/user.schema';
import { PlanModule } from '../plan/plan.module';
import { AuthModule } from '../auth/auth.module';
import { Plan, PlanSchema } from 'src/plan/schemas/plan.schema';
import { Comment, CommentSchema } from 'src/comment/schemas/comment.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Plan.name, schema: PlanSchema },
      { name: Comment.name, schema: CommentSchema },
    ]),
    forwardRef(() => PlanModule),
    forwardRef(() => AuthModule),
  ],
  controllers: [UserController],
  providers: [UserService],
  exports: [UserService, MongooseModule],
})
export class UserModule {}
