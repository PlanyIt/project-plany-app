import 'package:flutter/material.dart';

import '../../../domain/models/category/category.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart' as plan_steps;
import '../../../services/categorie_service.dart';
import '../../../services/plan_service.dart';
import '../../../services/step_service.dart';

class PlanDetailViewModel extends ChangeNotifier {
  final PlanService _planService;
  final StepService _stepService;
  final CategorieService _categorieService;

  PlanDetailViewModel({
    required PlanService planService,
    required StepService stepService,
    required CategorieService categorieService,
  })  : _planService = planService,
        _stepService = stepService,
        _categorieService = categorieService;

  Plan? _plan;
  List<plan_steps.Step>? _steps;
  Category? _category;
  bool _isLoading = true;
  String? _error;

  Plan? get plan => _plan;
  List<plan_steps.Step>? get steps => _steps;
  Category? get category => _category;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPlanDetails(String planId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedPlan = await _planService.getPlanById(planId);
      _plan = fetchedPlan;
      await _loadCategory();

      final loadedSteps = <plan_steps.Step>[];
      for (final stepId in _plan!.steps) {
        try {
          final id = stepId is String ? stepId : stepId.id;
          final step = await _stepService.getStepById(id.toString());
          if (step != null) {
            loadedSteps.add(step);
          }
        } catch (e) {
          debugPrint("Erreur chargement étape: $e");
        }
      }
      _steps = loadedSteps;
    } catch (e) {
      _error = "Erreur lors du chargement des détails.";
      debugPrint("fetchPlanDetails: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCategory() async {
    if (_plan == null || _plan!.category?.id == null) return;
    try {
      final cat = await _categorieService.getCategoryById(_plan!.category!.id);
      _category = cat;
    } catch (e) {
      debugPrint("Erreur chargement catégorie: $e");
    }
  }

  Color get categoryColor {
    if (_plan == null || _category == null) return const Color(0xFF3425B5);
    return CategorieService.getColorFromHex(_category!.color);
  }
}
