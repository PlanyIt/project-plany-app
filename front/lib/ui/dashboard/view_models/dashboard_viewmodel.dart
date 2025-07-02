import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/category/category_repository.dart';
import '../../../domain/models/category/category.dart';
import '../../../utils/command.dart';

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
    load = Command0(_load);
    logout = Command0(_logout);
  }

  // Services & Repos
  final CategoryRepository _categoryRepository;
  final PlanRepository _planRepository;
  final AuthRepository _authRepository;
  final StepRepository _stepRepository;
  final Logger _log = Logger('DashboardViewModel');

  // UI State
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> locationError = ValueNotifier<String?>(null);

  // Data
  final List<Category> _categories = [];
  final List<Plan> _plans = [];
  final Map<String, List<step_model.Step>> _planSteps = {};
  final Map<String, String> _stepImageCache = {};
  User? _user;

  // Filters & sort
  String searchQuery = '';
  Category? selectedCategory;
  String? sortBy;
  bool sortAscending = true;
  double? locationRadius;
  double? userLatitude;
  double? userLongitude;

  // Search screen state
  String? _searchScreenSortBy;
  bool _searchScreenSortAsc = true;
  double _searchScreenLocationRadius = 10.0;
  bool _searchScreenUseLocation = false;

  // Commands
  late final Command0 load;
  late final Command0 logout;

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

  String? get searchScreenSortBy => _searchScreenSortBy;
  bool get searchScreenSortAsc => _searchScreenSortAsc;
  double get searchScreenLocationRadius => _searchScreenLocationRadius;
  bool get searchScreenUseLocation => _searchScreenUseLocation;
  bool get hasActiveFilters =>
      selectedCategory != null ||
      _searchScreenSortBy != null ||
      _searchScreenUseLocation;

  /// Consolidated loading workflow
  Future<Result<void>> _load() async {
    isLoading.value = true;
    notifyListeners();
    try {
      _log.info('Loading dashboard data');
      final catRes = await _loadCategories();
      if (catRes is Error) return catRes;

      final planRes = await _loadPlans();
      if (planRes is Error) return planRes;

      await _loadStepsForPlans();

      final userRes = await _loadUser();
      if (userRes is Error) return userRes;

      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Error in load', e, st);
      return Result.error(Exception('Unexpected error: $e'));
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<Result<void>> _loadCategories() async {
    final res = await _categoryRepository.getCategoriesList();
    if (res is Ok<List<Category>>) {
      _categories
        ..clear()
        ..addAll(res.value);
      return Result.ok(null);
    }
    return res;
  }

  Future<Result<void>> _loadPlans() async {
    final res = await _planRepository.getPlanList();
    if (res is Ok<List<Plan>>) {
      _plans
        ..clear()
        ..addAll(res.value);
      return Result.ok(null);
    }
    return res;
  }

  Future<void> _loadStepsForPlans() async {
    _planSteps.clear();
    _stepImageCache.clear();
    for (final plan in _plans) {
      final steps = <step_model.Step>[];
      for (final id in plan.steps) {
        final res = await _stepRepository.getStepById(id);
        if (res is Ok<step_model.Step>) {
          steps.add(res.value);
          if (res.value.image.isNotEmpty) {
            _stepImageCache[id] = res.value.image;
          }
        }
      }
      _planSteps[plan.id!] = steps;
    }
  }

  Future<Result<void>> _loadUser() async {
    final res = await _userRepository.getCurrentUser();
    if (res is Ok<User>) {
      _user = res.value;
      return Result.ok(null);
    }
    return res;
  }

  Future<Result<void>> _logout() async {
    final res = await _sessionManager.logout();
    if (res is Ok) {
      _user = null;
      _categories.clear();
      _plans.clear();
      _planSteps.clear();
      _stepImageCache.clear();
    }
    notifyListeners();
    return res;
  }

  /// Filtered & sorted plans
  List<Plan> getFilteredPlans() {
    final query = searchQuery.toLowerCase();
    var filtered = _plans.where((plan) {
      final textMatch = plan.title.toLowerCase().contains(query) ||
          plan.description.toLowerCase().contains(query);
      final catMatch =
          selectedCategory == null || plan.category == selectedCategory!.id;
      bool locMatch = true;
      if (locationRadius != null &&
          userLatitude != null &&
          userLongitude != null) {
        locMatch = calculateDistanceToFirstStepValue(plan) != null &&
            calculateDistanceToFirstStepValue(plan)! <= locationRadius!;
      }
      return textMatch && catMatch && locMatch;
    }).toList();

    if (sortBy != null) {
      filtered.sort((a, b) {
        double getValue(Plan p) {
          switch (sortBy) {
            case 'cost':
              return p.steps.fold(0.0,
                  (sum, id) => sum + (_stepImageCache[id] == null ? 0.0 : 0.0));
            case 'duration':
              return calculatePlanTotalDuration(p).toDouble();
            case 'distance':
              return calculateDistanceToFirstStepValue(p) ?? double.infinity;
            default:
              return 0;
          }
        }

        final cmp = getValue(a).compareTo(getValue(b));
        return sortAscending ? cmp : -cmp;
      });
    }
    return filtered;
  }

  double calculatePlanTotalCost(Plan plan) {
    final steps = _planSteps[plan.id] ?? [];
    return steps.fold(0.0, (sum, s) => sum + (s.cost ?? 0.0));
  }

  int calculatePlanTotalDuration(Plan plan) {
    final steps = _planSteps[plan.id] ?? [];
    int total = 0;
    final regex = RegExp(r'(\d+)\s*(minute|heure|jour|semaine)');
    for (final s in steps) {
      final m = regex.firstMatch(s.duration ?? '');
      if (m != null) {
        final val = int.tryParse(m.group(1)!)!;
        switch (m.group(2)) {
          case 'minute':
            total += val;
            break;
          case 'heure':
            total += val * 60;
            break;
          case 'jour':
            total += val * 8 * 60;
            break;
          case 'semaine':
            total += val * 5 * 8 * 60;
            break;
        }
      }
    }
    return total;
  }

  /// Returns distance in meters
  double? calculateDistanceToFirstStepValue(Plan plan) {
    if (userLatitude == null || userLongitude == null) return null;
    final steps = _planSteps[plan.id] ?? [];
    if (steps.isEmpty) return null;
    final pos = LatLng(
      steps.first.latitude ?? 0.0,
      steps.first.longitude ?? 0.0,
    );
    return calculateDistanceBetween(
        userLatitude!, userLongitude!, pos.latitude, pos.longitude);
  }

  /// Navigation helpers
  void openProfileDrawer(GlobalKey<ScaffoldState> key) {
    key.currentState?.openEndDrawer();
  }

  void goToCategorySearch(BuildContext ctx, Category cat) {
    selectedCategory = cat;
    load.execute();
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          viewModel: this,
          initialQuery: searchQuery,
          initialCategory: cat,
        ),
      ),
    );
  }

  void goToPlanDetail(BuildContext ctx, String planId) {
    GoRouter.of(ctx)
        .pushNamed('detailsPlan', queryParameters: {'planId': planId});
  }

  void initSearchScreen({String? initialQuery, Category? initialCategory}) {
    searchQuery = initialQuery ?? '';
    selectedCategory = initialCategory;
    _searchScreenSortBy = sortBy;
    _searchScreenSortAsc = sortAscending;
    _searchScreenLocationRadius = locationRadius ?? 10.0;
    _searchScreenUseLocation = locationRadius != null;
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void updateSort(String? sort, bool asc) {
    _searchScreenSortBy = sort;
    _searchScreenSortAsc = asc;
    notifyListeners();
  }

  void updateLocationFilter(bool useLoc, double radius) {
    _searchScreenUseLocation = useLoc;
    _searchScreenLocationRadius = radius;
    notifyListeners();
  }

  void applyFilters() {
    sortBy = _searchScreenSortBy;
    sortAscending = _searchScreenSortAsc;
    locationRadius =
        _searchScreenUseLocation ? _searchScreenLocationRadius : null;
    load.execute();
  }

  void resetFilters() {
    selectedCategory = null;
    _searchScreenSortBy = null;
    _searchScreenSortAsc = true;
    _searchScreenUseLocation = false;
    _searchScreenLocationRadius = 10.0;
    sortBy = null;
    sortAscending = true;
    locationRadius = null;
    notifyListeners();
    load.execute();
  }

  Future<void> getCurrentLocation() async {
    locationError.value = null;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Services de localisation désactivés');
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception('Permission de localisation refusée');
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      userLatitude = pos.latitude;
      userLongitude = pos.longitude;
      notifyListeners();
    } catch (e) {
      locationError.value = e.toString();
      _log.warning('Location error: $e');
    }
  }

  Future<Result<Category>> getCategoryById(String id) async {
    return _categoryRepository.getCategoryById(id);
  }
}
