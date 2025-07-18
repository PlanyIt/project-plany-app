import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { CommentController } from './comment.controller';
import { CommentService } from './comment.service';
import { Comment, CommentSchema } from './schemas/comment.schema';
import { PlanModule } from '../plan/plan.module'; // ✅ tu dois l'importer ici

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Comment.name, schema: CommentSchema }]),
    PlanModule,
  ],
  controllers: [CommentController],
  providers: [CommentService],
})
export class CommentModule {}
