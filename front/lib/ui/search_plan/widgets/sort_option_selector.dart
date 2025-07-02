import 'package:flutter/material.dart';
import '../view_models/search_view_model.dart';

class SortOptionSelector extends StatelessWidget {
  final SortOption selectedOption;
  final Function(SortOption) onChanged;

  const SortOptionSelector({
    super.key,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: SortOption.values.map((option) {
        final isSelected = selectedOption == option;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withValues(alpha: .1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : Colors.grey.withValues(alpha: .2),
            ),
          ),
          child: RadioListTile<SortOption>(
            value: option,
            groupValue: selectedOption,
            onChanged: (value) => onChanged(value!),
            title: Text(
              _getSortLabel(option),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? theme.primaryColor : null,
              ),
            ),
            activeColor: theme.primaryColor,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        );
      }).toList(),
    );
  }

  String _getSortLabel(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.distance:
        return 'Distance croissante';
      case SortOption.cost:
        return 'Prix croissant';
      case SortOption.duration:
        return 'Durée croissante';
      case SortOption.favorites:
        return 'Plus populaires';
      case SortOption.recent:
        return 'Plus récents';
    }
  }
}
