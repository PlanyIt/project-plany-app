import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../data/services/location_service.dart';
import '../../routing/routes.dart';
import '../core/ui/list/vertical_plan_list.dart';
import '../core/ui/search_bar/search_bar.dart';
import '../create_plan/view_models/choose_location_view_model.dart';
import 'view_models/search_view_model.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/filter_chips_section.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;
  final SearchViewModel viewModel;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
    required this.viewModel,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final ChooseLocationViewModel _locationViewModel;
  final LocationService _locationService = LocationService();

  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _locationViewModel =
        ChooseLocationViewModel(locationService: _locationService);

    _initializeLocationAndFilters();

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }

    if (widget.initialCategory != null) {
      widget.viewModel.filtersViewModel
          .setSelectedCategory(widget.initialCategory);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCurrentLocation();
    });
  }

  Future<void> _initializeLocationAndFilters() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final location = LatLng(position.latitude, position.longitude);
      final name = await _locationService.reverseGeocode(location) ??
          'Ma position actuelle';
      widget.viewModel.filtersViewModel.setSelectedLocation(location, name);
      widget.viewModel.filtersViewModel.distanceRange =
          const RangeValues(0, 5000);
      widget.viewModel.search.execute();
    }
  }

  Future<void> _refreshCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    await widget.viewModel.initializeWithCurrentLocation();
    setState(() {
      _isLoadingLocation = false;
    });
  }

  @override
  void dispose() {
    _locationViewModel.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        viewModel: widget.viewModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.dashboard),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: DashboardSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: 'Rechercher un lieu...',
                    autofocus: true,
                    onChanged: (query) {
                      _locationViewModel.onSearchChanged(query);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _isLoadingLocation
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _refreshCurrentLocation,
                      ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showFilterBottomSheet(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(Icons.tune, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: widget.viewModel,
            builder: (context, _) {
              return FilterChipsSection(viewModel: widget.viewModel);
            },
          ),
          AnimatedBuilder(
            animation: _locationViewModel,
            builder: (context, _) {
              if (_locationViewModel.searchResults.isNotEmpty ||
                  _locationViewModel.isSearching) {
                return Expanded(
                  child: _locationViewModel.isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _locationViewModel.searchResults.length,
                          itemBuilder: (context, index) {
                            final result =
                                _locationViewModel.searchResults[index];
                            return ListTile(
                              title: Text(result.name),
                              subtitle: Text(result.description),
                              leading: const Icon(Icons.location_on),
                              onTap: () {
                                widget.viewModel.filtersViewModel
                                    .setSelectedLocationWithDefaultDistance(
                                  result.location,
                                  result.name,
                                );
                                widget.viewModel.search.execute();
                                _locationViewModel.clearSearchResults();
                                _searchFocusNode.unfocus();
                                _searchController.clear();
                              },
                            );
                          },
                        ),
                );
              }

              return Expanded(
                child: AnimatedBuilder(
                  animation: widget.viewModel,
                  builder: (context, _) {
                    if (widget.viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (widget.viewModel.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur de chargement',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => widget.viewModel.load.execute(),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      );
                    }

                    return VerticalPlanList(
                      plans: widget.viewModel.results,
                      isLoading: widget.viewModel.isSearching,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
