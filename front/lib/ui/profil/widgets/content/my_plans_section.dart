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

// Providers pour l'état des plans de l'utilisateur
final myPlansProvider =
    StateProvider.family<List<Plan>, String>((ref, userId) => []);
final myPlansLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final myCategoriesProvider = StateProvider<List<Category>>((ref) => []);
final myPlansDisplayLimitProvider = StateProvider<int>((ref) => 5);

class MyPlansSection extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback? onPlansUpdated;

  const MyPlansSection({
    super.key,
    required this.userId,
    this.onPlansUpdated,
  });
  @override
  ConsumerState<MyPlansSection> createState() => MyPlansSectionState();
}

class MyPlansSectionState extends ConsumerState<MyPlansSection>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlans();
      _loadCategories();
    });
  }

  Future<void> _loadPlans() async {
    ref.read(myPlansLoadingProvider(widget.userId).notifier).state = true;

    try {
      final planRepository = ref.read(planRepositoryProvider);
      final result = await planRepository.getPlansByUserId(widget.userId);

      if (result is Ok<List<Plan>>) {
        ref.read(myPlansProvider(widget.userId).notifier).state = result.value;
      }
    } catch (e) {
      print('Erreur lors du chargement des plans: $e');
    } finally {
      if (mounted) {
        ref.read(myPlansLoadingProvider(widget.userId).notifier).state = false;
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categoryRepository = ref.read(categoryRepositoryProvider);
      final result = await categoryRepository.getCategoriesList();

      if (result is Ok<List<Category>>) {
        ref.read(myCategoriesProvider.notifier).state = result.value;
      }
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
    }
  }

  Category? _findCategoryForPlan(Plan plan) {
    final categories = ref.read(myCategoriesProvider);
    if (categories.isEmpty) return null;
    try {
      return categories.firstWhere((c) => c.id == plan.category);
    } catch (e) {
      print('Catégorie non trouvée pour le plan: ${plan.id}');
      return null;
    }
  }

  Future<void> _deletePlan(String planId) async {
    try {
      final planRepository = ref.read(planRepositoryProvider);
      final result = await planRepository.deletePlan(planId);

      if (result is Ok<bool> && result.value) {
        // Recharger les plans
        await _loadPlans();

        if (widget.onPlansUpdated != null) {
          widget.onPlansUpdated!();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Plan supprimé avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la suppression du plan: $e');
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
  Widget build(BuildContext context) {
    super.build(context);
    final plans = ref.watch(myPlansProvider(widget.userId));
    final isLoading = ref.watch(myPlansLoadingProvider(widget.userId));
    final displayLimit = ref.watch(myPlansDisplayLimitProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun plan créé',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: "Plans Créés",
                            subtitle:
                                "${plans.length} plan${plans.length > 1 ? 's' : ''} créé${plans.length > 1 ? 's' : ''}",
                            icon: Icons.map_rounded,
                            gradientColors: const [
                              Colors.purple,
                              Colors.purpleAccent
                            ],
                            action: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(10),
                              child: Tooltip(
                                message: 'Créer un nouveau plan',
                                child: Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.purple,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...plans.take(displayLimit).map((plan) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildPlanCard(plan),
                        )),
                    if (plans.length > displayLimit)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            final newLimit = displayLimit + 5;
                            final finalLimit = newLimit > plans.length
                                ? plans.length
                                : newLimit;
                            ref
                                .read(myPlansDisplayLimitProvider.notifier)
                                .state = finalLimit;
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
                Navigator.pushNamed(context, '/details', arguments: plan.id);
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
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.white, size: 20),
              onPressed: () async {
                final confirm = await _showDeleteConfirmation(context, plan);
                if (confirm == true) {
                  await _deletePlan(plan.id!);
                }
              },
              tooltip: 'Supprimer ce plan',
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

  @override
  bool get wantKeepAlive => true;

  Future<bool?> _showDeleteConfirmation(BuildContext context, Plan plan) async {
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
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
              ),

              // Titre
              const Text(
                "Supprimer ce plan ?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                "Le plan \"${plan.title}\" sera définitivement supprimé. Cette action est irréversible.",
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
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.delete_forever,
                          size: 18, color: Colors.white),
                      label: const Text('Supprimer'),
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
}
