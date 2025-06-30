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
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiBody,
  ApiQuery,
} from '@nestjs/swagger';
import { CommentService } from './comment.service';
import { CommentDto } from './dto/comment.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Comments')
@ApiBearerAuth('access-token')
@Controller('api/comments')
export class CommentController {
  constructor(private readonly commentService: CommentService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  @ApiOperation({
    summary: 'Create a new comment',
    description: 'Create a new comment on a plan',
  })
  @ApiBody({
    type: CommentDto,
    description: 'Comment data',
    examples: {
      'Comment Example': {
        value: {
          content: 'This is a great plan! Thanks for sharing.',
          planId: '507f1f77bcf86cd799439011',
          imageUrl: 'https://example.com/comment-image.jpg',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Comment created successfully',
    schema: {
      type: 'object',
      properties: {
        _id: { type: 'string', example: '507f1f77bcf86cd799439014' },
        content: { type: 'string', example: 'This is a great plan!' },
        userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
        planId: { type: 'string', example: '507f1f77bcf86cd799439011' },
        likes: { type: 'array', items: { type: 'string' }, example: [] },
        responses: { type: 'array', items: { type: 'string' }, example: [] },
        imageUrl: { type: 'string', example: 'https://example.com/image.jpg' },
        createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
      },
    },
  })
  async createComment(@Body() createCommentDto: CommentDto, @Req() req: any) {
    const commentData = { ...createCommentDto, userId: req.user._id };
    return this.commentService.create(commentData);
  }

  @Get('plan/:planId')
  @ApiOperation({
    summary: 'Get comments by plan ID',
    description: 'Retrieve all comments for a specific plan with pagination',
  })
  @ApiParam({
    name: 'planId',
    description: 'The unique identifier of the plan',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    description: 'Page number for pagination',
    example: 1,
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    description: 'Number of comments per page',
    example: 10,
  })
  @ApiResponse({
    status: 200,
    description: 'Comments retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        comments: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              _id: { type: 'string', example: '507f1f77bcf86cd799439014' },
              content: { type: 'string', example: 'Great plan!' },
              userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
              planId: { type: 'string', example: '507f1f77bcf86cd799439011' },
              likes: { type: 'array', items: { type: 'string' } },
              responses: { type: 'array', items: { type: 'string' } },
              createdAt: {
                type: 'string',
                example: '2023-01-01T00:00:00.000Z',
              },
            },
          },
        },
        meta: {
          type: 'object',
          properties: {
            total: { type: 'number', example: 25 },
            page: { type: 'number', example: 1 },
            limit: { type: 'number', example: 10 },
            totalPages: { type: 'number', example: 3 },
          },
        },
      },
    },
  })
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
  @ApiOperation({
    summary: 'Get comment by ID',
    description: 'Retrieve a specific comment by its unique identifier',
  })
  @ApiParam({
    name: 'commentId',
    description: 'The unique identifier of the comment',
    example: '507f1f77bcf86cd799439014',
  })
  @ApiResponse({
    status: 200,
    description: 'Comment retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        _id: { type: 'string', example: '507f1f77bcf86cd799439014' },
        content: { type: 'string', example: 'This is a great plan!' },
        userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
        planId: { type: 'string', example: '507f1f77bcf86cd799439011' },
        likes: { type: 'array', items: { type: 'string' }, example: [] },
        responses: { type: 'array', items: { type: 'string' }, example: [] },
        createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Comment not found',
  })
  async findById(@Param('commentId') _id: string) {
    return this.commentService.findById(_id);
  }

  @Get('user/:userId')
  @ApiOperation({
    summary: 'Get comments by user ID',
    description: 'Retrieve all comments made by a specific user',
  })
  @ApiParam({
    name: 'userId',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'User comments retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439014' },
          content: { type: 'string', example: 'This is a great plan!' },
          userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
          planId: { type: 'string', example: '507f1f77bcf86cd799439011' },
          likes: { type: 'array', items: { type: 'string' } },
          responses: { type: 'array', items: { type: 'string' } },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  async findAllByUserId(@Param('userId') userId: string) {
    return this.commentService.findAllByUserId(userId);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':commentId')
  @ApiOperation({
    summary: 'Update a comment',
    description: 'Update an existing comment (only the author can update)',
  })
  @ApiParam({
    name: 'commentId',
    description: 'The unique identifier of the comment to update',
    example: '507f1f77bcf86cd799439014',
  })
  @ApiBody({
    type: CommentDto,
    description: 'Updated comment data',
    examples: {
      'Update Comment': {
        value: {
          content: 'This is an updated comment!',
          planId: '507f1f77bcf86cd799439011',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Comment updated successfully',
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Not the author of the comment',
  })
  @ApiResponse({
    status: 404,
    description: 'Comment not found',
  })
  async updateComment(
    @Param('commentId') commentId: string,
    @Body() updateCommentDto: CommentDto,
    @Req() req: any,
  ) {
    return this.commentService.updateById(commentId, {
      ...updateCommentDto,
      userId: req.user._id,
    });
  }

  @UseGuards(JwtAuthGuard)
  @Put(':commentId/like')
  @ApiOperation({
    summary: 'Like a comment',
    description: 'Add a like to a comment',
  })
  @ApiParam({
    name: 'commentId',
    description: 'The unique identifier of the comment to like',
    example: '507f1f77bcf86cd799439014',
  })
  @ApiResponse({
    status: 200,
    description: 'Comment liked successfully',
    schema: {
      example: {
        message: 'Comment liked successfully',
        likes: ['507f1f77bcf86cd799439012'],
      },
    },
  })
  async likeComment(@Param('commentId') commentId: string, @Req() req: any) {
    return this.commentService.likeComment(commentId, req.user._id);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':commentId/unlike')
  @ApiOperation({
    summary: 'Unlike a comment',
    description: 'Remove a like from a comment',
  })
  @ApiParam({
    name: 'commentId',
    description: 'The unique identifier of the comment to unlike',
    example: '507f1f77bcf86cd799439014',
  })
  @ApiResponse({
    status: 200,
    description: 'Comment unliked successfully',
    schema: {
      example: {
        message: 'Comment unliked successfully',
        likes: [],
      },
    },
  })
  async unlikeComment(@Param('commentId') commentId: string, @Req() req: any) {
    return this.commentService.unlikeComment(commentId, req.user._id);
  }

  @UseGuards(JwtAuthGuard)
  @Post(':commentId/response')
  @ApiOperation({
    summary: 'Add a response to a comment',
    description: 'Create a response to an existing comment',
  })
  @ApiParam({
    name: 'commentId',
    description: 'The unique identifier of the comment to respond to',
    example: '507f1f77bcf86cd799439014',
  })
  @ApiBody({
    type: CommentDto,
    description: 'Response data',
    examples: {
      'Response Example': {
        value: {
          content: 'Thank you for your comment!',
          planId: '507f1f77bcf86cd799439011',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Response added successfully',
  })
  async addResponse(
    @Param('commentId') commentId: string,
    @Body() responseDto: CommentDto,
    @Req() req: any,
  ) {
    const responseData = { ...responseDto, userId: req.user._id };
    return this.commentService.addResponse(commentId, responseData);
  }

  @Get(':commentId/responses')
  @ApiOperation({
    summary: 'Get comment responses',
    description: 'Retrieve all responses to a specific comment',
  })
  @ApiParam({
    name: 'commentId',
    description: 'The unique identifier of the comment',
    example: '507f1f77bcf86cd799439014',
  })
  @ApiResponse({
    status: 200,
    description: 'Responses retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439015' },
          content: { type: 'string', example: 'Thank you for your comment!' },
          userId: { type: 'string', example: '507f1f77bcf86cd799439013' },
          planId: { type: 'string', example: '507f1f77bcf86cd799439011' },
          parentId: { type: 'string', example: '507f1f77bcf86cd799439014' },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  async findAllResponses(@Param('commentId') commentId: string) {
    return this.commentService.findAllResponses(commentId);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':commentId')
  @ApiOperation({
    summary: 'Delete a comment',
    description: 'Delete a comment by its ID (only the author can delete)',
  })
  @ApiParam({
    name: 'commentId',
    description: 'The unique identifier of the comment to delete',
    example: '507f1f77bcf86cd799439014',
  })
  @ApiResponse({
    status: 200,
    description: 'Comment deleted successfully',
    schema: {
      example: {
        message: 'Comment deleted successfully',
      },
    },
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Not the author of the comment',
  })
  @ApiResponse({
    status: 404,
    description: 'Comment not found',
  })
  async removeComment(@Param('commentId') commentId: string, @Req() req: any) {
    const comment = await this.commentService.findById(commentId);

    if (!comment) {
      throw new NotFoundException(`Comment with ID ${commentId} not found`);
    }

    if (comment.userId !== req.user._id.toString()) {
      throw new UnauthorizedException('You can only delete your own comments');
    }

    return this.commentService.removeById(commentId);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':commentId/response/:responseId')
  @ApiOperation({
    summary: 'Delete a comment response',
    description: 'Delete a response to a comment (only the author can delete)',
  })
  @ApiParam({
    name: 'commentId',
    description: 'The unique identifier of the parent comment',
    example: '507f1f77bcf86cd799439014',
  })
  @ApiParam({
    name: 'responseId',
    description: 'The unique identifier of the response to delete',
    example: '507f1f77bcf86cd799439015',
  })
  @ApiResponse({
    status: 200,
    description: 'Response deleted successfully',
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Not the author of the response',
  })
  @ApiResponse({
    status: 404,
    description: 'Response not found',
  })
  async removeResponse(
    @Param('commentId') commentId: string,
    @Param('responseId') responseId: string,
    @Req() req: any,
  ) {
    const response = await this.commentService.findById(responseId);

    if (!response) {
      throw new NotFoundException(`Response with ID ${responseId} not found`);
    }

    if (response.userId !== req.user._id.toString()) {
      throw new UnauthorizedException('You can only delete your own responses');
    }

    return this.commentService.removeResponse(commentId, responseId);
  }
}
