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
  Inject,
  forwardRef,
} from '@nestjs/common';
import { PlanService } from './plan.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PlanDto } from './dto/plan.dto';
import { UserService } from '../user/user.service';
@UseGuards(JwtAuthGuard)
@Controller('api/plans')
export class PlanController {
  constructor(
    private readonly planService: PlanService,
    @Inject(forwardRef(() => UserService))
    private readonly userService: UserService,
  ) {}

  @Get()
  findAll() {
    return this.planService.findAll();
  }

  @Get(':planId')
  findById(@Param('planId') planId: string) {
    return this.planService.findById(planId);
  }

  @Post()
  async createPlan(@Body() createPlanDto: PlanDto, @Req() req) {
    try {
      const planData = {
        ...createPlanDto,
        user: req.user._id,
      };

      console.log('📝 Creating plan with data:', planData);

      const createdPlan = await this.planService.createPlan(planData);

      console.log('✅ Plan created successfully:', createdPlan._id);

      return createdPlan;
    } catch (error) {
      console.error('❌ Error creating plan:', error);
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
  updatePlan(
    @Param('planId') planId: string,
    @Body() updatePlanDto: PlanDto,
    @Body('userId') userId: string,
  ) {
    return this.planService.updateById(planId, updatePlanDto, userId);
  }

  @Delete(':planId')
  removePlan(@Param('planId') planId: string, @Req() req) {
    return this.planService.removeById(planId, req.user._id);
  }

  @Put(':planId/favorite')
  async addToFavorites(@Param('planId') planId: string, @Req() req) {
    return this.planService.addToFavorites(planId, req.user._id);
  }

  @Put(':planId/unfavorite')
  async removeFromFavorites(@Param('planId') planId: string, @Req() req) {
    return this.planService.removeFromFavorites(planId, req.user._id);
  }

  @Get('user/:userId')
  async findAllByUserId(@Param('userId') userId: string, @Req() req) {
    return this.planService.findAllByUserId(userId, req.user._id);
  }

  @Get('user/:userId/favorites')
  async findFavoritesByUserId(@Param('userId') userId: string) {
    return this.planService.findFavoritesByUserId(userId);
  }
}
