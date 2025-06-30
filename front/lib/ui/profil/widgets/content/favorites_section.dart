import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as plan_steps;
import 'package:front/ui/profil/widgets/common/section_header.dart';
import 'package:front/utils/helpers.dart';
import 'package:front/ui/core/ui/card/compact_plan_card.dart';
import 'package:front/providers/providers.dart';
import 'package:front/utils/result.dart';

// Providers pour l'état des favoris
final favoritesDisplayLimitProvider = StateProvider<int>((ref) => 5);

class FavoritesSection extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback? onFavoritesUpdated;

  const FavoritesSection({
    super.key,
    required this.userId,
    this.onFavoritesUpdated,
  });
  @override
  ConsumerState<FavoritesSection> createState() => FavoritesSectionState();
}

class FavoritesSectionState extends ConsumerState<FavoritesSection>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    // Charger les favoris au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final planRepository = ref.read(planRepositoryProvider);
      final result = await planRepository.getFavoritesByUserId(widget.userId);

      if (result is Ok<List<Plan>>) {
        // Charger aussi les catégories
        await _loadCategories();
      }
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categoryRepository = ref.read(categoryRepositoryProvider);
      final result = await categoryRepository.getCategoriesList();

      if (result is Ok<List<Category>>) {
        // Les catégories sont maintenant chargées
      }
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
    }
  }

  Future<List<Plan>> _getFavorites() async {
    final planRepository = ref.read(planRepositoryProvider);
    final result = await planRepository.getFavoritesByUserId(widget.userId);

    if (result is Ok<List<Plan>>) {
      return result.value;
    }
    return [];
  }

  Future<List<Category>> _getCategories() async {
    final categoryRepository = ref.read(categoryRepositoryProvider);
    final result = await categoryRepository.getCategoriesList();

    if (result is Ok<List<Category>>) {
      return result.value;
    }
    return [];
  }

  Future<Category?> _findCategoryForPlan(Plan plan) async {
    final categories = await _getCategories();
    if (categories.isEmpty) return null;
    try {
      return categories.firstWhere((c) => c.id == plan.category);
    } catch (e) {
      print('Catégorie non trouvée pour le plan: ${plan.id}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final displayLimit = ref.watch(favoritesDisplayLimitProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<Plan>>(
        future: _getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final allPlans = snapshot.data ?? [];

          if (allPlans.isEmpty) {
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

          final displayedPlans = allPlans.take(displayLimit).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: "Favoris",
                      subtitle:
                          "${allPlans.length} plan${allPlans.length > 1 ? 's' : ''} en favoris",
                      icon: Icons.favorite_rounded,
                      gradientColors: const [Colors.red, Colors.redAccent],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...displayedPlans.map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPlanCard(plan),
                  )),
              if (allPlans.length > displayLimit)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(favoritesDisplayLimitProvider.notifier).state +=
                          5;
                      final newLimit = ref.read(favoritesDisplayLimitProvider);
                      if (newLimit > allPlans.length) {
                        ref.read(favoritesDisplayLimitProvider.notifier).state =
                            allPlans.length;
                      }
                    },
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
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(Plan plan) {
    return Stack(
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: _getStepData(plan.steps),
          builder: (context, snapshot) {
            List<String>? imageUrls;
            double? cost;
            int? duration;

            if (snapshot.hasData) {
              final data = snapshot.data!;
              cost = data['cost'];
              duration = data['durationMinutes'];
              imageUrls = data['imageUrls'];
            }

            return FutureBuilder<Category?>(
              future: _findCategoryForPlan(plan),
              builder: (context, categorySnapshot) {
                final category = categorySnapshot.data;

                return CompactPlanCard(
                  title: plan.title,
                  description: plan.description,
                  imageUrls: imageUrls,
                  category: category,
                  stepsCount: plan.steps.length,
                  totalCost: cost,
                  totalDuration: duration,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/details',
                      arguments: plan.id,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                );
              },
            );
          },
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white, size: 20),
              onPressed: () async {
                final confirm =
                    await _showRemoveFavoriteConfirmation(context, plan);
                if (confirm == true) {
                  await _removeFavorite(plan.id!);
                }
              },
              tooltip: 'Retirer des favoris',
              constraints: BoxConstraints.tight(const Size(36, 36)),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _getStepData(List<String> stepIds) async {
    List<String> imageUrls = [];
    List<plan_steps.Step> steps = [];

    try {
      final stepRepository = ref.read(stepRepositoryProvider);

      for (final stepId in stepIds) {
        final stepResult = await stepRepository.getStepById(stepId);
        if (stepResult is Ok<plan_steps.Step>) {
          final step = stepResult.value;
          steps.add(step);

          if (step.image.isNotEmpty) {
            imageUrls.add(step.image);
          }
        }
      }

      // Calculer le coût total et la durée en minutes
      final totalCost = calculateTotalStepsCost(steps);
      final durationString = calculateTotalStepsDuration(steps);

      // Convertir la durée en minutes pour CompactPlanCard
      int durationMinutes = 0;
      try {
        // Utiliser la fonction helper pour parser la durée formatée
        durationMinutes = parseDurationStringToMinutes(durationString);
      } catch (e) {
        print('Erreur lors du parsing de la durée: $e');
        durationMinutes = 0;
      }

      return {
        'imageUrls': imageUrls,
        'cost': totalCost,
        'durationMinutes': durationMinutes,
      };
    } catch (e) {
      print('Erreur lors de la récupération des données des étapes: $e');
      return {
        'imageUrls': <String>[],
        'cost': 0.0,
        'durationMinutes': 0,
      };
    }
  }

  Future<bool?> _showRemoveFavoriteConfirmation(
      BuildContext context, Plan plan) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 70,
                width: 70,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.pink,
                    size: 36,
                  ),
                ),
              ),

              // Titre
              const Text(
                "Retirer des favoris ?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                "Voulez-vous vraiment retirer \"${plan.title}\" de vos favoris ?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.favorite_border,
                          size: 18, color: Colors.white),
                      label: const Text('Retirer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeFavorite(String planId) async {
    try {
      // Pour l'instant, simuler l'opération de suppression des favoris
      // Dans une vraie implémentation, il faudrait appeler un repository

      setState(() {
        // Déclencher un rebuild du widget pour recharger les favoris
      });

      if (widget.onFavoritesUpdated != null) {
        widget.onFavoritesUpdated!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Plan retiré des favoris'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors du retrait des favoris: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
