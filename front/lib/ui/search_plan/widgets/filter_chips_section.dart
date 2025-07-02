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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Filtres actifs',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (activeFilters.length > 1)
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear_all_rounded,
                          size: 12,
                          color: Colors.red[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tout effacer',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activeFilters
                .map((filter) => _buildModernFilterChip(
                      context,
                      filter['label'] as String,
                      filter['onRemove'] as VoidCallback,
                      filter['icon'] as IconData?,
                      filter['color'] as Color?,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(
    BuildContext context,
    String label,
    VoidCallback onRemove,
    IconData? icon,
    Color? customColor,
  ) {
    final theme = Theme.of(context);
    final chipColor = customColor ?? theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chipColor.withValues(alpha: .15),
            chipColor.withValues(alpha: .08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: chipColor.withValues(alpha: .2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: chipColor.withValues(alpha: .1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(16),
          splashColor: chipColor.withValues(alpha: .2),
          highlightColor: chipColor.withValues(alpha: .1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 14,
                    color: chipColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: chipColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: .2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: chipColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearAllFilters() {
    viewModel.distanceRange = null;
    viewModel.costRange = null;
    viewModel.durationRange = null;
    viewModel.favoritesThreshold = null;
    viewModel.sortBy = SortOption.recent;
    viewModel.search.execute();
  }

  List<Map<String, dynamic>> _getActiveFilters() {
    final filters = <Map<String, dynamic>>[];

    if (viewModel.distanceRange != null) {
      filters.add({
        'label':
            '${viewModel.distanceRange!.start.toInt()}-${viewModel.distanceRange!.end.toInt()}m',
        'icon': Icons.location_on_rounded,
        'color': Colors.blue,
        'onRemove': () {
          viewModel.distanceRange = null;
          viewModel.search.execute();
        },
      });
    }

    if (viewModel.costRange != null) {
      filters.add({
        'label':
            '${viewModel.costRange!.start.toInt()}-${viewModel.costRange!.end.toInt()}€',
        'icon': Icons.euro_rounded,
        'color': Colors.green,
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
        'label': '${startHours}h-${endHours}h',
        'icon': Icons.schedule_rounded,
        'color': Colors.orange,
        'onRemove': () {
          viewModel.durationRange = null;
          viewModel.search.execute();
        },
      });
    }

    if (viewModel.favoritesThreshold != null) {
      filters.add({
        'label': 'Min ${viewModel.favoritesThreshold} ♥',
        'icon': Icons.favorite_rounded,
        'color': Colors.red,
        'onRemove': () {
          viewModel.favoritesThreshold = null;
          viewModel.search.execute();
        },
      });
    }

    if (viewModel.sortBy != SortOption.recent) {
      final sortData = _getSortData(viewModel.sortBy);
      filters.add({
        'label': sortData['label'],
        'icon': sortData['icon'],
        'color': Colors.purple,
        'onRemove': () {
          viewModel.sortBy = SortOption.recent;
          viewModel.search.execute();
        },
      });
    }

    return filters;
  }

  Map<String, dynamic> _getSortData(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.distance:
        return {
          'label': 'Tri: Distance',
          'icon': Icons.near_me_rounded,
        };
      case SortOption.cost:
        return {
          'label': 'Tri: Prix',
          'icon': Icons.attach_money_rounded,
        };
      case SortOption.duration:
        return {
          'label': 'Tri: Durée',
          'icon': Icons.timer_rounded,
        };
      case SortOption.favorites:
        return {
          'label': 'Tri: Popularité',
          'icon': Icons.trending_up_rounded,
        };
      case SortOption.recent:
        return {
          'label': 'Tri: Récent',
          'icon': Icons.history_rounded,
        };
    }
  }
}
