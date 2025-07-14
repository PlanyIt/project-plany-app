import 'package:flutter/material.dart';
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

/// Association d'un Plan avec ses métriques calculées
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

/// ViewModel principal pour la recherche de plans
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

    // Écouter les changements de filtres pour relancer la recherche
    bool _isFilterListenerActive = false;
    filtersViewModel.addListener(() {
      if (_isFilterListenerActive) return;
      _isFilterListenerActive = true;
      search.execute();
      _isFilterListenerActive = false;
    });
  }

  final _log = Logger('SearchViewModel');
  final PlanRepository _planRepository;
  final CategoryRepository _categoryRepository;
  final LocationService _locationService;

  /// ViewModel pour la gestion des filtres
  final SearchFiltersViewModel filtersViewModel;

  /// ViewModel pour la gestion des chips (sera initialisé après le chargement des catégories)
  SearchChipsViewModel? chipsViewModel;

  /// Indicateurs d'état
  bool isLoading = false;
  bool isSearching = false;
  String? errorMessage;

  /// Données
  List<Plan> _allPlans = [];
  List<PlanWithMetrics> results = [];
  List<Category> _categories = [];

  /// Commandes
  late final Command0 load;
  late final Command0 search;

  /// Getters pour l'accès aux données
  List<Category> get fullCategories => _categories;

  /// Obtient le nom d'une catégorie par son ID
  String getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () =>
          Category(id: categoryId, name: categoryId, icon: '', color: ''),
    );
    return category.name;
  }

  /// Délégation vers les sous-ViewModels
  void setSearchQuery(String? query) => filtersViewModel.setSearchQuery(query);
  void setSelectedCategory(String? categoryId) =>
      filtersViewModel.setSelectedCategory(categoryId);

  /// Définit les filtres initiaux (utilisé lors de l'arrivée depuis le dashboard)
  void setInitialFilters({String? categoryId}) {
    if (categoryId != null && categoryId.isNotEmpty) {
      filtersViewModel.selectedCategory = categoryId;
    }
  }

  // Getters pour accéder aux filtres
  String? get searchQuery => filtersViewModel.searchQuery;
  String? get selectedCategory => filtersViewModel.selectedCategory;
  RangeValues? get distanceRange => filtersViewModel.distanceRange;
  RangeValues? get costRange => filtersViewModel.costRange;
  RangeValues? get durationRange => filtersViewModel.durationRange;
  int? get favoritesThreshold => filtersViewModel.favoritesThreshold;
  SortOption get sortBy => filtersViewModel.sortBy;

  // Délégation vers le chips ViewModel
  List<Map<String, dynamic>> getActiveFilters() =>
      chipsViewModel?.getActiveFilters() ?? [];
  bool get hasActiveFilters => chipsViewModel?.hasActiveFilters ?? false;
  int get activeFiltersCount => chipsViewModel?.activeFiltersCount ?? 0;
  void clearAllFilters() => filtersViewModel.clearAllFilters();

  // Délégation pour la validation et les valeurs temporaires
  void initializeTempValues() => filtersViewModel.initializeTempValues();
  bool applyTempFilters() => filtersViewModel.applyTempFilters();
  void resetTempValues() => filtersViewModel.resetTempValues();
  bool get hasTempValidationErrors => filtersViewModel.hasTempValidationErrors;
  String? getFieldError(String fieldName) =>
      filtersViewModel.getFieldError(fieldName);

  // Getters pour les valeurs temporaires
  RangeValues? get tempDistanceRange => filtersViewModel.tempDistanceRange;
  String? get tempSelectedCategory => filtersViewModel.tempSelectedCategory;
  String get tempMinCost => filtersViewModel.tempMinCost;
  String get tempMaxCost => filtersViewModel.tempMaxCost;
  String get tempMinDuration => filtersViewModel.tempMinDuration;
  String get tempMaxDuration => filtersViewModel.tempMaxDuration;
  String get tempDurationUnit => filtersViewModel.tempDurationUnit;
  int? get tempFavoritesThreshold => filtersViewModel.tempFavoritesThreshold;
  SortOption get tempSortBy => filtersViewModel.tempSortBy;

  // Méthodes pour mettre à jour les valeurs temporaires
  void updateTempDistanceRange(RangeValues? values) =>
      filtersViewModel.updateTempDistanceRange(values);
  void updateTempSelectedCategory(String? categoryId) =>
      filtersViewModel.updateTempSelectedCategory(categoryId);
  void updateTempCost({String? minCost, String? maxCost}) =>
      filtersViewModel.updateTempCost(minCost: minCost, maxCost: maxCost);
  void updateTempDuration({String? minDuration, String? maxDuration}) =>
      filtersViewModel.updateTempDuration(
          minDuration: minDuration, maxDuration: maxDuration);
  void updateTempDurationUnit(String unit) =>
      filtersViewModel.updateTempDurationUnit(unit);
  void updateTempFavoritesThreshold(int? threshold) =>
      filtersViewModel.updateTempFavoritesThreshold(threshold);
  void updateTempSortBy(SortOption sortOption) =>
      filtersViewModel.updateTempSortBy(sortOption);

  /// Charge catégories et plans
  Future<Result<void>> _load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Charger catégories
      final catRes = await _categoryRepository.getCategoriesList();
      if (catRes is Ok<List<Category>>) {
        _categories = catRes.value;

        // Initialiser le chips ViewModel maintenant que nous avons les catégories
        chipsViewModel = SearchChipsViewModel(
          filtersViewModel: filtersViewModel,
          categories: _categories,
        );
      } else {
        _log.warning(
            'Impossible de charger les catégories', (catRes as Error).error);
      }

      // Charger plans
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

  /// Applique filtres, catégorie et tris sur [_allPlans]
  Future<Result<void>> _search() async {
    isSearching = true;
    errorMessage = null;
    notifyListeners();

    final futures = _allPlans.map((plan) async {
      // Filtre catégorie
      if (filtersViewModel.selectedCategory != null &&
          plan.category?.id != filtersViewModel.selectedCategory) {
        return null;
      }

      // Filtre de recherche par texte
      if (filtersViewModel.searchQuery != null &&
          filtersViewModel.searchQuery!.isNotEmpty) {
        final query = filtersViewModel.searchQuery!.toLowerCase();
        bool matchesSearch = false;

        // Recherche dans le titre et description du plan
        if (plan.title.toLowerCase().contains(query) ||
            plan.description.toLowerCase().contains(query)) {
          matchesSearch = true;
        }

        // Recherche dans les étapes si pas encore trouvé
        if (!matchesSearch) {
          for (final step in plan.steps) {
            if (step.title.toLowerCase().contains(query) ||
                step.description.toLowerCase().contains(query)) {
              matchesSearch = true;
              break;
            }
          }
        }

        if (!matchesSearch) return null;
      }

      // Calculer la distance réelle au plan
      double totalDistance = 0;
      if (plan.steps.isNotEmpty) {
        final firstStep = plan.steps.first;
        if (firstStep.position != null) {
          final distanceInMeters = _locationService.calculateDistanceToPoint(
            firstStep.position!.latitude,
            firstStep.position!.longitude,
          );
          totalDistance = distanceInMeters ?? 0;
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

    // Appliquer filtres numériques
    final filtered = metricsList.where((m) {
      // Filtre distance
      if (filtersViewModel.distanceRange != null) {
        final range = filtersViewModel.distanceRange!;
        if (m.totalDistance < range.start || m.totalDistance > range.end) {
          return false;
        }
      }

      // Filtre coût avec support pour min ou max seul
      if (filtersViewModel.costRange != null) {
        final range = filtersViewModel.costRange!;
        // Seulement vérifier le minimum si ce n'est pas la valeur par défaut
        if (range.start > 0.0 && m.totalCost < range.start) {
          return false;
        }
        // Seulement vérifier le maximum si ce n'est pas la valeur par défaut
        if (range.end < 999999.0 && m.totalCost > range.end) {
          return false;
        }
      }

      // Filtre durée avec support pour min ou max seul
      if (filtersViewModel.durationRange != null) {
        final range = filtersViewModel.durationRange!;
        final durSec = m.totalDuration.inSeconds.toDouble();
        // Seulement vérifier le minimum si ce n'est pas la valeur par défaut
        if (range.start > 0.0 && durSec < range.start) {
          return false;
        }
        // Seulement vérifier le maximum si ce n'est pas la valeur par défaut
        if (range.end < (999999 * 60) && durSec > range.end) {
          return false;
        }
      }

      if (filtersViewModel.favoritesThreshold != null &&
          m.favoritesCount < filtersViewModel.favoritesThreshold!) {
        return false;
      }
      return true;
    }).toList();

    // Tri avec support pour la distance
    switch (filtersViewModel.sortBy) {
      case SortOption.cost:
        filtered.sort((a, b) => a.totalCost.compareTo(b.totalCost));
        break;
      case SortOption.duration:
        filtered.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
        break;
      case SortOption.favorites:
        filtered.sort((a, b) => b.favoritesCount.compareTo(a.favoritesCount));
        break;
      case SortOption.recent:
        filtered.sort((a, b) {
          final da = a.plan.createdAt;
          final db = b.plan.createdAt;
          if (da == null || db == null) return 0;
          return db.compareTo(da);
        });
        break;
    }

    results = filtered;
    _log.fine('Recherche terminée : ${results.length} plans trouvés');

    isSearching = false;
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  void dispose() {
    filtersViewModel.dispose();
    super.dispose();
  }
}
