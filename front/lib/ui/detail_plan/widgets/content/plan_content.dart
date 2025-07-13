import 'package:flutter/material.dart';

import '../../view_models/plan_details_viewmodel.dart';
import 'comments/comment_section.dart';
import 'info_plan/plan_info_section.dart';
import 'steps_carousel/steps_carousel.dart';

class PlanContent extends StatelessWidget {
  final ScrollController scrollController;
  final PlanDetailsViewModel planViewModel;

  const PlanContent({
    super.key,
    required this.scrollController,
    required this.planViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Poignée du bottom sheet
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Contenu défilable
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Informations du plan
                PlanInfoSection(
                  plan: planViewModel.plan,
                  categoryName:
                      planViewModel.plan.category?.name ?? 'Sans catégorie',
                  categoryIcon: planViewModel.planCategoryIcon,
                  steps: planViewModel.plan.steps,
                  viewModel: planViewModel,
                ),

                // Séparateur
                _buildElegantDivider(icon: Icons.map_outlined),

                //Étapes du plan
                SizedBox(
                  height: 400,
                  child: StepsCarousel(
                    steps: planViewModel.plan.steps,
                    categoryColor:
                        planViewModel.planCategoryColor ?? Colors.grey,
                  ),
                ),

                // Séparateur
                _buildElegantDivider(icon: Icons.chat_bubble_outline),

                //Commentaires
                CommentSection(
                  planId: planViewModel.plan.id!,
                  isEmbedded: true,
                  categoryColor: planViewModel.planCategoryColor ?? Colors.grey,
                  viewModel: planViewModel.commentViewModel,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Séparateur entre les sections
  Widget _buildElegantDivider({IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade200,
                    planViewModel.planCategoryColor?.withValues(alpha: 0.5) ??
                        Colors.grey.shade200,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.center,
                ),
              ),
            ),
          ),
          if (icon != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: planViewModel.planCategoryColor
                            ?.withValues(alpha: 0.1) ??
                        Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: planViewModel.planCategoryColor ?? Colors.grey.shade600,
                size: 24,
              ),
            ),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    planViewModel.planCategoryColor?.withValues(alpha: 0.5) ??
                        Colors.grey.shade200,
                    Colors.grey.shade200,
                  ],
                  begin: Alignment.center,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
