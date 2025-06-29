import 'dart:async';

import 'package:flutter/material.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:front/utils/icon_utils.dart';
import 'package:front/utils/result.dart';

import 'package:front/widgets/tag/cutom_chip.dart';
import 'package:front/ui/dashboard/widgets/search_bar/search_bar.dart';
import 'package:front/ui/core/ui/card/compact_plan_card.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

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
  String? _sortBy;
  bool _sortAsc = true;
  double _locationRadius = 10.0; // Default 10km
  bool _useLocation = false;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');

    // S'assurer que le viewModel est bien configuré avec les valeurs initiales
    widget.viewModel.searchQuery = widget.initialQuery ?? '';

    // Initialize sorting state from ViewModel
    _sortBy = widget.viewModel.sortBy;
    _sortAsc = widget.viewModel.sortAscending;

    // Prendre en compte la catégorie initiale si fournie
    if (widget.initialCategory != null) {
      widget.viewModel.selectedCategory = widget.initialCategory;
    }

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
    widget.viewModel.sortBy = _sortBy;
    widget.viewModel.sortAscending = _sortAsc;
    widget.viewModel.locationRadius = _useLocation ? _locationRadius : null;
    widget.viewModel.load.execute();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // For now, we'll simulate getting the location
      // In a real app, you would use geolocator package:
      // Position position = await Geolocator.getCurrentPosition();
      // widget.viewModel.userLatitude = position.latitude;
      // widget.viewModel.userLongitude = position.longitude;

      // Simulate Paris location for demonstration
      widget.viewModel.userLatitude = 48.8566;
      widget.viewModel.userLongitude = 2.3522;
    } catch (e) {
      // Handle location errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'obtenir votre position'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<DashboardViewModel>(builder: (context, model, _) {
        final plans = model.getFilteredPlans();

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _buildSearchBar(model),
          body: Column(
            children: [
              if (model.selectedCategory != null ||
                  _sortBy != null ||
                  _useLocation)
                _buildActiveFilters(model),
              Expanded(
                child: model.isLoading
                    ? _buildLoadingShimmer()
                    : plans.isEmpty
                        ? _buildEmptyView()
                        : _buildVerticalPlanList(plans, model),
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
                  color: (model.selectedCategory != null ||
                          _sortBy != null ||
                          _useLocation)
                      ? Theme.of(context).primaryColor
                      : Colors.grey[700],
                  size: 26,
                ),
                if (model.selectedCategory != null ||
                    _sortBy != null ||
                    _useLocation)
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
    List<Widget> chips = [];

    // Category filter
    if (model.selectedCategory != null) {
      chips.add(
        CustomChip(
          label: model.selectedCategory!.name,
          icon: getIconData(model.selectedCategory!.icon),
          onTap: () {
            setState(() {
              model.selectedCategory = null;
            });
            model.load.execute();
          },
          isSelected: true,
          showCloseIcon: true,
        ),
      );
    }

    // Sorting filter
    if (_sortBy != null) {
      String sortLabel = '';
      IconData sortIcon = Icons.sort;

      switch (_sortBy) {
        case 'cost':
          sortLabel = 'Coût ${_sortAsc ? '(croissant)' : '(décroissant)'}';
          sortIcon = Icons.euro;
          break;
        case 'duration':
          sortLabel = 'Durée ${_sortAsc ? '(croissant)' : '(décroissant)'}';
          sortIcon = Icons.access_time;
          break;
      }

      chips.add(
        CustomChip(
          label: sortLabel,
          icon: sortIcon,
          onTap: () {
            setState(() {
              _sortBy = null;
              _sortAsc = true;
              model.sortBy = null;
              model.sortAscending = true;
            });
            model.load.execute();
          },
          isSelected: true,
          showCloseIcon: true,
        ),
      );
    }

    // Location filter
    if (_useLocation) {
      chips.add(
        CustomChip(
          label: 'Proximité ${_locationRadius.round()}km',
          icon: Icons.location_on,
          onTap: () {
            setState(() {
              _useLocation = false;
              model.locationRadius = null;
            });
            model.load.execute();
          },
          isSelected: true,
          showCloseIcon: true,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...chips.map((chip) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: chip,
                )),
            if (chips.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    model.selectedCategory = null;
                    _sortBy = null;
                    _sortAsc = true;
                    _useLocation = false;
                    _locationRadius = 10.0;
                    model.sortBy = null;
                    model.sortAscending = true;
                    model.locationRadius = null;
                  });
                  model.load.execute();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
          SizedBox(
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
              widget.viewModel.sortBy = null;
              widget.viewModel.sortAscending = true;
              // Also reset local sorting state
              _sortBy = null;
              _sortAsc = true;
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

  Widget _buildVerticalPlanList(List<Plan> plans, DashboardViewModel model) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final steps = model.planSteps[plan.id] ?? [];
        final List<String> firstImage =
            steps.isNotEmpty ? [steps.first.image] : [];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: FutureBuilder<Category?>(
            future: _getCategoryById(model, plan.category),
            builder: (context, snapshot) {
              final category = snapshot.data;
              return CompactPlanCard(
                title: plan.title,
                description: plan.description,
                category: category,
                stepsCount: steps.length,
                imageUrls: firstImage,
                onTap: () => GoRouter.of(context).pushNamed(
                  'detailsPlan',
                  queryParameters: {'planId': plan.id},
                ),
                borderRadius: BorderRadius.circular(16),
                totalCost: _calculateTotalCost(steps),
                totalDuration: _calculateTotalDuration(steps),
              );
            },
          ),
        );
      },
    );
  }

  Future<Category?> _getCategoryById(
      DashboardViewModel model, String categoryId) async {
    final result = await model.getCategoryById(categoryId);
    return result is Ok<Category> ? result.value : null;
  }

  double _calculateTotalCost(List<step_model.Step> steps) {
    return steps.fold(0.0, (sum, step) => sum + (step.cost ?? 0.0));
  }

  int _calculateTotalDuration(List<step_model.Step> steps) {
    int total = 0;
    final regex = RegExp(r'(\d+)\s*(minute|heure|jour|semaine)');

    for (final step in steps) {
      final match = regex.firstMatch(step.duration ?? '');
      if (match != null) {
        final value = int.tryParse(match.group(1)!);
        final unit = match.group(2);
        if (value != null && unit != null) {
          switch (unit) {
            case 'minute':
              total += value;
              break;
            case 'heure':
              total += value * 60;
              break;
            case 'jour':
              total += value * 8 * 60;
              break;
            case 'semaine':
              total += value * 5 * 8 * 60;
              break;
          }
        }
      }
    }

    return total;
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
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
                                label: 'Coût (croissant)',
                                icon: Icons.trending_up,
                                isSelected: _sortBy == 'cost' && _sortAsc,
                                onTap: () {
                                  setModalState(() {
                                    _sortBy = 'cost';
                                    _sortAsc = true;
                                  });
                                },
                              ),
                              CustomChip(
                                label: 'Coût (décroissant)',
                                icon: Icons.trending_down,
                                isSelected: _sortBy == 'cost' && !_sortAsc,
                                onTap: () {
                                  setModalState(() {
                                    _sortBy = 'cost';
                                    _sortAsc = false;
                                  });
                                },
                              ),
                              CustomChip(
                                label: 'Durée (croissant)',
                                icon: Icons.trending_up,
                                isSelected: _sortBy == 'duration' && _sortAsc,
                                onTap: () {
                                  setModalState(() {
                                    _sortBy = 'duration';
                                    _sortAsc = true;
                                  });
                                },
                              ),
                              CustomChip(
                                label: 'Durée (décroissant)',
                                icon: Icons.trending_down,
                                isSelected: _sortBy == 'duration' && !_sortAsc,
                                onTap: () {
                                  setModalState(() {
                                    _sortBy = 'duration';
                                    _sortAsc = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Location filtering
                          Text(
                            'Localisation',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: _useLocation
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[400],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Filtrer par proximité',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: _useLocation
                                              ? Colors.black
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: _useLocation,
                                      onChanged: (value) async {
                                        if (value) {
                                          await _getCurrentLocation();
                                        }
                                        setModalState(() {
                                          _useLocation = value;
                                        });
                                      },
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                                if (_useLocation) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Rayon de recherche: ${_locationRadius.round()} km',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor:
                                          Theme.of(context).primaryColor,
                                      inactiveTrackColor: Colors.grey[300],
                                      thumbColor:
                                          Theme.of(context).primaryColor,
                                      overlayColor: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.2),
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 8),
                                      trackHeight: 4,
                                    ),
                                    child: Slider(
                                      value: _locationRadius,
                                      min: 1,
                                      max: 50,
                                      divisions: 49,
                                      onChanged: (value) {
                                        setModalState(() {
                                          _locationRadius = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    'Les plans avec au moins une étape dans ce rayon seront affichés',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                                _sortBy = null;
                                _sortAsc = true;
                                _useLocation = false;
                                _locationRadius = 10.0;
                                model.selectedCategory = null;
                                // Update ViewModel state
                                model.sortBy = null;
                                model.sortAscending = true;
                                model.locationRadius = null;
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
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
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
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 60,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
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
