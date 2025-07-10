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

  // État de l'UI
  String? _errorMessage;
  bool _hasError = false;

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

  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  void clearError() {
    _errorMessage = null;
    _hasError = false;
    notifyListeners();
  }

  void navigateToSearch({String query = '', String category = ''}) {
    // Émettre un événement pour la navigation
    _navigationEvent = NavigationEvent.search(query: query, category: category);
    notifyListeners();
  }

  void navigateToPlan(String planId) {
    _navigationEvent = NavigationEvent.plan(planId);
    notifyListeners();
  }

  NavigationEvent? _navigationEvent;
  NavigationEvent? get navigationEvent => _navigationEvent;

  void clearNavigationEvent() {
    _navigationEvent = null;
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    _categories = [];
    _plans = [];
    _planSteps.clear();
    _hasError = false;
    _errorMessage = null;

    // Charger l'utilisateur
    await _loadCurrentUser();
    notifyListeners();

    try {
      final results = await Future.wait([
        _categoryRepository.getCategoriesList(),
        _planRepository.getPlanList(),
      ]);

      final categoryResult = results[0] as Result<List<Category>>;
      final planResult = results[1] as Result<List<Plan>>;

      if (categoryResult is Error<List<Category>>) {
        _log.warning('Failed to load categories', categoryResult.error);
        _errorMessage = 'Erreur lors du chargement des catégories';
        _hasError = true;
        notifyListeners();
        return categoryResult;
      }

      if (planResult is Error<List<Plan>>) {
        _log.warning('Failed to load plans', planResult.error);
        _errorMessage = 'Erreur lors du chargement des plans';
        _hasError = true;
        notifyListeners();
        return planResult;
      }

      _categories = (categoryResult as Ok).value;
      // Filter out plans with null or invalid data
      final allPlans = (planResult as Ok).value;
      _plans = allPlans.where((plan) {
        return plan.title.isNotEmpty &&
            plan.description.isNotEmpty &&
            plan.category.isNotEmpty;
      }).toList();

      _log.fine(
          'Loaded ${_categories.length} categories & ${_plans.length} valid plans');

      await _loadStepsForPlans();
      _log.info('Dashboard data loaded successfully');
      notifyListeners();
      return const Result.ok(null);
    } catch (e, stackTrace) {
      _log.severe('Unexpected error loading dashboard data', e, stackTrace);
      _errorMessage =
          'Une erreur inattendue s\'est produite lors du chargement';
      _hasError = true;
      notifyListeners();
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Utiliser le AuthRepository pour récupérer l'utilisateur courant
      _user = _authRepository.currentUser;

      // Si pas d'utilisateur en cache, essayer de le recharger
      if (_user == null) {
        final userResult = await _authRepository.getCurrentUser();
        if (userResult is Ok<User>) {
          _user = userResult.value;
        }
      }

      _log.info('Current user loaded: ${_user?.username ?? "null"}');
    } catch (e) {
      _log.warning('Failed to load current user', e);
    }
  }

  Future<void> _loadStepsForPlans() async {
    if (_plans.isEmpty) {
      _log.warning('No plans found, skipping step loading');
      return;
    }

    final futures = _plans.where((plan) => plan.id != null).map((plan) async {
      final id = plan.id!;
      final result = await _stepRepository.getStepsList(id);
      if (result is Ok<List<step_model.Step>>) {
        _planSteps[id] = result.value;
      } else {
        _log.warning('Failed to load steps for plan $id',
            (result as Error<List<step_model.Step>>).error);
      }
    });

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
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

// Classe pour gérer les événements de navigation
class NavigationEvent {
  final String type;
  final Map<String, dynamic> data;

  NavigationEvent._(this.type, this.data);

  factory NavigationEvent.search({String query = '', String category = ''}) {
    return NavigationEvent._('search', {'query': query, 'category': category});
  }

  factory NavigationEvent.plan(String planId) {
    return NavigationEvent._('plan', {'planId': planId});
  }
}
