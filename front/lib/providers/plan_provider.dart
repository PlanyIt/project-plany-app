import 'package:flutter/foundation.dart';
import '../domain/models/plan/plan.dart';
import '../domain/models/step/step.dart' as step_model;
import '../services/auth_service.dart';
import '../services/plan_service.dart';
import '../services/step_service.dart';

class PlanProvider extends ChangeNotifier {
  // Services
  final PlanService _planService = PlanService();
  final StepService _stepService = StepService();
  final AuthService _auth = AuthService();

  // Data
  List<Plan> _plans = [];
  Plan? _selectedPlan;
  List<step_model.Step> _selectedPlanSteps = [];

  // États
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Plan> get plans => _plans;
  Plan? get selectedPlan => _selectedPlan;
  List<step_model.Step> get selectedPlanSteps => _selectedPlanSteps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Récupérer tous les plans
  Future<void> fetchPlans() async {
    try {
      _setLoading(true);
      _setError(null);

      final fetchedPlans = await _planService.getPlans();
      _plans = fetchedPlans;

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la récupération des plans: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Récupérer un plan spécifique par ID
  Future<void> fetchPlanById(String planId) async {
    try {
      _setLoading(true);
      _setError(null);

      final plan = await _planService.getPlanById(planId);
      _selectedPlan = plan;

      // Récupérer les steps correspondants
      final steps = await _loadStepsForPlan(plan);
      _selectedPlanSteps = steps;

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la récupération du plan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<List<step_model.Step>> _loadStepsForPlan(Plan plan) async {
    final stepsList = <step_model.Step>[];

    for (final stepId in plan.steps) {
      try {
        final step = await _stepService.getStepById(stepId.id ?? '');
        if (step != null) {
          stepsList.add(step);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors du chargement du step $stepId: ${e.toString()}');
        }
      }
    }

    stepsList.sort((a, b) => a.order.compareTo(b.order));

    return stepsList;
  }

  Future<bool> deletePlan(String planId) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _planService.deletePlan(planId);
      if (success) {
        // Supprimer le plan de la liste locale
        _plans.removeWhere((plan) => plan.id == planId);
        notifyListeners();
        return true;
      } else {
        _setError('Échec de la suppression du plan');
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de la suppression du plan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Méthodes pour gérer l'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Obtenir les plans filtrés par catégorie
  List<Plan> getPlansByCategory(String category) {
    if (category == 'Tous') {
      return _plans;
    }
    return _plans.where((plan) => plan.category?.id == category).toList();
  }

  // Recherche de plans par texte
  List<Plan> searchPlans(String query) {
    if (query.isEmpty) {
      return _plans;
    }

    final lowercaseQuery = query.toLowerCase();
    return _plans.where((plan) {
      return plan.title.toLowerCase().contains(lowercaseQuery) ||
          plan.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Obtenir les plans créés par l'utilisateur courant
  Future<List<Plan>> get userPlans async {
    final userId = await _auth.getCurrentUserId();
    return _plans.where((plan) => plan.user!.id == userId).toList();
  }

  // Calcule le coût total d'un plan en additionnant les coûts de toutes les étapes
  Future<double> calculatePlanTotalCost(Plan plan) async {
    double totalCost = 0;
    try {
      final steps = await _loadStepsForPlan(plan);
      for (final step in steps) {
        if (step.cost != null) {
          totalCost += step.cost!;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du calcul du coût total: $e');
      }
    }
    return totalCost;
  }

  // Recherche avancée avec filtres de coût et durée
  Future<List<Plan>> searchPlansWithFilters({
    String? query,
    String? categoryId,
    double? minCost,
    double? maxCost,
    int? minDuration,
    int? maxDuration,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (kDebugMode) {
        print('Recherche via API avec:');
        print('  query: "$query"');
        print('  categoryId: $categoryId');
        print('  cost range: $minCost - $maxCost');
        print('  duration range: $minDuration - $maxDuration');
        print('  sortBy: $sortBy (${ascending ? 'asc' : 'desc'})');
      }

      // Récupérer les plans depuis l'API
      final plans = await _planService.searchPlans(
        query: query,
        category: categoryId,
        minCost: minCost,
        maxCost: maxCost,
        minDuration: minDuration,
        maxDuration: maxDuration,
        sortBy: sortBy,
        ascending: ascending,
      );

      if (kDebugMode) {
        print('API a retourné ${plans.length} plans');
      }

      // Appliquer un filtre de texte supplémentaire côté client si nécessaire
      var filteredPlans = plans;
      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        filteredPlans = plans.where((plan) {
          return plan.title.toLowerCase().contains(lowercaseQuery) ||
              plan.description.toLowerCase().contains(lowercaseQuery);
        }).toList();

        if (kDebugMode && filteredPlans.length != plans.length) {
          print(
              'Filtrage supplémentaire sur le client: ${plans.length} → ${filteredPlans.length} plans');
        }
      }

      // Si des filtres de coût sont spécifiés, appliquer un filtre supplémentaire côté client
      if (minCost != null || maxCost != null) {
        final costFilteredPlans = <Plan>[];

        // Parcourir tous les plans et vérifier si leur coût total correspond aux critères
        for (final plan in filteredPlans) {
          final totalCost = await calculatePlanTotalCost(plan);

          final passesMinCost = minCost == null || totalCost >= minCost;
          final passesMaxCost = maxCost == null || totalCost <= maxCost;

          if (passesMinCost && passesMaxCost) {
            costFilteredPlans.add(plan);
          }
        }

        filteredPlans = costFilteredPlans;
      }

      // Mise à jour de la liste principale des plans avec les résultats filtrés
      _plans = filteredPlans;
      notifyListeners();

      return filteredPlans;
    } catch (e) {
      _setError('Erreur lors de la recherche: ${e.toString()}');
      if (kDebugMode) {
        print('Search error: $e');
      }
      return [];
    } finally {
      _setLoading(false);
    }
  }
}
