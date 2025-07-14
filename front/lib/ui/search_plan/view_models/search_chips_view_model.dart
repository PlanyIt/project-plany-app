import 'package:flutter/material.dart';
import '../../../domain/models/category/category.dart';
import 'search_filters_view_model.dart';

class SearchChipsViewModel extends ChangeNotifier {
  final SearchFiltersViewModel filtersViewModel;
  final List<Category> categories;

  SearchChipsViewModel({
    required this.filtersViewModel,
    required this.categories,
  }) {
    filtersViewModel.addListener(notifyListeners);
  }

  String getCategoryName(String categoryId) {
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () =>
          Category(id: categoryId, name: categoryId, icon: '', color: ''),
    );
    return category.name;
  }

  List<Map<String, dynamic>> getActiveFilters() {
    final filters = <Map<String, dynamic>>[];

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

    if (filtersViewModel.distanceRange != null) {
      final range = filtersViewModel.distanceRange!;
      final startKm = (range.start / 1000).toStringAsFixed(1);
      final endKm = (range.end / 1000).toStringAsFixed(1);
      filters.add({
        'type': 'distance',
        'label': 'Distance: ${startKm}km - ${endKm}km',
        'onRemove': () {
          filtersViewModel.updateTempDistanceRange(null);
          filtersViewModel.applyTempFilters();
        },
      });
    }

    if (filtersViewModel.costRange != null) {
      final range = filtersViewModel.costRange!;
      String label;
      if (range.start == 0.0 && range.end != 999999.0) {
        label = 'Budget: jusqu\'à ${range.end.toInt()}€';
      } else if (range.start != 0.0 && range.end == 999999.0) {
        label = 'Budget: à partir de ${range.start.toInt()}€';
      } else if (range.start != 0.0 && range.end != 999999.0) {
        label = 'Budget: ${range.start.toInt()}€ - ${range.end.toInt()}€';
      } else {
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

    if (filtersViewModel.durationRange != null) {
      final range = filtersViewModel.durationRange!;
      final startMinutes = (range.start / 60).round();
      final endMinutes = (range.end / 60).round();

      String label;
      if (range.start == 0.0 && range.end != (999999 * 60)) {
        label = 'Durée: jusqu\'à ${_formatDurationForChip(endMinutes)}';
      } else if (range.start != 0.0 && range.end == (999999 * 60)) {
        label = 'Durée: à partir de ${_formatDurationForChip(startMinutes)}';
      } else if (range.start != 0.0 && range.end != (999999 * 60)) {
        label =
            'Durée: ${_formatDurationForChip(startMinutes)} - ${_formatDurationForChip(endMinutes)}';
      } else {
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

    if (filtersViewModel.favoritesThreshold != null) {
      filters.add({
        'type': 'favorites',
        'label': 'Min ${filtersViewModel.favoritesThreshold} favoris',
        'onRemove': () {
          filtersViewModel.updateTempFavoritesThreshold(null);
          filtersViewModel.applyTempFilters();
        },
      });
    }

    // --- Chip PMR ---
    if (filtersViewModel.pmrOnly == true) {
      filters.add({
        'type': 'pmr',
        'label': 'Accessibilité PMR',
        'onRemove': () {
          filtersViewModel.updateTempPmrOnly(null);
          filtersViewModel.applyTempFilters();
        },
        'icon': Icons.accessible,
        'color': Colors.teal,
      });
    }

    if (filtersViewModel.selectedLocationName != null) {
      filters.add({
        'type': 'location',
        'label': filtersViewModel.selectedLocationName!,
        'onRemove': () {
          filtersViewModel.setSelectedLocation(null, null);
        },
        'icon': Icons.location_on,
        'color': Colors.blue,
      });
    }

    if (filtersViewModel.keywordQuery != null &&
        filtersViewModel.keywordQuery!.isNotEmpty) {
      filters.add({
        'type': 'keyword',
        'label': filtersViewModel.keywordQuery!,
        'onRemove': () {
          filtersViewModel.setKeywordQuery(null);
        },
        'icon': Icons.search,
        'color': Colors.deepOrange,
      });
    }

    // --- Chip Tri ---
    if (filtersViewModel.sortBy != SortOption.favorites) {
      String label;
      switch (filtersViewModel.sortBy) {
        case SortOption.cost:
          label = 'Trier: Prix croissant';
          break;
        case SortOption.duration:
          label = 'Trier: Durée croissante';
          break;
        case SortOption.recent:
          label = 'Trier: Récent';
          break;
        default:
          label = 'Trier: Populaires';
      }

      filters.add({
        'type': 'sort',
        'label': label,
        'onRemove': () {
          filtersViewModel.updateTempSortBy(SortOption.favorites);
          filtersViewModel.applyTempFilters();
        },
        'icon': Icons.sort,
        'color': const Color(0xFF9C27B0),
      });
    }

    return filters;
  }

  String _formatDurationForChip(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else if (minutes < 1440) {
      final hours = (minutes / 60).round();
      return '${hours}h';
    } else {
      final days = (minutes / 1440).round();
      return '${days}j';
    }
  }

  bool get hasActiveFilters => getActiveFilters().isNotEmpty;
  int get activeFiltersCount => getActiveFilters().length;

  @override
  void dispose() {
    filtersViewModel.removeListener(notifyListeners);
    super.dispose();
  }
}
