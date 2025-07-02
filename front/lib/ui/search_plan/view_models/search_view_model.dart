import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

import '../../../data/repositories/category/category_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/repositories/step/step_repository.dart';
import '../../../domain/models/category/category.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart' as step_model;
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Critères de tri disponibles
enum SortOption { distance, cost, duration, favorites, recent }

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

/// ViewModel pour la recherche de plans
class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required PlanRepository planRepository,
    required StepRepository stepRepository,
    required CategoryRepository categoryRepository,
  })  : _planRepository = planRepository,
        _stepRepository = stepRepository,
        _categoryRepository = categoryRepository {
    load = Command0(_load)..execute();
    search = Command0(_search);
  }

  final _log = Logger('SearchViewModel');
  final PlanRepository _planRepository;
  final StepRepository _stepRepository;
  final CategoryRepository _categoryRepository;

  /// Indicateur de chargement initial
  bool isLoading = false;

  /// Indicateur de recherche en cours
  bool isSearching = false;

  /// Éventuelle erreur
  String? errorMessage;

  /// Liste brute de tous les plans
  List<Plan> _allPlans = [];

  /// Résultats après application des filtres / tris
  List<PlanWithMetrics> results = [];

  /// Liste des catégories disponibles
  List<String> categories = [];

  /// Catégorie sélectionnée, null = toutes
  String? selectedCategory;

  // --- filtres sélectionnés ---
  RangeValues? distanceRange; // en mètres
  RangeValues? costRange; // unités monétaires
  RangeValues? durationRange; // en secondes
  int? favoritesThreshold; // nb minimum de favoris
  SortOption sortBy = SortOption.recent;

  /// Commandes
  late final Command0 load;
  late final Command0 search;

  /// Charge catégories et plans
  Future<Result<void>> _load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // Charger catégories
    final catRes = await _categoryRepository.getCategoriesList();
    if (catRes is Ok<List<Category>>) {
      categories = catRes.value.map((c) => c.id).toList();
    } else {
      _log.warning(
          'Impossible de charger les catégories', (catRes as Error).error);
    }

    // Charger plans
    final res = await _planRepository.getPlanList();
    if (res is Error) {
      errorMessage = (res).toString();
      _log.warning('Échec du chargement des plans', res);
      isLoading = false;
      notifyListeners();
      return res;
    }

    _allPlans = (res as Ok<List<Plan>>).value;
    _log.fine('Plans chargés : ${_allPlans.length}');

    final searchRes = await _search();

    isLoading = false;
    notifyListeners();
    return searchRes;
  }

  /// Applique filtres, catégorie et tris sur [_allPlans]
  Future<Result<void>> _search() async {
    isSearching = true;
    errorMessage = null;
    notifyListeners();

    var hadError = false;
    final distance = Distance();

    final futures = _allPlans.map((plan) async {
      // Filtre catégorie
      if (selectedCategory != null && plan.category != selectedCategory) {
        return null;
      }

      final stepRes = await _stepRepository.getStepsList(plan.id!);
      if (stepRes is Error) {
        hadError = true;
        _log.warning('Échec chargement steps pour plan ${plan.id}', (stepRes));
        return null;
      }
      final steps = (stepRes as Ok<List<step_model.Step>>).value;

      // Calcul métriques
      double totalDist = 0;
      for (var i = 1; i < steps.length; i++) {
        final p1 = steps[i - 1].position;
        final p2 = steps[i].position;
        if (p1 != null && p2 != null) {
          totalDist += distance.as(LengthUnit.Meter, p1, p2);
        }
      }
      final totalCost = steps.fold<double>(0, (sum, s) => sum + (s.cost ?? 0));
      final totalDuration = steps.fold<Duration>(
        Duration.zero,
        (sum, s) {
          if (s.duration != null) {
            final parts = s.duration!.split(':').map(int.parse).toList();
            if (parts.length == 2) {
              return sum + Duration(hours: parts[0], minutes: parts[1]);
            }
            return sum + Duration(minutes: parts[0]);
          }
          return sum;
        },
      );
      final favCount = plan.favorites?.length ?? 0;

      return PlanWithMetrics(
        plan: plan,
        totalDistance: totalDist,
        totalCost: totalCost,
        totalDuration: totalDuration,
        favoritesCount: favCount,
      );
    }).toList();

    final metricsList =
        (await Future.wait(futures)).whereType<PlanWithMetrics>().toList();

    if (hadError) {
      errorMessage ??= 'Certaines étapes n’ont pas pu être chargées';
      _log.warning(errorMessage!);
    }

    // Appliquer filtres numériques
    var filtered = metricsList.where((m) {
      if (distanceRange != null &&
          (m.totalDistance < distanceRange!.start ||
              m.totalDistance > distanceRange!.end)) {
        return false;
      }
      if (costRange != null &&
          (m.totalCost < costRange!.start || m.totalCost > costRange!.end)) {
        return false;
      }
      final durSec = m.totalDuration.inSeconds.toDouble();
      if (durationRange != null &&
          (durSec < durationRange!.start || durSec > durationRange!.end)) {
        return false;
      }
      if (favoritesThreshold != null &&
          m.favoritesCount < favoritesThreshold!) {
        return false;
      }
      return true;
    }).toList();

    // Tri
    switch (sortBy) {
      case SortOption.distance:
        filtered.sort((a, b) => a.totalDistance.compareTo(b.totalDistance));
        break;
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
    return hadError
        ? Result.error(Exception(errorMessage ?? 'Erreur inconnue'))
        : Result.ok(null);
  }
}
