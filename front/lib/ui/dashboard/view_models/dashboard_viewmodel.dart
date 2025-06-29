import 'package:flutter/material.dart';
import 'package:front/application/session_manager.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:front/domain/models/user/user.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';
import 'dart:math' as math;

class DashboardViewModel extends ChangeNotifier {
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

  final Map<String, String> _stepImageCache = {};
  final Map<String, List<step_model.Step>> _planSteps = {};

  List<Category> _categories = [];
  List<Plan> _plans = [];
  User? _user;
  String searchQuery = '';
  Category? selectedCategory;
  String? sortBy;
  bool sortAscending = true;
  double? locationRadius; // in kilometers
  double? userLatitude;
  double? userLongitude;

  late Command0 load;
  late Command0 logout;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Category> get categories => _categories;
  List<Plan> get plans => _plans;
  Map<String, List<step_model.Step>> get planSteps => _planSteps;
  User? get user => _user;

  bool get hasLoadedData =>
      _categories.isNotEmpty && _plans.isNotEmpty && _planSteps.isNotEmpty;

  Future<Result> _load() async {
    try {
      _log.info('Loading dashboard data...');
      _isLoading = true;
      notifyListeners();

      final categoryResult = await _categoryRepository.getCategoriesList();
      if (categoryResult case Ok(value: final cats)) {
        _categories = cats;
      } else {
        return categoryResult;
      }

      final planResult = await _planRepository.getPlanList();
      if (planResult case Ok(value: final plans)) {
        _plans = plans;
      } else {
        return planResult;
      }

      _planSteps.clear();
      _stepImageCache.clear();

      for (final plan in _plans) {
        final steps = <step_model.Step>[];
        for (final stepId in plan.steps) {
          final stepResult = await _stepRepository.getStepById(stepId);
          if (stepResult case Ok(value: final step)) {
            steps.add(step);
            if (step.image.isNotEmpty) _stepImageCache[stepId] = step.image;
          }
        }
        if (plan.id != null) _planSteps[plan.id!] = steps;
      }

      final userResult = await _userRepository.getCurrentUser();
      if (userResult case Ok(value: final usr)) {
        _user = usr;
      }

      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Unexpected error in load()', e, st);
      return Result.error(Exception('Unexpected error: $e'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Result> _logout() async {
    final result = await _sessionManager.logout();
    if (result case Ok()) {
      _user = null;
      _plans.clear();
      _categories.clear();
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

    for (final plan in _plans.take(3)) {
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
