import 'package:flutter/material.dart';
import '../../../domain/models/category/category.dart';
import 'search_filters_view_model.dart';

/// ViewModel pour la gestion des chips de filtres actifs
class SearchChipsViewModel extends ChangeNotifier {
  final SearchFiltersViewModel filtersViewModel;
  final List<Category> categories;

  SearchChipsViewModel({
    required this.filtersViewModel,
    required this.categories,
  }) {
    // Écouter les changements du filtersViewModel pour mettre à jour les chips
    filtersViewModel.addListener(notifyListeners);
  }

  /// Obtient le nom d'une catégorie par son ID
  String getCategoryName(String categoryId) {
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () =>
          Category(id: categoryId, name: categoryId, icon: '', color: ''),
    );
    return category.name;
  }

  /// Obtient la liste des filtres actifs avec leurs données d'affichage
  List<Map<String, dynamic>> getActiveFilters() {
    final filters = <Map<String, dynamic>>[];

    // Catégorie
    if (filtersViewModel.selectedCategory != null) {
      final category = categories.firstWhere(
        (cat) => cat.id == filtersViewModel.selectedCategory,
        orElse: () => Category(
          id: filtersViewModel.selectedCategory!,
          name: filtersViewModel.selectedCategory!,
          icon: '',
          color: '',
        ),
      );
      filters.add({
        'type': 'category',
        'label': category.name,
        'onRemove': () => filtersViewModel.setSelectedCategory(null),
      });
    }

    // Distance
    if (filtersViewModel.distanceRange != null) {
      final range = filtersViewModel.distanceRange!;
      final startKm = (range.start / 1000).toStringAsFixed(1);
      final endKm = (range.end / 1000).toStringAsFixed(1);
      filters.add({
        'type': 'distance',
        'label': 'Distance: ${startKm}km - ${endKm}km',
        'onRemove': () => filtersViewModel.updateTempDistanceRange(null),
      });
    }

    // Prix avec support pour min ou max seul
    if (filtersViewModel.costRange != null) {
      final range = filtersViewModel.costRange!;
      String label;

      // Si c'est la valeur par défaut (0), afficher seulement le max
      if (range.start == 0.0 && range.end != 999999.0) {
        label = 'Budget: jusqu\'à ${range.end.toInt()}€';
      }
      // Si c'est la valeur max par défaut, afficher seulement le min
      else if (range.start != 0.0 && range.end == 999999.0) {
        label = 'Budget: à partir de ${range.start.toInt()}€';
      }
      // Si les deux sont définies
      else if (range.start != 0.0 && range.end != 999999.0) {
        label = 'Budget: ${range.start.toInt()}€ - ${range.end.toInt()}€';
      }
      // Cas par défaut (ne devrait pas arriver)
      else {
        label = 'Budget défini';
      }

      filters.add({
        'type': 'cost',
        'label': label,
        'onRemove': () {
          filtersViewModel.updateTempCost(minCost: '', maxCost: '');
          filtersViewModel.applyTempFilters();
        },
      });
    }

    // Durée avec support pour min ou max seul
    if (filtersViewModel.durationRange != null) {
      final range = filtersViewModel.durationRange!;
      final startMinutes = (range.start / 60).round();
      final endMinutes = (range.end / 60).round();

      String label;

      // Si c'est la valeur par défaut (0), afficher seulement le max
      if (range.start == 0.0 && range.end != (999999 * 60)) {
        label = 'Durée: jusqu\'à ${_formatDurationForChip(endMinutes)}';
      }
      // Si c'est la valeur max par défaut, afficher seulement le min
      else if (range.start != 0.0 && range.end == (999999 * 60)) {
        label = 'Durée: à partir de ${_formatDurationForChip(startMinutes)}';
      }
      // Si les deux sont définies
      else if (range.start != 0.0 && range.end != (999999 * 60)) {
        label =
            'Durée: ${_formatDurationForChip(startMinutes)} - ${_formatDurationForChip(endMinutes)}';
      }
      // Cas par défaut
      else {
        label = 'Durée définie';
      }

      filters.add({
        'type': 'duration',
        'label': label,
        'onRemove': () {
          filtersViewModel.updateTempDuration(minDuration: '', maxDuration: '');
          filtersViewModel.applyTempFilters();
        },
      });
    }

    // Favoris
    if (filtersViewModel.favoritesThreshold != null) {
      filters.add({
        'type': 'favorites',
        'label': 'Min ${filtersViewModel.favoritesThreshold} favoris',
        'onRemove': () => filtersViewModel.updateTempFavoritesThreshold(null),
      });
    }

    return filters;
  }

  /// Formate une durée en minutes pour l'affichage dans les chips
  String _formatDurationForChip(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else if (minutes < 1440) {
      // moins de 24h
      final hours = (minutes / 60).round();
      return '${hours}h';
    } else {
      final days = (minutes / 1440).round();
      return '${days}j';
    }
  }

  /// Méthodes privées pour supprimer des filtres spécifiques
  void _removeDistanceFilter() {
    filtersViewModel.distanceRange = null;
    filtersViewModel.notifyListeners();
  }

  void _removeCostFilter() {
    filtersViewModel.costRange = null;
    filtersViewModel.notifyListeners();
  }

  void _removeDurationFilter() {
    filtersViewModel.durationRange = null;
    filtersViewModel.notifyListeners();
  }

  void _removeFavoritesFilter() {
    filtersViewModel.favoritesThreshold = null;
    filtersViewModel.notifyListeners();
  }

  void _removeSortFilter() {
    filtersViewModel.sortBy = SortOption.recent;
    filtersViewModel.notifyListeners();
  }

  /// Obtient les données d'affichage pour un critère de tri
  Map<String, dynamic> _getSortData(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.cost:
        return {'label': 'Tri: Prix', 'icon': Icons.attach_money_rounded};
      case SortOption.duration:
        return {'label': 'Tri: Durée', 'icon': Icons.timer_rounded};
      case SortOption.favorites:
        return {'label': 'Tri: Popularité', 'icon': Icons.trending_up_rounded};
      case SortOption.recent:
        return {'label': 'Tri: Récent', 'icon': Icons.history_rounded};
    }
  }

  /// Vérifie s'il y a des filtres actifs
  bool get hasActiveFilters => getActiveFilters().isNotEmpty;

  /// Obtient le nombre de filtres actifs
  int get activeFiltersCount => getActiveFilters().length;

  @override
  void dispose() {
    filtersViewModel.removeListener(notifyListeners);
    super.dispose();
  }

  /// Détermine la meilleure unité d'affichage pour la durée
  String _getDurationDisplayUnit(int startMinutes, int endMinutes) {
    final maxMinutes = endMinutes;

    if (maxMinutes >= 24 * 60) {
      return 'j';
    } else if (maxMinutes >= 60) {
      return 'h';
    } else {
      return 'min';
    }
  }

  /// Convertit des minutes vers l'unité d'affichage
  double _convertMinutesToDisplayUnit(int minutes, String unit) {
    switch (unit) {
      case 'j':
        return minutes / (24 * 60);
      case 'h':
        return minutes / 60;
      case 'min':
      default:
        return minutes.toDouble();
    }
  }
}
