import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/utils/helpers.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/ui/dashboard/widgets/shimmer/shimmer_effect.dart';
import 'package:front/ui/core/ui/widgets/tag/cutom_chip.dart';
import 'package:front/ui/core/ui/card/compact_plan_card.dart';
import 'package:front/ui/dashboard/widgets/search_bar/search_bar.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final Category? initialCategory;
  final bool autoFocus;
  final DashboardViewModel viewModel;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
    this.autoFocus = false,
    required this.viewModel,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');

    widget.viewModel.initSearchScreen(
      initialQuery: widget.initialQuery,
      initialCategory: widget.initialCategory,
    );

    // Récupère la localisation puis charge les plans
    widget.viewModel.getCurrentLocation().whenComplete(() {
      print('DEBUG: getCurrentLocation completed in SearchScreen');
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
      widget.viewModel.updateSearchQuery(value);
      widget.viewModel.applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<DashboardViewModel>(
        builder: (context, model, _) {
          final isLoading = model.isLoading.value;
          final plans = model.getFilteredPlans();
          final hasFilters = model.hasActiveFilters;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: _buildSearchBar(model),
            body: Column(
              children: [
                if (hasFilters) _buildActiveFilters(model),
                Expanded(
                  child: isLoading
                      ? const ShimmerEffect()
                      : plans.isEmpty
                          ? _buildEmptyView(model)
                          : _buildPlanList(plans, model),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildSearchBar(DashboardViewModel model) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: DashboardSearchBar(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: widget.autoFocus,
          hintText: 'Rechercher un plan...',
          onChanged: _onSearchChanged,
          onSubmitted: (_) => widget.viewModel.applyFilters(),
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 26,
                color: widget.viewModel.hasActiveFilters
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
              if (widget.viewModel.hasActiveFilters)
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
          onPressed: () => _showFilterBottomSheet(context),
        ),
      ],
    );
  }

  Widget _buildActiveFilters(DashboardViewModel model) {
    final List<Widget> chips = [];
    final radius = model.searchScreenLocationRadius;

    if (model.selectedCategory != null) {
      chips.add(
        CustomChip(
          label: model.selectedCategory!.name,
          icon: getIconData(model.selectedCategory!.icon),
          onTap: () {
            model.selectedCategory = null;
            model.applyFilters();
          },
          isSelected: true,
          showCloseIcon: true,
        ),
      );
    }
    if (model.searchScreenSortBy != null) {
      final asc = model.searchScreenSortAsc;
      String label;
      IconData icon;
      switch (model.searchScreenSortBy!) {
        case 'cost':
          label = 'Coût ${asc ? '(↑)' : '(↓)'}';
          icon = Icons.euro;
          break;
        case 'duration':
          label = 'Durée ${asc ? '(↑)' : '(↓)'}';
          icon = Icons.access_time;
          break;
        default:
          label = 'Trier';
          icon = Icons.sort;
      }
      chips.add(
        CustomChip(
          label: label,
          icon: icon,
          onTap: () {
            model.updateSort(null, true);
            model.applyFilters();
          },
          isSelected: true,
          showCloseIcon: true,
        ),
      );
    }
    if (model.searchScreenUseLocation) {
      chips.add(
        CustomChip(
          label: 'Proximité ${radius.round()} km',
          icon: Icons.location_on,
          onTap: () {
            model.updateLocationFilter(false, radius);
            model.applyFilters();
          },
          isSelected: true,
          showCloseIcon: true,
        ),
      );
    }
    if (chips.isNotEmpty) {
      chips.add(
        GestureDetector(
          onTap: () => widget.viewModel.resetFilters(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Effacer tout',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
          children: chips
              .map((c) =>
                  Padding(padding: const EdgeInsets.only(right: 8), child: c))
              .toList()),
    );
  }

  Widget _buildEmptyView(DashboardViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text('Aucun résultat trouvé',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
              'Essayez de modifier vos critères ou explorez d’autres catégories',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Réinitialiser'),
            onPressed: () => widget.viewModel.resetFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanList(List<Plan> plans, DashboardViewModel model) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, i) {
        final plan = plans[i];
        final steps = model.planSteps[plan.id] ?? [];
        final images = steps.isNotEmpty ? [steps.first.image] : <String>[];
        final distanceMeters = model.calculateDistanceToFirstStepValue(plan);
        final distanceLabel = formatDistance(distanceMeters);

        return CompactPlanCard(
          title: plan.title,
          description: plan.description,
          category: null,
          stepsCount: steps.length,
          imageUrls: images,
          totalCost: calculateTotalStepsCost(steps),
          totalDuration: calculateTotalDuration(steps),
          distance: distanceLabel,
          onTap: () => model.goToPlanDetail(context, plan.id!),
          borderRadius: BorderRadius.circular(12),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(viewModel: widget.viewModel),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final DashboardViewModel viewModel;
  const _FilterSheet({required this.viewModel});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? sortBy;
  bool sortAsc = true;
  bool useLocation = false;
  double radius = 10.0;
  Category? category;

  @override
  void initState() {
    super.initState();
    final vm = widget.viewModel;
    sortBy = vm.searchScreenSortBy;
    sortAsc = vm.searchScreenSortAsc;
    useLocation = vm.searchScreenUseLocation;
    radius = vm.searchScreenLocationRadius;
    category = vm.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 5, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Filtres',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Expanded(
              child: SingleChildScrollView(
                controller: scroll,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Catégorie
                    Text('Catégorie',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: vm.categories.map((cat) {
                        final selected = category?.id == cat.id;
                        return ChoiceChip(
                          label: Text(cat.name),
                          selected: selected,
                          onSelected: (val) =>
                              setState(() => category = val ? cat : null),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Tri
                    Text('Trier par',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                            label: const Text('Coût'),
                            selected: sortBy == 'cost',
                            onSelected: (v) =>
                                setState(() => sortBy = v ? 'cost' : null)),
                        ChoiceChip(
                            label: const Text('Durée'),
                            selected: sortBy == 'duration',
                            onSelected: (v) =>
                                setState(() => sortBy = v ? 'duration' : null)),
                        ChoiceChip(
                            label: const Text('Distance'),
                            selected: sortBy == 'distance',
                            onSelected: (v) =>
                                setState(() => sortBy = v ? 'distance' : null)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Ordre : '),
                        ChoiceChip(
                            label: const Text('Ascendant'),
                            selected: sortAsc,
                            onSelected: (v) => setState(() => sortAsc = true)),
                        const SizedBox(width: 8),
                        ChoiceChip(
                            label: const Text('Descendant'),
                            selected: !sortAsc,
                            onSelected: (v) => setState(() => sortAsc = false)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Localisation
                    Row(
                      children: [
                        Switch(
                            value: useLocation,
                            onChanged: (v) => setState(() => useLocation = v)),
                        const Text('Filtrer par proximité'),
                      ],
                    ),
                    if (useLocation) ...[
                      const SizedBox(height: 8),
                      Text('Rayon : ${radius.round()} km'),
                      Slider(
                          value: radius,
                          min: 1,
                          max: 100,
                          divisions: 99,
                          label: '${radius.round()} km',
                          onChanged: (v) => setState(() => radius = v)),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        vm.resetFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        vm.updateSort(sortBy, sortAsc);
                        vm.updateLocationFilter(useLocation, radius);
                        vm.selectedCategory = category;
                        vm.applyFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
