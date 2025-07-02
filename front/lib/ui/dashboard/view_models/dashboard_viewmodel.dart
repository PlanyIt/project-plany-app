import 'package:flutter/material.dart';

import 'package:logging/logging.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/category/category_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/repositories/step/step_repository.dart';
import '../../../domain/models/category/category.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart' as step_model;
import '../../../domain/models/user/user.dart' show User;
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required CategoryRepository categoryRepository,
    required AuthRepository authRepository,
    required PlanRepository planRepository,
    required StepRepository stepRepository,
  })  : _categoryRepository = categoryRepository,
        _authRepository = authRepository,
        _planRepository = planRepository,
        _stepRepository = stepRepository {
    load = Command0(_load)..execute();
    logout = Command0(_logout);
  }

  // Repos
  final CategoryRepository _categoryRepository;
  final PlanRepository _planRepository;
  final AuthRepository _authRepository;
  final StepRepository _stepRepository;
  final Logger _log = Logger('DashboardViewModel');

  // Data
  List<Category> _categories = [];
  List<Plan> _plans = [];
  final Map<String, List<step_model.Step>> _planSteps = {};
  User? _user;

  // Commands
  late Command0 load;
  late Command0 logout;

  // Public getters
  List<Category> get categories => _categories;
  List<Plan> get plans => _plans;
  Map<String, List<step_model.Step>> get planSteps => _planSteps;
  User? get user => _user;
  bool get hasLoadedData => _categories.isNotEmpty && _plans.isNotEmpty;
  List<Plan> get trendingPlans => _plans.take(5).toList();
  List<Plan> get discoveryPlans {
    final copy = List<Plan>.from(_plans)..shuffle();
    return copy;
  }

  Future<Result<void>> _load() async {
    _categories = [];
    _plans = [];
    _planSteps.clear();
    notifyListeners();
    try {
      _user = _authRepository.currentUser;
      // Lance les deux fetch en parallèle
      final results = await Future.wait([
        _categoryRepository.getCategoriesList(),
        _planRepository.getPlanList(),
      ]);
      final categoryResult = results[0] as Result<List<Category>>;
      final planResult = results[1] as Result<List<Plan>>;

      if (categoryResult is Error<List<Category>>) {
        _log.warning('Failed to load categories', categoryResult.error);
        return categoryResult;
      }
      if (planResult is Error<List<Plan>>) {
        _log.warning('Failed to load plans', planResult.error);
        return planResult;
      }

      _categories = (categoryResult as Ok).value;
      _plans = (planResult as Ok).value;
      _log.fine('Loaded categories & plans');

      await _loadStepsForPlans();
      _log.info('Dashboard data loaded successfully');
      return const Result.ok(null);
    } finally {
      notifyListeners(); // Ensure listeners are notified after loading completes
    }
  }

  Future<void> _loadStepsForPlans() async {
    if (_plans.isEmpty) {
      _log.warning('No plans found, skipping step loading');
      return;
    }
    final futures = _plans.map((plan) async {
      final id = plan.id;
      if (id == null) {
        _log.warning('Plan without id: $plan');
        return;
      }
      final result = await _stepRepository.getStepsList(id);
      if (result is Ok<List<step_model.Step>>) {
        _planSteps[id] = result.value;
      } else {
        _log.warning(
            'Failed to load steps for plan $id', (result as Error).error);
      }
    });
    await Future.wait(futures);
  }

  Future<Result<Category>> getCategoryById(String id) async {
    return _categoryRepository.getCategory(id);
  }

  Future<Result> _logout() async {
    final result = await _authRepository.logout();
    switch (result) {
      case Ok<void>():
      case Error<void>():
        return result;
    }
  }
}
