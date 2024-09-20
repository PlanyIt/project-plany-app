import { Module } from '@nestjs/common';
import { PlanModule } from './plan/plan.module';
import { CategoryService } from './category/category.service';
import { CategoryController } from './category/category.controller';
import { TagService } from './tag/tag.service';
import { TagController } from './tag/tag.controller';
import { TypeController } from './type/type.controller';
import { TypeService } from './type/type.service';
import { AccessController } from './access/access.controller';
import { AccessService } from './access/access.service';
import { StepController } from './step/step.controller';
import { StepService } from './step/step.service';
import { CommentController } from './comment/comment.controller';
import { CommentService } from './comment/comment.service';
import { MongooseModule } from '@nestjs/mongoose';
import { CategoryModule } from './category/category.module';

@Module({
  imports: [
    MongooseModule.forRoot(process.env.MONGO_URI),
    PlanModule,
    CategoryModule,
  ],
  providers: [
    CategoryService,
    TagService,
    TypeService,
    AccessService,
    StepService,
    CommentService,
  ],
  controllers: [
    CategoryController,
    TagController,
    TypeController,
    AccessController,
    StepController,
    CommentController,
  ],
})
export class AppModule {}
