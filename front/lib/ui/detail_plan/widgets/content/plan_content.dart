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
    final plan = planViewModel.plan!;
    final steps = plan.steps;

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
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _BottomSheetHandle(),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                PlanInfoSection(
                  plan: plan,
                  categoryName: plan.category?.name ?? 'Sans catégorie',
                  categoryIcon: plan.category?.icon,
                  steps: steps,
                  viewModel: planViewModel,
                ),
                _buildElegantDivider(icon: Icons.map_outlined),
                SizedBox(
                  height: 400,
                  child: StepsCarousel(
                    steps: steps,
                    categoryColor:
                        planViewModel.planCategoryColor ?? Colors.grey,
                  ),
                ),
                _buildElegantDivider(icon: Icons.chat_bubble_outline),
                CommentSection(
                  isEmbedded: true,
                  planDetailsViewModel: planViewModel,
                  viewModel: planViewModel.commentSectionViewModel,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantDivider({IconData? icon}) {
    final color = planViewModel.planCategoryColor ?? Colors.grey.shade200;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade200, color.withOpacity(0.5)],
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
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.5), Colors.grey.shade200],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
