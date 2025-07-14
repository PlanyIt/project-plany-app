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
    final activeFilters = viewModel.getActiveFilters();

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
              if (viewModel.activeFiltersCount > 1)
                GestureDetector(
                  onTap: viewModel.clearAllFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
}
