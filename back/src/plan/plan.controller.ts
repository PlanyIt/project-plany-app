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
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { PlanService } from './plan.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PlanDto } from './dto/plan.dto';

@ApiTags('Plans')
@Controller('api/plans')
export class PlanController {
  constructor(private readonly planService: PlanService) {}

  @Get()
  @ApiOperation({
    summary: 'Get all plans',
    description: 'Retrieve all public plans available in the system',
  })
  @ApiResponse({
    status: 200,
    description: 'Plans retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
          title: { type: 'string', example: 'Trip to Paris' },
          description: { type: 'string', example: 'A wonderful trip to Paris' },
          category: { type: 'string', example: 'Travel' },
          isPublic: { type: 'boolean', example: true },
          userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
          steps: {
            type: 'array',
            items: { type: 'string' },
            example: ['Visit Eiffel Tower', 'Go to Louvre Museum'],
          },
          favorites: {
            type: 'array',
            items: { type: 'string' },
            example: ['507f1f77bcf86cd799439013'],
          },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
          updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  findAll() {
    return this.planService.findAll();
  }

  @Get(':planId')
  @ApiOperation({
    summary: 'Get plan by ID',
    description: 'Retrieve a specific plan by its unique identifier',
  })
  @ApiParam({
    name: 'planId',
    description: 'The unique identifier of the plan',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Plan retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
        title: { type: 'string', example: 'Trip to Paris' },
        description: { type: 'string', example: 'A wonderful trip to Paris' },
        category: { type: 'string', example: 'Travel' },
        isPublic: { type: 'boolean', example: true },
        userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
        steps: {
          type: 'array',
          items: { type: 'string' },
          example: ['Visit Eiffel Tower', 'Go to Louvre Museum'],
        },
        favorites: {
          type: 'array',
          items: { type: 'string' },
          example: ['507f1f77bcf86cd799439013'],
        },
        createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Plan not found',
    schema: {
      example: {
        statusCode: 404,
        message: 'Plan not found',
        error: 'Not Found',
      },
    },
  })
  findById(@Param('planId') planId: string) {
    return this.planService.findById(planId);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Create a new plan',
    description:
      'Create a new plan with title, description, category and steps',
  })
  @ApiBody({
    type: PlanDto,
    description: 'Plan data',
    examples: {
      'Travel Plan': {
        value: {
          title: 'Trip to Paris',
          description: 'A wonderful trip to the city of lights',
          category: 'Travel',
          isPublic: true,
          userId: '507f1f77bcf86cd799439012',
          steps: [
            'Book flight tickets',
            'Reserve hotel',
            'Visit Eiffel Tower',
            'Go to Louvre Museum',
          ],
        },
      },
      'Workout Plan': {
        value: {
          title: 'Morning Workout Routine',
          description: 'Daily workout routine for better health',
          category: 'Fitness',
          isPublic: false,
          userId: '507f1f77bcf86cd799439012',
          steps: [
            'Warm up for 10 minutes',
            'Push-ups (3 sets of 10)',
            'Squats (3 sets of 15)',
            'Cool down and stretch',
          ],
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Plan created successfully',
    schema: {
      type: 'object',
      properties: {
        _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
        title: { type: 'string', example: 'Trip to Paris' },
        description: { type: 'string', example: 'A wonderful trip to Paris' },
        category: { type: 'string', example: 'Travel' },
        isPublic: { type: 'boolean', example: true },
        userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
        steps: {
          type: 'array',
          items: { type: 'string' },
          example: ['Visit Eiffel Tower', 'Go to Louvre Museum'],
        },
        favorites: { type: 'array', items: { type: 'string' }, example: [] },
        createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid plan data',
    schema: {
      example: {
        statusCode: 400,
        message: [
          'title should not be empty',
          'steps must contain at least one element',
        ],
        error: 'Bad Request',
      },
    },
  })
  async createPlan(@Body() createPlanDto: PlanDto) {
    try {
      const planData = { ...createPlanDto };
      return await this.planService.createPlan(planData);
    } catch (error) {
      console.error('Erreur lors de la création du plan :', error);
      throw new HttpException(
        {
          status: HttpStatus.INTERNAL_SERVER_ERROR,
          error: 'Erreur serveur lors de la création du plan',
          message: error.message,
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Put(':planId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Update a plan',
    description:
      'Update an existing plan by its ID (only the owner can update)',
  })
  @ApiParam({
    name: 'planId',
    description: 'The unique identifier of the plan to update',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiBody({
    type: PlanDto,
    description: 'Updated plan data',
    examples: {
      'Update Plan': {
        value: {
          title: 'Updated Trip to Paris',
          description: 'An updated wonderful trip to the city of lights',
          category: 'Travel',
          isPublic: true,
          userId: '507f1f77bcf86cd799439012',
          steps: [
            'Book flight tickets',
            'Reserve hotel',
            'Visit Eiffel Tower',
            'Go to Louvre Museum',
            'Try French cuisine',
          ],
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Plan updated successfully',
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Not the owner of the plan',
  })
  @ApiResponse({
    status: 404,
    description: 'Plan not found',
  })
  updatePlan(
    @Param('planId') planId: string,
    @Body() updatePlanDto: PlanDto,
    @Body('userId') userId: string,
  ) {
    return this.planService.updateById(planId, updatePlanDto, userId);
  }

  @Delete(':planId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Delete a plan',
    description: 'Delete a plan by its ID (only the owner can delete)',
  })
  @ApiParam({
    name: 'planId',
    description: 'The unique identifier of the plan to delete',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Plan deleted successfully',
    schema: {
      example: {
        message: 'Plan deleted successfully',
      },
    },
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Not the owner of the plan',
  })
  @ApiResponse({
    status: 404,
    description: 'Plan not found',
  })
  removePlan(@Param('planId') planId: string, @Req() req: any) {
    return this.planService.removeById(planId, req.user._id);
  }

  @Put(':planId/favorite')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Add plan to favorites',
    description: 'Add a plan to the current user favorites list',
  })
  @ApiParam({
    name: 'planId',
    description: 'The unique identifier of the plan to favorite',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Plan added to favorites successfully',
    schema: {
      example: {
        message: 'Plan added to favorites',
        plan: {
          _id: '507f1f77bcf86cd799439011',
          title: 'Trip to Paris',
          favorites: ['507f1f77bcf86cd799439012', '507f1f77bcf86cd799439013'],
        },
      },
    },
  })
  async addToFavorites(@Param('planId') planId: string, @Req() req: any) {
    return this.planService.addToFavorites(planId, req.user._id);
  }

  @Put(':planId/unfavorite')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Remove plan from favorites',
    description: 'Remove a plan from the current user favorites list',
  })
  @ApiParam({
    name: 'planId',
    description: 'The unique identifier of the plan to unfavorite',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Plan removed from favorites successfully',
    schema: {
      example: {
        message: 'Plan removed from favorites',
        plan: {
          _id: '507f1f77bcf86cd799439011',
          title: 'Trip to Paris',
          favorites: ['507f1f77bcf86cd799439013'],
        },
      },
    },
  })
  async removeFromFavorites(@Param('planId') planId: string, @Req() req: any) {
    return this.planService.removeFromFavorites(planId, req.user._id);
  }

  @Get('user/:userId')
  @ApiOperation({
    summary: 'Get plans by user ID',
    description: 'Retrieve all plans created by a specific user',
  })
  @ApiParam({
    name: 'userId',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'User plans retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
          title: { type: 'string', example: 'Trip to Paris' },
          description: { type: 'string', example: 'A wonderful trip to Paris' },
          category: { type: 'string', example: 'Travel' },
          isPublic: { type: 'boolean', example: true },
          userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
          steps: {
            type: 'array',
            items: { type: 'string' },
            example: ['Visit Eiffel Tower', 'Go to Louvre Museum'],
          },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
          updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  async findAllByUserId(@Param('userId') userId: string) {
    return this.planService.findAllByUserId(userId);
  }

  @Get('user/:userId/favorites')
  @ApiOperation({
    summary: 'Get user favorite plans',
    description: 'Retrieve all plans marked as favorites by a specific user',
  })
  @ApiParam({
    name: 'userId',
    description: 'The unique identifier of the user',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'User favorite plans retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
          title: { type: 'string', example: 'Trip to Paris' },
          description: { type: 'string', example: 'A wonderful trip to Paris' },
          category: { type: 'string', example: 'Travel' },
          isPublic: { type: 'boolean', example: true },
          userId: { type: 'string', example: '507f1f77bcf86cd799439013' },
          steps: {
            type: 'array',
            items: { type: 'string' },
            example: ['Visit Eiffel Tower', 'Go to Louvre Museum'],
          },
          favorites: {
            type: 'array',
            items: { type: 'string' },
            example: ['507f1f77bcf86cd799439012'],
          },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
          updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  async findFavoritesByUserId(@Param('userId') userId: string) {
    return this.planService.findFavoritesByUserId(userId);
  }
}
