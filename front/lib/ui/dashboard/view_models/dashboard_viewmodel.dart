import 'package:flutter/material.dart';

import 'package:logging/logging.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/category/category_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../domain/models/category/category.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart' as step_model;
import '../../../domain/models/user/user.dart' show User;
import '../../../services/location_service.dart';
import '../../../utils/command.dart';
import '../../../utils/helpers.dart';
import '../../../utils/result.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required CategoryRepository categoryRepository,
    required AuthRepository authRepository,
    required PlanRepository planRepository,
    required LocationService locationService,
  })  : _categoryRepository = categoryRepository,
        _authRepository = authRepository,
        _planRepository = planRepository,
        _locationService = locationService {
    load = Command0(_load)..execute();
    logout = Command0(_logout);

    // Écouter les changements de position
    _locationService.addListener(_onLocationChanged);
  }

  // Repos
  final CategoryRepository _categoryRepository;
  final PlanRepository _planRepository;
  final AuthRepository _authRepository;
  final LocationService _locationService;
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
        _hasError = true;
        notifyListeners();
        return categoryResult;
      }

      if (planResult is Error<List<Plan>>) {
        _log.warning('Failed to load plans', planResult.error);
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
            plan.category != null &&
            plan.category!.id.isNotEmpty;
      }).toList();

      _log.fine(
          'Loaded ${_categories.length} categories & ${_plans.length} valid plans');
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

  // Getter pour accéder au service de localisation
  LocationService get locationService => _locationService;

  /// Obtient les plans avec leur distance calculée (moins de 10km)
  List<Plan> get nearbyPlans {
    if (_locationService.currentPosition == null) return [];

    const maxDistanceKm = 10.0; // Distance maximale en kilomètres
    const maxDistanceMeters = maxDistanceKm * 1000;

    // Calculer les distances et filtrer les plans à moins de 10km
    final plansWithDistance = _plans
        .map((plan) {
          final distance = _calculatePlanDistance(plan);
          return {
            'plan': plan,
            'distance': distance,
          };
        })
        .where((item) =>
            item['distance'] != null &&
            (item['distance'] as double) <= maxDistanceMeters)
        .toList();

    // Trier par distance croissante (du plus proche au plus loin)
    plansWithDistance.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    // Retourner les 10 premiers plans les plus proches
    return plansWithDistance
        .take(10)
        .map((item) => item['plan'] as Plan)
        .toList();
  }

  /// Calcule la distance pour un plan donné
  double? _calculatePlanDistance(Plan plan) {
    if (plan.steps.isEmpty) return null;

    // Utiliser la position du premier step comme référence
    final firstStep = plan.steps.first;
    if (firstStep.position == null) {
      return null;
    }

    final userPosition = _locationService.currentPosition;
    if (userPosition == null) return null;

    return calculateDistanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      firstStep.position!.latitude,
      firstStep.position!.longitude,
    );
  }

  /// Obtient la distance formatée pour un plan
  String getFormattedDistanceForPlan(Plan plan) {
    final distance = _calculatePlanDistance(plan);
    return formatDistance(distance);
  }

  void _onLocationChanged() {
    // Notifier les changements quand la position change
    notifyListeners();
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationChanged);
    super.dispose();
  }
}
