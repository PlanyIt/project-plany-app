import 'dart:async';

import 'package:flutter/material.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/ui/core/ui/card/compact_plan_card.dart';
import 'package:front/widgets/tag/cutom_chip.dart';
import 'package:front/ui/dashboard/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final Category? initialCategory;
  final bool autoFocus;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
    this.autoFocus = false,
    required this.viewModel,
  });

  final DashboardViewModel viewModel;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  // For filters
  RangeValues _costRange = const RangeValues(0, 1000);
  RangeValues _durationRange = const RangeValues(0, 1440);
  final double _maxCost = 1000;
  final double _maxDuration = 1440;
  String? _sortBy;
  bool _sortAsc = true;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    widget.viewModel.searchQuery = widget.initialQuery ?? '';
    widget.viewModel.selectedCategory = widget.initialCategory;

    // Utiliser addPostFrameCallback pour exécuter après le build initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Charger les données après que le build initial soit terminé
      widget.viewModel.load.execute();

      if (widget.autoFocus) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.viewModel.searchQuery = value;
      widget.viewModel.load.execute();
    });
  }

  void _applyFilters() {
    widget.viewModel.searchQuery = _searchController.text;
    widget.viewModel.selectedCategory = widget.viewModel.selectedCategory;
    // Note: cost and duration filtering not yet in ViewModel
    widget.viewModel.load.execute();
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<DashboardViewModel>(builder: (context, model, _) {
        final plans = model.getFilteredPlans();
        final categories = model.categories;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _buildSearchBar(model),
          body: Column(
            children: [
              if (model.selectedCategory != null) _buildActiveFilters(model),
              Expanded(
                child: model.isLoading
                    ? _buildLoadingShimmer()
                    : plans.isEmpty
                        ? _buildEmptyView()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: plans.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, idx) {
                              final plan = plans[idx];
                              final images = plan.steps
                                  .map((id) => model.getStepImageById(id))
                                  .whereType<String>()
                                  .take(5)
                                  .toList();
                              final cost = model.calculatePlanTotalCost(plan);
                              final duration =
                                  model.calculatePlanTotalDuration(plan);

                              // Ajouter une animation de défilement
                              return AnimatedBuilder(
                                animation: AlwaysStoppedAnimation(
                                    (idx % 2 == 0) ? 1.0 : 0.0),
                                builder: (context, child) {
                                  return AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: Duration(
                                        milliseconds: 300 + (idx * 50)),
                                    curve: Curves.easeInOut,
                                    child: TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 20, end: 0),
                                      duration: Duration(
                                          milliseconds: 300 + (idx * 50)),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, double value, child) {
                                        return Transform.translate(
                                          offset: Offset(0, value),
                                          child: child,
                                        );
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            onTap: () =>
                                                _navigateToDetail(plan.id),
                                            child: CompactPlanCard(
                                              title: plan.title,
                                              description: plan.description,
                                              imageUrls: images,
                                              category: categories.firstWhere(
                                                (c) => c.id == plan.category,
                                                orElse: () => Category(
                                                    id: '', name: '', icon: ''),
                                              ),
                                              stepsCount: plan.steps.length,
                                              totalCost: cost,
                                              totalDuration: duration,
                                              onTap: () =>
                                                  _navigateToDetail(plan.id),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      }),
    );
  }

  AppBar _buildSearchBar(DashboardViewModel model) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8, top: 8),
        child: Hero(
          tag: 'searchBar',
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: DashboardSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: widget.autoFocus,
              hintText: 'Rechercher un plan...',
              onChanged: (v) {
                _onSearchChanged(v);
              },
              onSubmitted: (_) => _applyFilters(),
              onTap: () {},
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color: model.selectedCategory != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey[700],
                  size: 26,
                ),
                if (model.selectedCategory != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              _showFilterBottomSheet(context, model);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters(DashboardViewModel model) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            CustomChip(
              label: model.selectedCategory!.name,
              icon: getIconData(model.selectedCategory!.icon),
              onTap: () {
                model.selectedCategory = null;
                model.load.execute();
              },
              isSelected: true,
              showCloseIcon: true,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Effacer tout',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Aucun résultat trouvé",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              "Essayez de modifier vos critères de recherche ou explorez d'autres catégories",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              widget.viewModel.searchQuery = '';
              widget.viewModel.selectedCategory = null;
              widget.viewModel.load.execute();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réinitialiser la recherche'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(String? planId) {
    if (planId == null) return;
    Navigator.pushNamed(context, '/details', arguments: planId);
  }

  void _showFilterBottomSheet(BuildContext context, DashboardViewModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtres',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.close, size: 20),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Filter content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Categories
                          Text(
                            'Catégories',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          model.categories.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: model.categories.map((category) {
                                    final isSelected =
                                        model.selectedCategory?.id ==
                                            category.id;
                                    return CustomChip(
                                      label: category.name,
                                      icon: getIconData(category.icon),
                                      isSelected: isSelected,
                                      onTap: () {
                                        setModalState(() {
                                          if (isSelected) {
                                            model.selectedCategory = null;
                                          } else {
                                            model.selectedCategory = category;
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                          const SizedBox(height: 24),

                          // Cost Range
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Coût',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${_costRange.start.toInt()}€ - ${_costRange.end.toInt()}€',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: Theme.of(context).primaryColor,
                              inactiveTrackColor: Colors.grey[200],
                              thumbColor: Theme.of(context).primaryColor,
                              overlayColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              trackHeight: 4,
                            ),
                            child: RangeSlider(
                              values: _costRange,
                              min: 0,
                              max: _maxCost,
                              divisions: 20,
                              onChanged: (values) {
                                setModalState(() {
                                  _costRange = values;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Duration Range
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Durée',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${_formatDuration(_durationRange.start.toInt())} - ${_formatDuration(_durationRange.end.toInt())}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: Theme.of(context).primaryColor,
                              inactiveTrackColor: Colors.grey[200],
                              thumbColor: Theme.of(context).primaryColor,
                              overlayColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              trackHeight: 4,
                            ),
                            child: RangeSlider(
                              values: _durationRange,
                              min: 0,
                              max: _maxDuration,
                              divisions: 24,
                              onChanged: (values) {
                                setModalState(() {
                                  _durationRange = values;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sort options
                          Text(
                            'Trier par',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              CustomChip(
                                label: 'Pertinence',
                                icon: Icons.sort,
                                isSelected: _sortBy == null,
                                onTap: () {
                                  setModalState(() {
                                    _sortBy = null;
                                  });
                                },
                              ),
                              CustomChip(
                                label: 'Coût ${_sortAsc ? '↑' : '↓'}',
                                icon: Icons.euro,
                                isSelected: _sortBy == 'cost',
                                onTap: () {
                                  setModalState(() {
                                    if (_sortBy == 'cost') {
                                      _sortAsc = !_sortAsc;
                                    } else {
                                      _sortBy = 'cost';
                                      _sortAsc = true;
                                    }
                                  });
                                },
                              ),
                              CustomChip(
                                label: 'Durée ${_sortAsc ? '↑' : '↓'}',
                                icon: Icons.access_time,
                                isSelected: _sortBy == 'duration',
                                onTap: () {
                                  setModalState(() {
                                    if (_sortBy == 'duration') {
                                      _sortAsc = !_sortAsc;
                                    } else {
                                      _sortBy = 'duration';
                                      _sortAsc = true;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom buttons
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _costRange = RangeValues(0, _maxCost);
                                _durationRange = RangeValues(0, _maxDuration);
                                _sortBy = null;
                                _sortAsc = true;
                                model.selectedCategory = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Réinitialiser'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _applyFilters();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Appliquer'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[300]!,
                    Colors.grey[200]!,
                    Colors.grey[300]!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Shimmer effect
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedBuilder(
                          animation: AlwaysStoppedAnimation(0),
                          builder: (context, child) {
                            return Opacity(
                              opacity: 0.6,
                              child: Container(
                                width: constraints.maxWidth,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(-1.0, -0.3),
                                    end: Alignment(1.0, 0.3),
                                    colors: [
                                      Colors.grey[300]!,
                                      Colors.grey[200]!,
                                      Colors.grey[100]!,
                                      Colors.grey[200]!,
                                      Colors.grey[300]!,
                                    ],
                                    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                                    tileMode: TileMode.clamp,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Content shimmer
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Container(
                          width: 200,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        const Spacer(),

                        // Footer
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 60,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
