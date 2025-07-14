import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/location_service.dart';
import '../../routing/routes.dart';
import '../core/ui/list/vertical_plan_list.dart';
import '../core/ui/search_bar/search_bar.dart';
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
  bool _isUpdatingController = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }

    widget.viewModel.setInitialFilters(categoryId: widget.initialCategory);
    widget.viewModel.addListener(_syncSearchController);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_syncSearchController);
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

  void _syncSearchController() {
    if (_isUpdatingController) return;

    final currentQuery =
        widget.viewModel.filtersViewModel.locationSearchQuery ?? '';
    if (currentQuery != _searchController.text) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isUpdatingController) {
          _isUpdatingController = true;
          _searchController.text = currentQuery;
          _isUpdatingController = false;
        }
      });
    }
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
                  ),
                ),
                const SizedBox(width: 12),
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
          Expanded(
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
          ),
        ],
      ),
    );
  }
}
