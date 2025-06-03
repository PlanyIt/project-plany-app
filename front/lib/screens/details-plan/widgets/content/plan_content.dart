import 'package:flutter/material.dart';
import 'package:front/domain/models/category.dart';
import 'package:front/domain/models/plan.dart';
import 'package:front/domain/models/step.dart' as plan_steps;
import 'package:front/screens/details-plan/widgets/content/info_plan/plan_info_section.dart';
import 'package:front/screens/details-plan/widgets/content/steps_carousel/steps_carousel.dart';
import 'package:front/screens/details-plan/widgets/content/comments/comment_section.dart';

class PlanContent extends StatelessWidget {
  final Plan plan;
  final Color categoryColor;
  final ScrollController scrollController;
  final Category? category;
  final List<plan_steps.Step>? steps;

  const PlanContent({
    super.key,
    required this.plan,
    required this.categoryColor,
    required this.scrollController,
    this.category,
    this.steps,
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
            color: Colors.black.withOpacity(0.1),
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
                  plan: plan,
                  categoryColor: categoryColor,
                  categoryName: category?.name,
                  categoryIcon: category?.icon,
                  steps: steps,
                ),

                // Séparateur
                _buildElegantDivider(icon: Icons.map_outlined),

                //Étapes du plan
                SizedBox(
                  height: 400,
                  child: StepsCarousel(
                    steps: steps,
                    categoryColor: categoryColor,
                  ),
                ),

                // Séparateur
                _buildElegantDivider(icon: Icons.chat_bubble_outline),

                //Commentaires
                CommentSection(
                  planId: plan.id!,
                  isEmbedded: true,
                  categoryColor: categoryColor,
                ),

                // Espace en bas pour éviter que le dernier élément soit coupé
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
                    categoryColor.withOpacity(0.5),
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
                    color: categoryColor.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: categoryColor,
                size: 24,
              ),
            ),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    categoryColor.withOpacity(0.5),
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
