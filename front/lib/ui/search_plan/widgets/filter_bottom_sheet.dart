import 'package:flutter/material.dart';

import '../../../utils/icon_utils.dart';
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
  final _minCostController = TextEditingController();
  final _maxCostController = TextEditingController();
  final _minDurationController = TextEditingController();
  final _maxDurationController = TextEditingController();
  final _favoritesController = TextEditingController();
  final _keywordsController = TextEditingController();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initializeTempValues();
    _initializeControllers();
    _initializeAnimation();
  }

  void _initializeControllers() {
    _minCostController.text = widget.viewModel.tempMinCost;
    _maxCostController.text = widget.viewModel.tempMaxCost;
    _minDurationController.text = widget.viewModel.tempMinDuration;
    _maxDurationController.text = widget.viewModel.tempMaxDuration;
    _keywordsController.text = widget.viewModel.keywordQuery ?? '';
    _favoritesController.text =
        widget.viewModel.tempFavoritesThreshold?.toString() ?? '';

    // Écouter les changements des controllers
    _minCostController.addListener(() {
      widget.viewModel.updateTempCost(minCost: _minCostController.text);
    });
    _maxCostController.addListener(() {
      widget.viewModel.updateTempCost(maxCost: _maxCostController.text);
    });
    _minDurationController.addListener(() {
      widget.viewModel
          .updateTempDuration(minDuration: _minDurationController.text);
    });
    _maxDurationController.addListener(() {
      widget.viewModel
          .updateTempDuration(maxDuration: _maxDurationController.text);
    });
    widget.viewModel.filtersViewModel.setKeywordQuery(_keywordsController.text);
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
    _keywordsController.dispose();
    super.dispose();
  }

  void _applyFilters() async {
    final success = widget.viewModel.applyTempFilters();
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _resetFilters() {
    widget.viewModel.clearAllFilters();
    widget.viewModel.resetTempValues();

    // Réinitialiser les controllers
    _minCostController.clear();
    _maxCostController.clear();
    _minDurationController.clear();
    _maxDurationController.clear();
    _favoritesController.clear();
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
                    _buildKeywordsSearchBar(),
                    const SizedBox(height: 32),
                    _buildSortSection(),
                    const SizedBox(height: 32),
                    _buildCategorySection(),
                    const SizedBox(height: 32),
                    _buildDistanceSection(),
                    const SizedBox(height: 32),
                    _buildPmrSection(),
                    const SizedBox(height: 24),
                    _buildCostSection(),
                    const SizedBox(height: 32),
                    _buildDurationSection(),
                    const SizedBox(height: 32),
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
      child: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          return SortOptionSelector(
            selectedOption: widget.viewModel.tempSortBy,
            onChanged: widget.viewModel.updateTempSortBy,
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    return FilterSection(
      title: 'Catégorie',
      icon: Icons.category_rounded,
      color: Colors.indigo,
      child: _buildCategorySelector(),
    );
  }

  Widget _buildKeywordsSearchBar() {
    return TextField(
      controller: _keywordsController,
      onChanged: (value) {
        widget.viewModel.filtersViewModel.setKeywordQuery(value);
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Recherche par mots-clés (titre, description)...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);
    final categories = widget.viewModel.fullCategories;

    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => widget.viewModel.updateTempSelectedCategory(null),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.viewModel.tempSelectedCategory == null
                      ? Colors.indigo.withValues(alpha: .1)
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.viewModel.tempSelectedCategory == null
                        ? Colors.indigo
                        : theme.dividerColor.withValues(alpha: .3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive_rounded,
                      color: widget.viewModel.tempSelectedCategory == null
                          ? Colors.indigo
                          : theme.textTheme.bodyMedium?.color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Toutes les catégories',
                      style: TextStyle(
                        color: widget.viewModel.tempSelectedCategory == null
                            ? Colors.indigo
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight:
                            widget.viewModel.tempSelectedCategory == null
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Liste des catégories
            ...categories.map((category) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => widget.viewModel
                        .updateTempSelectedCategory(category.id),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            widget.viewModel.tempSelectedCategory == category.id
                                ? Colors.indigo.withValues(alpha: .1)
                                : Colors.transparent,
                        border: Border.all(
                          color: widget.viewModel.tempSelectedCategory ==
                                  category.id
                              ? Colors.indigo
                              : theme.dividerColor.withValues(alpha: .3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            getIconData(category.icon),
                            color: widget.viewModel.tempSelectedCategory ==
                                    category.id
                                ? Colors.indigo
                                : theme.textTheme.bodyMedium?.color,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category.name,
                            style: TextStyle(
                              color: widget.viewModel.tempSelectedCategory ==
                                      category.id
                                  ? Colors.indigo
                                  : theme.textTheme.bodyMedium?.color,
                              fontWeight:
                                  widget.viewModel.tempSelectedCategory ==
                                          category.id
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildDistanceSection() {
    return FilterSection(
      title: 'Rayon de recherche',
      icon: Icons.location_on_rounded,
      color: Colors.blue,
      child: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          return DistanceSlider(
            values: widget.viewModel.tempDistanceRange,
            onChanged: widget.viewModel.updateTempDistanceRange,
          );
        },
      ),
    );
  }

  Widget _buildCostSection() {
    return FilterSection(
      title: 'Budget (€)',
      icon: Icons.euro_rounded,
      color: Colors.green,
      child: RangeInput(
        viewModel: widget.viewModel,
        minController: _minCostController,
        maxController: _maxCostController,
        minLabel: 'Prix minimum',
        maxLabel: 'Prix maximum',
        suffix: '€',
        color: Colors.green,
        fieldName: 'prix',
      ),
    );
  }

  Widget _buildDurationSection() {
    return FilterSection(
      title: 'Durée',
      icon: Icons.schedule_rounded,
      color: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RangeInput(
            viewModel: widget.viewModel,
            minController: _minDurationController,
            maxController: _maxDurationController,
            minLabel: 'Durée minimum',
            maxLabel: 'Durée maximum',
            suffix: widget.viewModel.tempDurationUnit,
            color: Colors.orange,
            fieldName: 'durée',
          ),
          const SizedBox(height: 16),
          _buildDurationUnitSelector(),
        ],
      ),
    );
  }

  Widget _buildDurationUnitSelector() {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final units = ['min', 'h', 'j'];
        final unitLabels = {
          'min': 'Minutes',
          'h': 'Heures',
          'j': 'Jours',
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unité de durée',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: units.map((unit) {
                final isSelected = widget.viewModel.tempDurationUnit == unit;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: unit != units.last ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () =>
                          widget.viewModel.updateTempDurationUnit(unit),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Colors.orange
                                : theme.dividerColor.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          unitLabels[unit]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.orange
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPmrSection() {
    return FilterSection(
      title: 'Accessibilité',
      icon: Icons.accessible,
      color: Colors.teal,
      child: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          return SwitchListTile.adaptive(
            value: widget.viewModel.tempPmrOnly ?? false,
            onChanged: (value) {
              widget.viewModel.updateTempPmrOnly(value ? true : null);
            },
            activeColor: Colors.teal,
            title: const Text('Plans accessibles PMR uniquement'),
          );
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
            child: AnimatedBuilder(
              animation: widget.viewModel,
              builder: (context, _) {
                final hasErrors = widget.viewModel.hasTempValidationErrors;

                return ElevatedButton(
                  onPressed: hasErrors ? null : _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    hasErrors
                        ? 'Erreurs de validation'
                        : 'Appliquer les filtres',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
