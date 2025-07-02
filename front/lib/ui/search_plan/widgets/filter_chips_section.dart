import 'package:flutter/material.dart';

import '../view_models/search_view_model.dart';

class FilterChipsSection extends StatelessWidget {
  final SearchViewModel viewModel;

  const FilterChipsSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final activeFilters = _getActiveFilters();

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres actifs',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: activeFilters
                .map((filter) => _buildFilterChip(
                      context,
                      filter['label'] as String,
                      filter['onRemove'] as VoidCallback,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, VoidCallback onRemove) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.close,
                  size: 14,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getActiveFilters() {
    final filters = <Map<String, dynamic>>[];

    if (viewModel.distanceRange != null) {
      filters.add({
        'label':
            'Distance: ${viewModel.distanceRange!.start.toInt()}-${viewModel.distanceRange!.end.toInt()}m',
        'onRemove': () {
          viewModel.distanceRange = null;
          viewModel.search.execute();
        },
      });
    }

    if (viewModel.costRange != null) {
      filters.add({
        'label':
            'Coût: ${viewModel.costRange!.start.toInt()}-${viewModel.costRange!.end.toInt()}€',
        'onRemove': () {
          viewModel.costRange = null;
          viewModel.search.execute();
        },
      });
    }

    if (viewModel.durationRange != null) {
      final startHours = (viewModel.durationRange!.start / 3600).toInt();
      final endHours = (viewModel.durationRange!.end / 3600).toInt();
      filters.add({
        'label': 'Durée: ${startHours}h-${endHours}h',
        'onRemove': () {
          viewModel.durationRange = null;
          viewModel.search.execute();
        },
      });
    }

    if (viewModel.favoritesThreshold != null) {
      filters.add({
        'label': 'Min ${viewModel.favoritesThreshold} favoris',
        'onRemove': () {
          viewModel.favoritesThreshold = null;
          viewModel.search.execute();
        },
      });
    }

    if (viewModel.sortBy != SortOption.recent) {
      final sortLabel = _getSortLabel(viewModel.sortBy);
      filters.add({
        'label': 'Tri: $sortLabel',
        'onRemove': () {
          viewModel.sortBy = SortOption.recent;
          viewModel.search.execute();
        },
      });
    }

    return filters;
  }

  String _getSortLabel(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.distance:
        return 'Distance';
      case SortOption.cost:
        return 'Coût';
      case SortOption.duration:
        return 'Durée';
      case SortOption.favorites:
        return 'Favoris';
      case SortOption.recent:
        return 'Récent';
    }
  }
}
