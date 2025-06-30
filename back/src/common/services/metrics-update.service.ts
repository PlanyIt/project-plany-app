import { Injectable, OnModuleInit } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { MetricsService } from '../../metrics/metrics.service';
import { UserService } from '../../user/user.service';
import { PlanService } from '../../plan/plan.service';
import { CommentService } from '../../comment/comment.service';
import { CategoryService } from '../../category/category.service';

@Injectable()
export class MetricsUpdateService implements OnModuleInit {
  constructor(
    private readonly metricsService: MetricsService,
    private readonly userService: UserService,
    private readonly planService: PlanService,
    private readonly commentService: CommentService,
    private readonly categoryService: CategoryService,
  ) {}

  async onModuleInit() {
    // Initialiser les métriques au démarrage
    await this.updateAllMetrics();
  }

  @Cron(CronExpression.EVERY_MINUTE)
  async updateBusinessMetrics() {
    await this.updateAllMetrics();
  }

  private async updateAllMetrics() {
    try {
      // Compter les utilisateurs
      const usersCount = await this.userService.count();

      // Compter les plans
      const plansCount = await this.planService.count();

      // Compter les commentaires
      const commentsCount = await this.commentService.count();

      // Compter les plans par catégorie
      const plansByCategory = await this.getPlansByCategory();

      // Mettre à jour toutes les métriques
      await this.metricsService.updateBusinessMetrics(
        usersCount,
        plansCount,
        commentsCount,
        plansByCategory,
      );
    } catch (error) {
      console.error('Erreur lors de la mise à jour des métriques:', error);
    }
  }

  private async getPlansByCategory(): Promise<Record<string, number>> {
    try {
      // Récupérer toutes les catégories
      const categories = await this.categoryService.findAll();
      const plansByCategory: Record<string, number> = {};

      // Compter les plans pour chaque catégorie
      for (const category of categories) {
        const count = await this.planService.countByCategory(category.id);
        plansByCategory[category.name] = count;
      }

      return plansByCategory;
    } catch (error) {
      console.error('Erreur lors du comptage des plans par catégorie:', error);
      return {};
    }
  }
}
