import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Put,
  UseGuards,
  Req,
} from '@nestjs/common';
import { CommentService } from './comment.service';
import { CreateCommentDto } from './dto/create-comment.dto';
import { FirebaseAuthGuard } from 'src/auth/guards/firebase-auth.guard';

@Controller('api/comments')
export class CommentController {
  constructor(private readonly commentService: CommentService) {}

  @UseGuards(FirebaseAuthGuard)
  @Post()
  async createComment(@Body() createCommentDto: CreateCommentDto, @Req() req) {
    const commentData = { ...createCommentDto, userId: req.userId };
    return this.commentService.create(commentData);
  }

  @Get(':planId')
  async findAllByPlanId(@Param('planId') planId: string) {
    return this.commentService.findAllByPlanId(planId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Delete(':commentId')
  async removeComment(@Param('commentId') commentId: string) {
    return this.commentService.removeById(commentId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Put(':commentId')
  async updateComment(
    @Param('commentId') commentId: string,
    @Body() updateCommentDto: CreateCommentDto,
    @Body('userId') userId: string,
    @Body('planId') planId: string,
  ) {
    return this.commentService.updateById(
      commentId,
      updateCommentDto,
      userId,
      planId,
    );
  }
}
