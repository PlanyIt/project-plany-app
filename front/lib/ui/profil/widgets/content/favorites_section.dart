import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun plan en favoris',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Parcourez les plans et ajoutez-les à vos favoris',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: "Favoris",
                  subtitle:
                      "${vm.favorites.length} plan${vm.favorites.length > 1 ? 's' : ''} en favoris",
                  icon: Icons.favorite_rounded,
                  gradientColors: const [Colors.red, Colors.redAccent],
                ),
                const SizedBox(height: 12),
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
                      totalCost: plan.steps.fold(
                          0.0, (total, step) => total! + (step.cost ?? 0)),
                      totalDuration: plan.steps.fold(
                          0, (total, step) => total! + (step.duration ?? 0)),
                      onTap: () => Navigator.pushNamed(context, '/details',
                          arguments: plan.id),
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
          );
        },
      ),
    );
  }
}
