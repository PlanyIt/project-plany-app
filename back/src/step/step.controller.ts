import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Put,
  UseGuards,
  NotFoundException,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { StepService } from './step.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { StepDto } from './dto/step.dto';

@ApiTags('Steps')
@Controller('api/steps')
export class StepController {
  constructor(private readonly stepService: StepService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Create a new step',
    description:
      'Create a new step with title, description, location and other details',
  })
  @ApiBody({
    type: StepDto,
    description: 'Step data',
    examples: {
      'Travel Step': {
        value: {
          title: 'Visit Eiffel Tower',
          description: 'Go to the iconic Eiffel Tower and take amazing photos',
          latitude: 48.8584,
          longitude: 2.2945,
          order: 1,
          image: 'https://example.com/eiffel-tower.jpg',
          duration: '2 hours',
          cost: 25.5,
          userId: '507f1f77bcf86cd799439012',
        },
      },
      'Workout Step': {
        value: {
          title: 'Push-ups',
          description: '3 sets of 10 push-ups',
          order: 2,
          image: 'https://example.com/pushups.jpg',
          duration: '5 minutes',
          userId: '507f1f77bcf86cd799439012',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Step created successfully',
    schema: {
      type: 'object',
      properties: {
        _id: { type: 'string', example: '507f1f77bcf86cd799439015' },
        title: { type: 'string', example: 'Visit Eiffel Tower' },
        description: {
          type: 'string',
          example: 'Go to the iconic Eiffel Tower',
        },
        latitude: { type: 'number', example: 48.8584 },
        longitude: { type: 'number', example: 2.2945 },
        order: { type: 'number', example: 1 },
        image: { type: 'string', example: 'https://example.com/eiffel.jpg' },
        duration: { type: 'string', example: '2 hours' },
        cost: { type: 'number', example: 25.5 },
        userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
        createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid step data',
    schema: {
      example: {
        statusCode: 400,
        message: [
          'title should not be empty',
          'order must be a positive number',
        ],
        error: 'Bad Request',
      },
    },
  })
  async createStep(@Body() createStepDto: StepDto) {
    const stepData = { ...createStepDto };
    return this.stepService.create(stepData);
  }

  @Get()
  @ApiOperation({
    summary: 'Get all steps',
    description: 'Retrieve all steps available in the system',
  })
  @ApiResponse({
    status: 200,
    description: 'Steps retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439015' },
          title: { type: 'string', example: 'Visit Eiffel Tower' },
          description: {
            type: 'string',
            example: 'Go to the iconic Eiffel Tower',
          },
          latitude: { type: 'number', example: 48.8584 },
          longitude: { type: 'number', example: 2.2945 },
          order: { type: 'number', example: 1 },
          image: { type: 'string', example: 'https://example.com/eiffel.jpg' },
          duration: { type: 'string', example: '2 hours' },
          cost: { type: 'number', example: 25.5 },
          userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
          updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  async findAll() {
    return this.stepService.findAll();
  }

  @Get(':stepId')
  @ApiOperation({
    summary: 'Get step by ID',
    description: 'Retrieve a specific step by its unique identifier',
  })
  @ApiParam({
    name: 'stepId',
    description: 'The unique identifier of the step',
    example: '507f1f77bcf86cd799439015',
  })
  @ApiResponse({
    status: 200,
    description: 'Step retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        _id: { type: 'string', example: '507f1f77bcf86cd799439015' },
        title: { type: 'string', example: 'Visit Eiffel Tower' },
        description: {
          type: 'string',
          example: 'Go to the iconic Eiffel Tower',
        },
        latitude: { type: 'number', example: 48.8584 },
        longitude: { type: 'number', example: 2.2945 },
        order: { type: 'number', example: 1 },
        image: { type: 'string', example: 'https://example.com/eiffel.jpg' },
        duration: { type: 'string', example: '2 hours' },
        cost: { type: 'number', example: 25.5 },
        userId: { type: 'string', example: '507f1f77bcf86cd799439012' },
        createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        updatedAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Step not found',
    schema: {
      example: {
        statusCode: 404,
        message: 'Step with ID 507f1f77bcf86cd799439015 not found',
        error: 'Not Found',
      },
    },
  })
  async findById(@Param('stepId') stepId: string) {
    console.log(`Fetching step for ID: ${stepId}`);
    const step = await this.stepService.findById(stepId);
    if (!step) {
      console.log(`Step not found for ID: ${stepId}`);
      throw new NotFoundException(`Step with ID ${stepId} not found`);
    }
    console.log(`Found step for ID: ${stepId}`);
    return step;
  }

  @Get('plan/:planId')
  @ApiOperation({
    summary: 'Get steps by plan ID',
    description: 'Retrieve all steps for a specific plan',
  })
  @ApiParam({
    name: 'planId',
    description: 'The unique identifier of the plan',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Plan steps retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '507f1f77bcf86cd799439015' },
          title: { type: 'string', example: 'Visit Eiffel Tower' },
          description: {
            type: 'string',
            example: 'Go to the iconic Eiffel Tower',
          },
          order: { type: 'number', example: 1 },
          image: { type: 'string', example: 'https://example.com/eiffel.jpg' },
          duration: { type: 'string', example: '2 hours' },
          cost: { type: 'number', example: 25.5 },
          createdAt: { type: 'string', example: '2023-01-01T00:00:00.000Z' },
        },
      },
    },
  })
  async findAllByPlanId(@Param('planId') planId: string) {
    return this.stepService.findAllByPlanId(planId);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':stepId')
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Update a step',
    description:
      'Update an existing step by its ID (only the owner can update)',
  })
  @ApiParam({
    name: 'stepId',
    description: 'The unique identifier of the step to update',
    example: '507f1f77bcf86cd799439015',
  })
  @ApiBody({
    type: StepDto,
    description: 'Updated step data',
    examples: {
      'Update Step': {
        value: {
          title: 'Updated Visit Eiffel Tower',
          description:
            'Go to the iconic Eiffel Tower and enjoy the sunset view',
          latitude: 48.8584,
          longitude: 2.2945,
          order: 1,
          image: 'https://example.com/eiffel-sunset.jpg',
          duration: '3 hours',
          cost: 30.0,
          userId: '507f1f77bcf86cd799439012',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Step updated successfully',
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Not the owner of the step',
  })
  @ApiResponse({
    status: 404,
    description: 'Step not found',
  })
  async updateStep(
    @Param('stepId') stepId: string,
    @Body() updateStepDto: StepDto,
    @Body('userId') userId: string,
    @Body('planId') planId: string,
  ) {
    return this.stepService.updateById(stepId, updateStepDto, userId, planId);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':stepId')
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Delete a step',
    description: 'Delete a step by its ID (only the owner can delete)',
  })
  @ApiParam({
    name: 'stepId',
    description: 'The unique identifier of the step to delete',
    example: '507f1f77bcf86cd799439015',
  })
  @ApiResponse({
    status: 200,
    description: 'Step deleted successfully',
    schema: {
      example: {
        message: 'Step deleted successfully',
      },
    },
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Not the owner of the step',
  })
  @ApiResponse({
    status: 404,
    description: 'Step not found',
  })
  async removeStep(@Param('stepId') stepId: string) {
    return this.stepService.removeById(stepId);
  }
}
