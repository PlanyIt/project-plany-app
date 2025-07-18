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
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PlanService } from '../plan/plan.service';

@UseGuards(JwtAuthGuard)
@Controller('api/comments')
export class CommentController {
  constructor(
    private readonly commentService: CommentService,
    private readonly planService: PlanService,
  ) {}

  @Post()
  async createComment(@Body() createCommentDto: CommentDto, @Req() req) {
    // Vérifier que le plan est public avant de permettre le commentaire
    const plan = await this.planService.findById(createCommentDto.planId);
    if (!plan || !plan.isPublic) {
      throw new UnauthorizedException(
        'Vous ne pouvez commenter que les plans publics',
      );
    }
    const commentData = { ...createCommentDto, user: req.user._id };
    const createdComment = await this.commentService.create(commentData);
    return createdComment;
  }

  @Get('plan/:planId')
  async findAllByPlanId(
    @Param('planId') planId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 10,
  ) {
    const [comments, total] = await Promise.all([
      this.commentService.findAllByPlanId(planId, {
        page: +page,
        limit: +limit,
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

  @Delete(':commentId/response/:responseId')
  async removeResponse(
    @Param('commentId') commentId: string,
    @Param('responseId') responseId: string,
    @Req() req,
  ) {
    const response = await this.commentService.findById(responseId);

    if (!response) {
      throw new NotFoundException(`Response with ID ${responseId} not found`);
    }

    const responseUserId =
      typeof response.user === 'string' ? response.user : response.user._id;

    if (responseUserId.toString() !== req.user._id.toString()) {
      throw new UnauthorizedException('You can only delete your own responses');
    }

    return this.commentService.removeResponse(commentId, responseId);
  }

  @Put(':commentId')
  async updateComment(
    @Param('commentId') commentId: string,
    @Body() updateCommentDto: CommentDto,
    @Req() req,
  ) {
    return this.commentService.updateById(commentId, {
      ...updateCommentDto,
      user: req.user._id,
    });
  }

  @Put(':commentId/like')
  async likeComment(@Param('commentId') commentId: string, @Req() req) {
    return this.commentService.likeComment(commentId, req.user._id);
  }

  @Put(':commentId/unlike')
  async unlikeComment(@Param('commentId') commentId: string, @Req() req) {
    return this.commentService.unlikeComment(commentId, req.user._id);
  }

  @Post(':commentId/response')
  async addResponse(
    @Param('commentId') commentId: string,
    @Body() responseDto: CommentDto,
    @Req() req,
  ) {
    const responseData = { ...responseDto, user: req.user._id };
    return this.commentService.addResponse(commentId, responseData);
  }

  @Get(':commentId/responses')
  async findAllResponses(@Param('commentId') commentId: string) {
    return this.commentService.findAllResponses(commentId);
  }

  @Delete(':commentId')
  async removeComment(@Param('commentId') commentId: string, @Req() req) {
    const comment = await this.commentService.findById(commentId);

    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }

    const commentUserId =
      typeof comment.user === 'string' ? comment.user : comment.user._id;

    if (commentUserId.toString() !== req.user._id.toString()) {
      throw new UnauthorizedException('You can only delete your own comments');
    }

    return this.commentService.removeById(commentId);
  }
}
