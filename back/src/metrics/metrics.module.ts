import { Module, Global } from '@nestjs/common';
import { MetricsService } from './metrics.service';
import { MetricsController } from './metrics.controller';
import { MetricsUpdateService } from '../common/services/metrics-update.service';
import { UserModule } from '../user/user.module';
import { PlanModule } from '../plan/plan.module';
import { CommentModule } from '../comment/comment.module';
import { CategoryModule } from '../category/category.module';

@Global()
@Module({
  imports: [UserModule, PlanModule, CommentModule, CategoryModule],
  controllers: [MetricsController],
  providers: [MetricsService, MetricsUpdateService],
  exports: [MetricsService],
})
export class MetricsModule {}
