import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import '../../../data/repositories/category/category_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../domain/models/category/category.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import 'search_chips_view_model.dart';
import 'search_filters_view_model.dart';

class PlanWithMetrics {
  final Plan plan;
  final double totalDistance;
  final double totalCost;
  final Duration totalDuration;
  final int favoritesCount;

  PlanWithMetrics({
    required this.plan,
    required this.totalDistance,
    required this.totalCost,
    required this.totalDuration,
    required this.favoritesCount,
  });
}

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required PlanRepository planRepository,
    required CategoryRepository categoryRepository,
  })  : _planRepository = planRepository,
        _categoryRepository = categoryRepository,
        _locationService = LocationService(),
        filtersViewModel = SearchFiltersViewModel() {
    load = Command0(_load)..execute();
    search = Command0(_search);

    filtersViewModel.addListener(() {
      search.execute();
    });
  }

  final _log = Logger('SearchViewModel');
  final PlanRepository _planRepository;
  final CategoryRepository _categoryRepository;
  final LocationService _locationService;

  final SearchFiltersViewModel filtersViewModel;
  SearchChipsViewModel? chipsViewModel;

  bool isLoading = false;
  bool isSearching = false;
  String? errorMessage;

  List<Plan> _allPlans = [];
  List<PlanWithMetrics> results = [];
  List<Category> _categories = [];

  late final Command0 load;
  late final Command0 search;

  List<Map<String, dynamic>> getActiveFilters() {
    return chipsViewModel?.getActiveFilters() ?? [];
  }

  bool get hasActiveFilters => chipsViewModel?.hasActiveFilters ?? false;

  int get activeFiltersCount => chipsViewModel?.activeFiltersCount ?? 0;

  List<Category> get fullCategories => _categories;
  String? getFieldError(String fieldName) {
    return filtersViewModel.getFieldError(fieldName);
  }

  Future<void> initializeWithCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) return;

    final selectedLocation = LatLng(position.latitude, position.longitude);
    final addressName = await _locationService.reverseGeocode(selectedLocation);

    filtersViewModel.setSelectedLocationWithDefaultDistance(
      selectedLocation,
      addressName ?? 'Ma position actuelle',
    );

    search.execute();
  }

  Future<Result<void>> _load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final catRes = await _categoryRepository.getCategoriesList();
      if (catRes is Ok<List<Category>>) {
        _categories = catRes.value;
        chipsViewModel = SearchChipsViewModel(
          filtersViewModel: filtersViewModel,
          categories: _categories,
        );
      } else {
        _log.warning(
            'Impossible de charger les catégories', (catRes as Error).error);
      }

      final res = await _planRepository.getPlanList();
      if (res is Error) {
        errorMessage = (res).toString();
        _log.warning('Échec du chargement des plans', res);
        return res;
      }

      _allPlans = (res as Ok<List<Plan>>).value;
      _log.fine('Plans chargés : ${_allPlans.length}');

      final searchRes = await _search();
      return searchRes;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Result<void>> _search() async {
    isSearching = true;
    errorMessage = null;
    notifyListeners();

    final futures = _allPlans.map((plan) async {
      if (filtersViewModel.selectedCategory != null &&
          plan.category?.id != filtersViewModel.selectedCategory) {
        return null;
      }

      if (filtersViewModel.keywordQuery != null &&
          filtersViewModel.keywordQuery!.isNotEmpty) {
        final query = filtersViewModel.keywordQuery!.toLowerCase();
        final matchesSearch = _matchesQuery(plan, query);
        if (!matchesSearch) return null;
      }

      double totalDistance = 0;
      if (plan.steps.isNotEmpty) {
        final firstStep = plan.steps.first;
        if (firstStep.position != null) {
          final selectedLocation = filtersViewModel.selectedLocation;
          if (selectedLocation != null) {
            totalDistance = const Distance().as(
              LengthUnit.Meter,
              LatLng(
                  firstStep.position!.latitude, firstStep.position!.longitude),
              selectedLocation,
            );
          } else {
            totalDistance = _locationService.calculateDistanceToPoint(
                  firstStep.position!.latitude,
                  firstStep.position!.longitude,
                ) ??
                0;
          }
        }
      }

      return PlanWithMetrics(
        plan: plan,
        totalDistance: totalDistance,
        totalCost: plan.totalCost ?? 0,
        totalDuration: Duration(minutes: plan.totalDuration ?? 0),
        favoritesCount: plan.favorites?.length ?? 0,
      );
    }).toList();

    final metricsList =
        (await Future.wait(futures)).whereType<PlanWithMetrics>().toList();
    final filtered = _applyFilters(metricsList);

    results = filtered;
    isSearching = false;
    notifyListeners();
    return const Result.ok(null);
  }

  bool _matchesQuery(Plan plan, String query) {
    if (plan.title.toLowerCase().contains(query) ||
        plan.description.toLowerCase().contains(query)) {
      return true;
    }
    for (final step in plan.steps) {
      if (step.title.toLowerCase().contains(query) ||
          step.description.toLowerCase().contains(query)) {
        return true;
      }
    }
    return false;
  }

  List<PlanWithMetrics> _applyFilters(List<PlanWithMetrics> metricsList) {
    return metricsList.where((m) {
      final distanceRange = filtersViewModel.effectiveDistanceRange;
      if (distanceRange != null &&
          (m.totalDistance < distanceRange.start ||
              m.totalDistance > distanceRange.end)) {
        return false;
      }

      final costRange = filtersViewModel.costRange;
      if (costRange != null &&
          ((costRange.start > 0.0 && m.totalCost < costRange.start) ||
              (costRange.end < 999999.0 && m.totalCost > costRange.end))) {
        return false;
      }

      final durationRange = filtersViewModel.durationRange;
      if (durationRange != null) {
        final durSec = m.totalDuration.inSeconds.toDouble();
        if ((durationRange.start > 0.0 && durSec < durationRange.start) ||
            (durationRange.end < (999999 * 60) && durSec > durationRange.end)) {
          return false;
        }
      }

      if (filtersViewModel.favoritesThreshold != null &&
          m.favoritesCount < filtersViewModel.favoritesThreshold!) {
        return false;
      }

      if (filtersViewModel.pmrOnly == true && m.plan.isAccessible != true) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (filtersViewModel.sortBy) {
          case SortOption.cost:
            return a.totalCost.compareTo(b.totalCost);
          case SortOption.duration:
            return a.totalDuration.compareTo(b.totalDuration);
          case SortOption.favorites:
            return b.favoritesCount.compareTo(a.favoritesCount);
          case SortOption.recent:
            final da = a.plan.createdAt;
            final db = b.plan.createdAt;
            return (da == null || db == null) ? 0 : db.compareTo(da);
        }
      });
  }

  void clearAllFilters() {
    filtersViewModel.clearAllFilters();
    search.execute();
  }

  @override
  void dispose() {
    filtersViewModel.dispose();
    super.dispose();
  }
}
