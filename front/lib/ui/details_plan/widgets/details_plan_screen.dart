import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/ui/details_plan/widgets/content/plan_content.dart';
import 'package:front/ui/details_plan/widgets/header/details_header.dart';
import 'package:front/providers/providers.dart';

// Providers pour l'état du détail du plan
final detailsPlanProvider =
    StateNotifierProvider.family<DetailsPlanNotifier, DetailsPlanState, String>(
        (ref, planId) {
  return DetailsPlanNotifier(
    planRepository: ref.read(planRepositoryProvider),
    stepRepository: ref.read(stepRepositoryProvider),
    categoryRepository: ref.read(categoryRepositoryProvider),
  )..loadPlan(planId);
});

// Provider simple pour les opérations sur les étapes
final stepOperationsProvider = Provider((ref) {
  return StepOperations(
    stepRepository: ref.read(stepRepositoryProvider),
    categoryRepository: ref.read(categoryRepositoryProvider),
  );
});

class StepOperations {
  final dynamic stepRepository;
  final dynamic categoryRepository;

  StepOperations({
    required this.stepRepository,
    required this.categoryRepository,
  });

  Future<dynamic> getStepById(String stepId) async {
    final result = await stepRepository.getStepById(stepId);
    return result.isOk ? result.value : null;
  }

  // Méthodes factices pour maintenir la compatibilité
  Future<dynamic> getCurrentUserId() async => null;
  Future<dynamic> getUserProfile(String userId) async => null;
  Future<bool> isFollowing(String userId) async => false;
  Future<bool> followUser(String userId) async => false;
  Future<bool> unfollowUser(String userId) async => false;
  Future<void> addToFavorites(String planId) async {}
  Future<void> removeFromFavorites(String planId) async {}
  Map<String, double> get mapCenterPosition => {
        'latitude': 48.8566,
        'longitude': 2.3522,
      };

  // Propriétés pour la compatibilité avec l'interface attendue
  bool get isLoading => false;
  String? get error => null;
  dynamic get plan => null;
  List<dynamic> get steps => [];
  dynamic get category => null;
  Color get categoryColor => const Color(0xFF3425B5);
}

class DetailsPlanState {
  final bool isLoading;
  final String? error;
  final dynamic plan;
  final List<dynamic> steps;
  final dynamic category;
  final Color categoryColor;

  DetailsPlanState({
    this.isLoading = false,
    this.error,
    this.plan,
    this.steps = const [],
    this.category,
    this.categoryColor = const Color(0xFF3425B5),
  });

  DetailsPlanState copyWith({
    bool? isLoading,
    String? error,
    dynamic plan,
    List<dynamic>? steps,
    dynamic category,
    Color? categoryColor,
  }) {
    return DetailsPlanState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      plan: plan ?? this.plan,
      steps: steps ?? this.steps,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}

class DetailsPlanNotifier extends StateNotifier<DetailsPlanState> {
  final dynamic planRepository;
  final dynamic stepRepository;
  final dynamic categoryRepository;

  DetailsPlanNotifier({
    required this.planRepository,
    required this.stepRepository,
    required this.categoryRepository,
  }) : super(DetailsPlanState());

  Future<void> loadPlan(String planId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Charger le plan
      final planResult = await planRepository.getPlanById(planId);
      if (planResult.isOk) {
        final plan = planResult.value;

        // Charger les étapes
        final steps = <dynamic>[];
        for (final stepId in plan.steps) {
          final stepResult = await stepRepository.getStepById(stepId);
          if (stepResult.isOk) {
            steps.add(stepResult.value);
          }
        }

        // Charger la catégorie
        dynamic category;
        Color categoryColor = const Color(0xFF3425B5);

        if (plan.category.isNotEmpty) {
          final categoryResult =
              await categoryRepository.getCategoryById(plan.category);
          if (categoryResult.isOk) {
            category = categoryResult.value;
            // Calculer la couleur de la catégorie
            if (category.color.isNotEmpty) {
              try {
                String colorString = category.color;
                if (!colorString.startsWith('0x')) {
                  colorString = '0xFF$colorString';
                }
                categoryColor = Color(int.parse(colorString));
              } catch (e) {
                categoryColor = const Color(0xFF3425B5);
              }
            }
          }
        }

        state = state.copyWith(
          isLoading: false,
          plan: plan,
          steps: steps,
          category: category,
          categoryColor: categoryColor,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Plan non trouvé',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement: $e',
      );
    }
  }
}

class DetailScreen extends ConsumerStatefulWidget {
  final String planId;

  const DetailScreen({
    super.key,
    required this.planId,
  });

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailsState = ref.watch(detailsPlanProvider(widget.planId));

    if (detailsState.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(detailsState.categoryColor),
          ),
        ),
      );
    }

    if (detailsState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(detailsState.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(detailsPlanProvider(widget.planId).notifier)
                      .loadPlan(widget.planId);
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final plan = detailsState.plan;
    final steps = detailsState.steps;
    final category = detailsState.category;

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plan non trouvé')),
        body: const Center(
          child: Text('Ce plan n\'existe pas ou n\'est plus disponible'),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Carte en arrière-plan (plein écran)
          if (steps.isNotEmpty)
            DetailsHeader(
              stepIds: plan.steps,
              category: category?.name ?? 'Général',
              categoryColor: detailsState.categoryColor,
              planTitle: plan.title,
              planDescription: plan.description,
            ),

          // Contenu défilable par-dessus
          DraggableScrollableSheet(
            controller: _scrollController,
            initialChildSize: 0.4,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return PlanContent(
                plan: plan,
                categoryColor: detailsState.categoryColor,
                scrollController: scrollController,
                category: category,
                steps: steps as dynamic,
              );
            },
          ),
        ],
      ),
    );
  }
}
