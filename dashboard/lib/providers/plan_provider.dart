import 'package:flutter/foundation.dart';
import 'package:dashboard/models/plan.dart';
import 'package:dashboard/services/plan_service.dart';

class PlanProvider extends ChangeNotifier {
  final PlanService _planService = PlanService();

  List<Plan> _plans = [];
  Plan? _selectedPlan;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _planStats;

  List<Plan> get plans => _plans;
  Plan? get selectedPlan => _selectedPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get planStats => _planStats;

  Future<void> fetchPlans() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fetchedPlans = await _planService.getPlans();
      _plans = fetchedPlans;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchPlanById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final plan = await _planService.getPlanById(id);
      _selectedPlan = plan;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchPlansByCategory(String categoryId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final plans = await _planService.getPlansByCategory(categoryId);
      _plans = plans;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchPlansByUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final plans = await _planService.getPlansByUser(userId);
      _plans = plans;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updatePlan(String id, Plan plan) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedPlan = await _planService.updatePlan(id, plan);

      // Update the plan in the list
      final index = _plans.indexWhere((p) => p.id == id);
      if (index != -1) {
        _plans[index] = updatedPlan;
      }

      if (_selectedPlan?.id == id) {
        _selectedPlan = updatedPlan;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlan(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _planService.deletePlan(id);

      // Remove the plan from the list
      _plans.removeWhere((p) => p.id == id);

      if (_selectedPlan?.id == id) {
        _selectedPlan = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchPlanStats() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _planStats = await _planService.getPlanStats();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setSelectedPlan(Plan? plan) {
    _selectedPlan = plan;
    notifyListeners();
  }
}
