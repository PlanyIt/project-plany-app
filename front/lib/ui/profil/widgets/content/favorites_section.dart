import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../routing/routes.dart';
import '../../../core/ui/card/compact_plan_card.dart';
import '../../view_models/favorites_viewmodel.dart';
import '../common/section_header.dart';

class FavoritesSection extends StatelessWidget {
  final FavoritesViewModel viewModel;

  const FavoritesSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<FavoritesViewModel>(
        builder: (context, vm, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SectionHeader(
                  title: "Favoris",
                  subtitle:
                      "${vm.favorites.length} plan${vm.favorites.length > 1 ? 's' : ''} en favoris",
                  icon: Icons.favorite_rounded,
                  gradientColors: const [Colors.red, Colors.redAccent],
                ),
              ),
              if (vm.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!vm.isLoading && vm.favorites.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.favorite_border,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Aucun favori pour le moment',
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ),
              if (!vm.isLoading && vm.favorites.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ...vm.displayedFavorites.map(
                        (plan) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CompactPlanCard(
                            title: plan.title,
                            description: plan.description,
                            imageUrls: plan.steps
                                .map((e) => e.image)
                                .where((img) => img.isNotEmpty)
                                .toList(),
                            category: plan.category,
                            stepsCount: plan.steps.length,
                            totalCost: plan.steps.fold(0.0,
                                (total, step) => total! + (step.cost ?? 0)),
                            totalDuration: plan.steps.fold(0,
                                (total, step) => total! + (step.duration ?? 0)),
                            onTap: () => context
                                .push('${Routes.planDetails}?id=${plan.id}'),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      if (vm.favorites.length > vm.displayLimit)
                        Center(
                          child: ElevatedButton(
                            onPressed: vm.showMore,
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
        },
      ),
    );
  }
}
