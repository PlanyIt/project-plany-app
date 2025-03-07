import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front/models/plan.dart';
import 'package:front/models/step.dart' as StepModel;
import 'package:front/services/plan_service.dart';
import 'package:front/services/step_service.dart';

class PlanProvider extends ChangeNotifier {
  // Services
  final PlanService _planService = PlanService();
  final StepService _stepService = StepService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Data
  List<Plan> _plans = [];
  Plan? _selectedPlan;
  List<StepModel.Step> _selectedPlanSteps = [];

  // États
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Plan> get plans => _plans;
  Plan? get selectedPlan => _selectedPlan;
  List<StepModel.Step> get selectedPlanSteps => _selectedPlanSteps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Récupérer tous les plans
  Future<void> fetchPlans() async {
    try {
      _setLoading(true);
      _setError(null);

      // Récupérer les plans depuis l'API
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

      // Récupérer le plan et ses steps depuis l'API
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

  // Charger les steps pour un plan donné
  Future<List<StepModel.Step>> _loadStepsForPlan(Plan plan) async {
    final stepsList = <StepModel.Step>[];

    for (final stepId in plan.steps) {
      try {
        print(stepId);
        print("stepId");
        final step = await _stepService.getStepById(stepId);
        if (step != null) {
          stepsList.add(step);
        }
      } catch (e) {
        print('Erreur lors du chargement du step $stepId: ${e.toString()}');
      }
    }

    // Trier les steps par ordre
    stepsList.sort((a, b) => a.order.compareTo(b.order));

    return stepsList;
  }

  // Supprimer un plan
  Future<bool> deletePlan(String planId) async {
    try {
      _setLoading(true);

      // Vérifier que l'utilisateur est bien le propriétaire du plan
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _setError('Utilisateur non connecté');
        return false;
      }

      // Supprimer le plan
      await _planService.deletePlan(planId);

      // Mettre à jour la liste locale
      _plans.removeWhere((plan) => plan.id == planId);
      notifyListeners();

      return true;
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
    return _plans.where((plan) => plan.category == category).toList();
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
  List<Plan> get userPlans {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    return _plans.where((plan) => plan.userId == userId).toList();
  }
}
