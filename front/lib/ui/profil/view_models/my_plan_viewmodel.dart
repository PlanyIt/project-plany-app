import 'package:flutter/material.dart';

import '../../../data/repositories/plan/plan_repository.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../utils/result.dart';

class MyPlansViewModel extends ChangeNotifier {
  final PlanRepository planRepository;

  MyPlansViewModel({required this.planRepository});

  List<Plan> _plans = [];
  bool isLoading = true;
  int displayLimit = 5;

  List<Plan> get displayedPlans => _plans.take(displayLimit).toList();
  int get totalPlans => _plans.length;

  Future<void> loadPlans(String userId) async {
    isLoading = true;
    notifyListeners();

    final result = await planRepository.getPlansByUser(userId);
    if (result is Ok<List<Plan>>) {
      _plans = result.value;
    } else {
      _plans = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void showMore() {
    displayLimit += 5;
    notifyListeners();
  }

  Future<void> deletePlan(String planId) async {
    final result = await planRepository.deletePlan(planId);
    if (result is Ok<void>) {
      _plans.removeWhere((p) => p.id == planId);
      notifyListeners();
    }
  }
}
