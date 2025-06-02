import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Put,
  Patch,
  UseGuards,
  Req,
  HttpException,
  HttpStatus,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { PlanService } from './plan.service';
import { FirebaseAuthGuard } from 'src/auth/guards/firebase-auth.guard';
import { PlanDto } from './dto/plan.dto';
import { UserService } from '../user/user.service';
import { UpdateUserDto } from '../user/dto/update-user.dto';

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

  @UseGuards(FirebaseAuthGuard)
  @Post()
  async createPlan(@Body() createPlanDto: PlanDto, @Req() req) {
    try {
      const planData = { ...createPlanDto, userId: req.userId };
      return await this.planService.createPlan(planData);
    } catch (error) {
      console.error('Erreur lors de la création du plan :', error);
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

  @UseGuards(FirebaseAuthGuard)
  @Delete(':planId')
  removePlan(@Param('planId') planId: string, @Req() req) {
    return this.planService.removeById(planId, req.userId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Put(':planId/favorite')
  async addToFavorites(@Param('planId') planId: string, @Req() req) {
    return this.planService.addToFavorites(planId, req.userId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Put(':planId/unfavorite')
  async removeFromFavorites(@Param('planId') planId: string, @Req() req) {
    return this.planService.removeFromFavorites(planId, req.userId);
  }

  @Get('user/:userId')
  async findAllByUserId(@Param('userId') userId: string) {
    return this.planService.findAllByUserId(userId);
  }

  @Get('user/:userId/favorites')
  async findFavoritesByUserId(@Param('userId') userId: string) {
    return this.planService.findFavoritesByUserId(userId);
  }

  @Patch(':firebaseUid/profile')
  async updateUserProfile(
    @Param('firebaseUid') firebaseUid: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.userService.updateByFirebaseUid(firebaseUid, updateUserDto);
  }
}
