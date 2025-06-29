import 'package:front/application/session_manager.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:front/domain/models/user/user.dart';
import 'package:front/ui/core/base/base_viewmodel.dart';
import 'package:front/ui/core/state/list_state.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';
import 'dart:math' as math;

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel({
    required CategoryRepository categoryRepository,
    required UserRepository userRepository,
    required PlanRepository planRepository,
    required StepRepository stepRepository,
    required SessionManager sessionManager,
  })  : _categoryRepository = categoryRepository,
        _userRepository = userRepository,
        _planRepository = planRepository,
        _stepRepository = stepRepository,
        _sessionManager = sessionManager {
    load = Command0(_load);
    logout = Command0(_logout);
  }
  final CategoryRepository _categoryRepository;
  final PlanRepository _planRepository;
  final UserRepository _userRepository;
  final StepRepository _stepRepository;
  final SessionManager _sessionManager;
  final _log = Logger('DashboardViewModel');

  // Commands
  late Command0 load;
  late Command0 logout;

  // Search and filter state
  String searchQuery = '';
  Category? selectedCategory;
  String? sortBy;
  bool sortAscending = true;
  double? locationRadius;
  double? userLatitude;
  double? userLongitude;

  // Cache for performance
  final Map<String, String> _stepImageCache = {};
  final Map<String, List<step_model.Step>> _planSteps = {};

  // State management using the new unified approach
  ListState<Category> _categoriesState = ListState.initial();
  ListState<Plan> _plansState = ListState.initial();
  User? _user;

  // Getters for state
  ListState<Category> get categoriesState => _categoriesState;
  ListState<Plan> get plansState => _plansState;
  List<Category> get categories => _categoriesState.items;
  List<Plan> get plans => _plansState.items;
  Map<String, List<step_model.Step>> get planSteps => _planSteps;
  User? get user => _user;

  // Legacy compatibility getters
  bool get isLoading => _categoriesState.isLoading || _plansState.isLoading;
  bool get hasLoadedData =>
      !_categoriesState.isInitial && !_plansState.isInitial;
  Future<Result> _load() async {
    // Set categories and plans to loading state
    _categoriesState = ListState.loading();
    _plansState = ListState.loading();
    notifyListeners();

    try {
      _log.info('Loading dashboard data...');

      // Load user
      final userResult = await _userRepository.getCurrentUser();
      if (userResult is Ok<User>) {
        _user = userResult.value;
      }

      // Load categories
      final categoryResult = await _categoryRepository.getCategoriesList();
      if (categoryResult is Ok<List<Category>>) {
        _categoriesState = ListState.success(items: categoryResult.value);
      } else {
        _categoriesState = ListState.error('Failed to load categories');
        notifyListeners();
        return categoryResult;
      }

      // Load plans
      final planResult = await _planRepository.getPlanList();
      if (planResult is Ok<List<Plan>>) {
        _plansState = ListState.success(items: planResult.value);

        // Clear existing caches
        _planSteps.clear();
        _stepImageCache.clear();

        // Load steps for each plan
        for (final plan in planResult.value) {
          await _loadStepsForPlan(plan);
        }
      } else {
        _plansState = ListState.error('Failed to load plans');
        notifyListeners();
        return planResult;
      }

      notifyListeners();
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Unexpected error in load()', e, st);
      _categoriesState = ListState.error(e.toString());
      _plansState = ListState.error(e.toString());
      notifyListeners();
      return Result.error(Exception('Unexpected error: $e'));
    }
  }

  Future<void> _loadStepsForPlan(Plan plan) async {
    if (plan.id == null || _planSteps.containsKey(plan.id)) return;

    final List<step_model.Step> stepsList = [];
    for (final stepId in plan.steps) {
      final stepResult = await _stepRepository.getStepById(stepId);
      if (stepResult is Ok<step_model.Step>) {
        stepsList.add(stepResult.value);

        // Cache step image if available
        if (stepResult.value.image.isNotEmpty) {
          _stepImageCache[stepId] = stepResult.value.image;
        }
      }
    }
    _planSteps[plan.id!] = stepsList;
  }

  Future<Result> _logout() async {
    final result = await _sessionManager.logout();
    if (result case Ok()) {
      _user = null;
      _categoriesState = ListState.initial();
      _plansState = ListState.initial();
      _planSteps.clear();
      _stepImageCache.clear();
    }
    notifyListeners();
    return result;
  }

  Future<void> searchPlans() async {
    await load.execute();
  }

  List<Plan> getFilteredPlans() {
    final query = searchQuery.toLowerCase();
    var filteredPlans = plans.where((plan) {
      final matchText = plan.title.toLowerCase().contains(query) ||
          plan.description.toLowerCase().contains(query);
      final matchCategory = selectedCategory == null ||
          plan.category == selectedCategory!.id; // Location filtering
      bool matchLocation = true;
      if (locationRadius != null &&
          userLatitude != null &&
          userLongitude != null) {
        final steps = _planSteps[plan.id] ?? [];
        matchLocation = steps.any((step) {
          if (step.position != null) {
            final distance = _calculateDistance(userLatitude!, userLongitude!,
                step.position!.latitude, step.position!.longitude);
            return distance <= locationRadius!;
          }
          return false;
        });
      }

      return matchText && matchCategory && matchLocation;
    }).toList();

    // Apply sorting if specified
    if (sortBy != null) {
      filteredPlans.sort((a, b) {
        int comparison = 0;
        switch (sortBy) {
          case 'cost':
            final costA = calculatePlanTotalCost(a);
            final costB = calculatePlanTotalCost(b);
            comparison = costA.compareTo(costB);
            break;
          case 'duration':
            final durationA = calculatePlanTotalDuration(a);
            final durationB = calculatePlanTotalDuration(b);
            comparison = durationA.compareTo(durationB);
            break;
          case 'distance':
            final distanceA =
                calculateDistanceToFirstStep(a) ?? double.infinity;
            final distanceB =
                calculateDistanceToFirstStep(b) ?? double.infinity;
            comparison = distanceA.compareTo(distanceB);
            break;
          default:
            return 0;
        }

        return sortAscending ? comparison : -comparison;
      });
    }

    return filteredPlans;
  }

  double calculatePlanTotalCost(Plan plan) {
    final steps = _planSteps[plan.id] ?? [];
    return steps.fold(0.0, (sum, step) => sum + (step.cost ?? 0.0));
  }

  int calculatePlanTotalDuration(Plan plan) {
    final steps = _planSteps[plan.id] ?? [];
    int total = 0;
    final regex = RegExp(r'(\d+)\s*(minute|heure|jour|semaine)');

    for (final step in steps) {
      final match = regex.firstMatch(step.duration ?? '');
      if (match != null) {
        final value = int.tryParse(match.group(1)!);
        final unit = match.group(2);
        if (value != null && unit != null) {
          switch (unit) {
            case 'minute':
              total += value;
              break;
            case 'heure':
              total += value * 60;
              break;
            case 'jour':
              total += value * 8 * 60;
              break;
            case 'semaine':
              total += value * 5 * 8 * 60;
              break;
          }
        }
      }
    }

    return total;
  }

  String? getStepImageById(String stepId) => _stepImageCache[stepId];
  // Calculate distance to first step of a plan (returns null if no position data)
  double? calculateDistanceToFirstStep(Plan plan) {
    if (userLatitude == null || userLongitude == null) return null;

    final steps = _planSteps[plan.id] ?? [];
    if (steps.isEmpty) return null;

    final firstStep = steps.first;
    if (firstStep.position == null) return null;

    final distance = _calculateDistance(userLatitude!, userLongitude!,
        firstStep.position!.latitude, firstStep.position!.longitude);

    return distance;
  }

  // Debug method to check if steps have position data
  void debugStepPositions() {
    print('=== DEBUG: Step Positions ===');
    print('User location: lat=${userLatitude}, lon=${userLongitude}');

    for (final plan in plans.take(3)) {
      // Check first 3 plans
      final steps = _planSteps[plan.id] ?? [];
      print('Plan "${plan.title}":');
      for (int i = 0; i < steps.length && i < 2; i++) {
        // Check first 2 steps
        final step = steps[i];
        if (step.position != null) {
          print(
              '  Step $i: lat=${step.position!.latitude}, lon=${step.position!.longitude}');
          if (userLatitude != null && userLongitude != null) {
            final distance = _calculateDistance(userLatitude!, userLongitude!,
                step.position!.latitude, step.position!.longitude);
            print('  Distance: ${distance.toStringAsFixed(2)} km');
          }
        } else {
          print('  Step $i: NO POSITION DATA');
        }
      }
    }
    print('=== END DEBUG ===');
  }

  Future<Result<Category>> getCategoryById(String id) async {
    return await _categoryRepository.getCategoryById(id);
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
