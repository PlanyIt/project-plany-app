import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/textfield/custom_text_field.dart';
import '../view_models/search_view_model.dart';
import 'distance_slider.dart';
import 'filter_bottom_sheet_header.dart';
import 'filter_section.dart';
import 'range_input.dart';
import 'sort_option_selector.dart';

class FilterBottomSheet extends StatefulWidget {
  final SearchViewModel viewModel;

  const FilterBottomSheet({
    super.key,
    required this.viewModel,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with TickerProviderStateMixin {
  late RangeValues? _tempDistanceRange;
  late int? _tempMinCost;
  late int? _tempMaxCost;
  late int? _tempMinDuration;
  late int? _tempMaxDuration;
  late int? _tempFavoritesThreshold;
  late SortOption _tempSortBy;

  final _minCostController = TextEditingController();
  final _maxCostController = TextEditingController();
  final _minDurationController = TextEditingController();
  final _maxDurationController = TextEditingController();
  final _favoritesController = TextEditingController();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _initializeAnimation();
  }

  void _initializeValues() {
    _tempDistanceRange = widget.viewModel.distanceRange;
    _tempSortBy = widget.viewModel.sortBy;

    // Cost
    if (widget.viewModel.costRange != null) {
      _tempMinCost = widget.viewModel.costRange!.start.toInt();
      _tempMaxCost = widget.viewModel.costRange!.end.toInt();
      _minCostController.text = _tempMinCost.toString();
      _maxCostController.text = _tempMaxCost.toString();
    }

    // Duration
    if (widget.viewModel.durationRange != null) {
      _tempMinDuration = (widget.viewModel.durationRange!.start / 3600).toInt();
      _tempMaxDuration = (widget.viewModel.durationRange!.end / 3600).toInt();
      _minDurationController.text = _tempMinDuration.toString();
      _maxDurationController.text = _tempMaxDuration.toString();
    }

    // Favorites
    if (widget.viewModel.favoritesThreshold != null) {
      _tempFavoritesThreshold = widget.viewModel.favoritesThreshold;
      _favoritesController.text = _tempFavoritesThreshold.toString();
    }
  }

  void _initializeAnimation() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _minCostController.dispose();
    _maxCostController.dispose();
    _minDurationController.dispose();
    _maxDurationController.dispose();
    _favoritesController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.viewModel.distanceRange = _tempDistanceRange;

    // Cost range
    if (_tempMinCost != null && _tempMaxCost != null) {
      widget.viewModel.costRange = RangeValues(
        _tempMinCost!.toDouble(),
        _tempMaxCost!.toDouble(),
      );
    } else {
      widget.viewModel.costRange = null;
    }

    // Duration range
    if (_tempMinDuration != null && _tempMaxDuration != null) {
      widget.viewModel.durationRange = RangeValues(
        (_tempMinDuration! * 3600).toDouble(),
        (_tempMaxDuration! * 3600).toDouble(),
      );
    } else {
      widget.viewModel.durationRange = null;
    }

    widget.viewModel.favoritesThreshold = _tempFavoritesThreshold;
    widget.viewModel.sortBy = _tempSortBy;
    widget.viewModel.search.execute();
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _tempDistanceRange = null;
      _tempMinCost = null;
      _tempMaxCost = null;
      _tempMinDuration = null;
      _tempMaxDuration = null;
      _tempFavoritesThreshold = null;
      _tempSortBy = SortOption.recent;

      _minCostController.clear();
      _maxCostController.clear();
      _minDurationController.clear();
      _maxDurationController.clear();
      _favoritesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            FilterBottomSheetHeader(onReset: _resetFilters),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSortSection(),
                    const SizedBox(height: 32),
                    _buildDistanceSection(),
                    const SizedBox(height: 32),
                    _buildCostSection(),
                    const SizedBox(height: 32),
                    _buildDurationSection(),
                    const SizedBox(height: 32),
                    _buildFavoritesSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSortSection() {
    return FilterSection(
      title: 'Trier par',
      icon: Icons.sort_rounded,
      color: Colors.purple,
      child: SortOptionSelector(
        selectedOption: _tempSortBy,
        onChanged: (option) => setState(() => _tempSortBy = option),
      ),
    );
  }

  Widget _buildDistanceSection() {
    return FilterSection(
      title: 'Rayon de recherche',
      icon: Icons.location_on_rounded,
      color: Colors.blue,
      child: DistanceSlider(
        values: _tempDistanceRange,
        onChanged: (values) => setState(() => _tempDistanceRange = values),
      ),
    );
  }

  Widget _buildCostSection() {
    return FilterSection(
      title: 'Budget (€)',
      icon: Icons.euro_rounded,
      color: Colors.green,
      child: RangeInput(
        minController: _minCostController,
        maxController: _maxCostController,
        minLabel: 'Prix minimum',
        maxLabel: 'Prix maximum',
        suffix: '€',
        color: Colors.green,
        onMinChanged: (value) => _tempMinCost = int.tryParse(value),
        onMaxChanged: (value) => _tempMaxCost = int.tryParse(value),
      ),
    );
  }

  Widget _buildDurationSection() {
    return FilterSection(
      title: 'Durée (heures)',
      icon: Icons.schedule_rounded,
      color: Colors.orange,
      child: RangeInput(
        minController: _minDurationController,
        maxController: _maxDurationController,
        minLabel: 'Durée minimum',
        maxLabel: 'Durée maximum',
        suffix: 'h',
        color: Colors.orange,
        onMinChanged: (value) => _tempMinDuration = int.tryParse(value),
        onMaxChanged: (value) => _tempMaxDuration = int.tryParse(value),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return FilterSection(
      title: 'Favoris minimum',
      icon: Icons.favorite_rounded,
      color: Colors.red,
      child: CustomTextField(
        controller: _favoritesController,
        labelText: 'Nombre minimum de favoris',
        keyboardType: TextInputType.number,
        onFocusChange: (_) =>
            _tempFavoritesThreshold = int.tryParse(_favoritesController.text),
        onTextFieldTap: () {
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: .1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.withValues(alpha: .3)),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Appliquer les filtres',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
