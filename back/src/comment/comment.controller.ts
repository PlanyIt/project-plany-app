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
  UnauthorizedException,
  Query,
  NotFoundException,
} from '@nestjs/common';
import { CommentService } from './comment.service';
import { CommentDto } from './dto/comment.dto';
import { FirebaseAuthGuard } from 'src/auth/guards/firebase-auth.guard';

@Controller('api/comments')
export class CommentController {
  constructor(private readonly commentService: CommentService) {}

  @UseGuards(FirebaseAuthGuard)
  @Post()
  async createComment(@Body() createCommentDto: CommentDto, @Req() req) {
    const commentData = { ...createCommentDto, userId: req.userId };
    return this.commentService.create(commentData);
  }

  @Get('plan/:planId')
  async findAllByPlanId(
    @Param('planId') planId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 10,
  ) {
    const [comments, total] = await Promise.all([
      this.commentService.findAllByPlanId(planId, {
        page: +page, // Convertir en nombre
        limit: +limit, // Convertir en nombre
      }),
      this.commentService.countByPlanId(planId),
    ]);

    return {
      comments,
      meta: {
        total,
        page: +page,
        limit: +limit,
        totalPages: Math.ceil(total / +limit),
      },
    };
  }

  @Get(':commentId')
  async findById(@Param('commentId') _id: string) {
    return this.commentService.findById(_id);
  }

  @Get('user/:userId')
  async findAllByUserId(@Param('userId') userId: string) {
    return this.commentService.findAllByUserId(userId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Delete(':commentId/response/:responseId')
  async removeResponse(
    @Param('commentId') commentId: string,
    @Param('responseId') responseId: string,
    @Req() req,
  ) {
    // Vérifier que l'utilisateur est le propriétaire de la réponse
    const response = await this.commentService.findById(responseId);

    if (!response) {
      throw new NotFoundException(`Response with ID ${responseId} not found`);
    }

    if (response.userId !== req.userId) {
      throw new UnauthorizedException('You can only delete your own responses');
    }

    // Supprimer la réponse et la retirer du tableau responses du commentaire parent
    return this.commentService.removeResponse(commentId, responseId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Put(':commentId')
  async updateComment(
    @Param('commentId') commentId: string,
    @Body() updateCommentDto: CommentDto,
    @Req() req,
  ) {
    return this.commentService.updateById(commentId, {
      ...updateCommentDto,
      userId: req.userId,
    });
  }

  @UseGuards(FirebaseAuthGuard)
  @Put(':commentId/like')
  async likeComment(@Param('commentId') commentId: string, @Req() req) {
    return this.commentService.likeComment(commentId, req.userId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Put(':commentId/unlike')
  async unlikeComment(@Param('commentId') commentId: string, @Req() req) {
    return this.commentService.unlikeComment(commentId, req.userId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Post(':commentId/response')
  async addResponse(
    @Param('commentId') commentId: string,
    @Body() responseDto: CommentDto,
    @Req() req,
  ) {
    const responseData = { ...responseDto, userId: req.userId };
    return this.commentService.addResponse(commentId, responseData);
  }

  @Get(':commentId/responses')
  async findAllResponses(@Param('commentId') commentId: string) {
    return this.commentService.findAllResponses(commentId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Delete(':commentId')
  async removeComment(@Param('commentId') commentId: string, @Req() req) {
    // Vérifier que l'utilisateur est le propriétaire du commentaire
    const comment = await this.commentService.findById(commentId);

    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }

    if (comment.userId !== req.userId) {
      throw new UnauthorizedException('You can only delete your own comments');
    }

    return this.commentService.removeById(commentId);
  }
}
