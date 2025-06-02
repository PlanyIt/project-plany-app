import 'package:flutter/material.dart';
import 'package:front/models/category.dart';
import 'package:front/models/plan.dart';
import 'package:front/models/step.dart' as plan_steps;
import 'package:front/screens/profile/widgets/common/section_header.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/services/user_service.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/utils/helpers.dart';
import 'package:front/widgets/card/compact_plan_card.dart';

class FavoritesSection extends StatefulWidget {
  final String userId;
  final VoidCallback? onFavoritesUpdated;

  const FavoritesSection({
    super.key,
    required this.userId,
    this.onFavoritesUpdated,
  });

  @override
  _FavoritesSectionState createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection>
    with AutomaticKeepAliveClientMixin {
  final UserService _userService = UserService();
  final StepService _stepService = StepService();
  final CategorieService _categorieService = CategorieService();

  late Future<List<Plan>> _favoritesFuture;
  int _displayLimit = 5;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _userService.getUserFavoritePlans(widget.userId);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _categorieService.getCategories();
      setState(() {});
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
    }
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _userService.getUserFavoritePlans(widget.userId);
    });
  }

  Category? _findCategoryForPlan(Plan plan) {
    if (_categories.isEmpty) return null;
    try {
      return _categories.firstWhere((c) => c.id == plan.category);
    } catch (e) {
      print('Catégorie non trouvée pour le plan: ${plan.id}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<Plan>>(
        future: _favoritesFuture,
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
                    onPressed: _refreshFavorites,
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
                  Text(
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

          final displayedPlans = allPlans.take(_displayLimit).toList();

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
              if (allPlans.length > _displayLimit)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _displayLimit += 5;
                        if (_displayLimit > allPlans.length) {
                          _displayLimit = allPlans.length;
                        }
                      });
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

            final category = _findCategoryForPlan(plan);

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
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
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
      for (final stepId in stepIds) {
        final step = await _stepService.getStepById(stepId);
        if (step != null) {
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
      if (durationString.contains('heure')) {
        final parts = durationString.split(' ');
        if (parts.length >= 3) {
          durationMinutes = int.parse(parts[0]) * 60;
          if (parts.length >= 4) {
            durationMinutes += int.parse(parts[2]);
          }
        }
      } else if (durationString.contains('minute')) {
        final parts = durationString.split(' ');
        if (parts.length >= 2) {
          durationMinutes = int.parse(parts[0]);
        }
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
                color: Colors.black.withOpacity(0.1),
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
                  color: Colors.pink.withOpacity(0.1),
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
      final planService = PlanService();
      await planService.removeFromFavorites(planId);

      setState(() {
        _favoritesFuture = _userService.getUserFavoritePlans(widget.userId);
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
