import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/routes.dart';
import '../../../core/ui/card/compact_plan_card.dart';
import '../../view_models/my_plan_viewmodel.dart';
import '../../view_models/profile_viewmodel.dart';
import '../common/section_header.dart';

class MyPlansSection extends StatelessWidget {
  final MyPlansViewModel viewModel;
  final ProfileViewModel profileViewModel;

  const MyPlansSection({
    super.key,
    required this.viewModel,
    required this.profileViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SectionHeader(
            title: "Plans créés",
            subtitle:
                "${viewModel.totalPlans} plan${viewModel.totalPlans > 1 ? 's' : ''} créés",
            icon: Icons.map_rounded,
            gradientColors: const [Colors.purple, Colors.purpleAccent],
          ),
        ),
        if (viewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        if (!viewModel.isLoading && viewModel.displayedPlans.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.map_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Aucun plan créé pour le moment',
                      style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ),
        if (!viewModel.isLoading && viewModel.displayedPlans.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ...viewModel.displayedPlans.map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Stack(
                      children: [
                        CompactPlanCard(
                          title: plan.title,
                          description: plan.description,
                          imageUrls: plan.steps
                              .where((step) => step.image.isNotEmpty)
                              .map((step) => step.image)
                              .toList(),
                          category: plan.category,
                          user: plan.user,
                          stepsCount: plan.steps.length,
                          totalCost: plan.totalCost,
                          totalDuration: plan.totalDuration,
                          onTap: () => context
                              .push('${Routes.planDetails}?id=${plan.id}'),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.white, size: 20),
                              onPressed: () async {
                                await viewModel.deletePlan(context, plan.id!);
                                await profileViewModel.refreshStats();
                              },
                              tooltip: 'Supprimer ce plan',
                              constraints: BoxConstraints.tight(Size(36, 36)),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (viewModel.totalPlans > viewModel.displayLimit)
                  Center(
                    child: ElevatedButton(
                      onPressed: viewModel.showMore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                      ),
                      child: const Text("Afficher plus"),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
