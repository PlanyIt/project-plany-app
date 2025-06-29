import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/providers/dashboard/dashboard_provider.dart';
import 'package:front/utils/result.dart';

import 'package:front/widgets/tag/cutom_chip.dart';
import 'package:front/ui/dashboard/widgets/search_bar/search_bar.dart';
import 'package:front/ui/core/ui/card/compact_plan_card.dart';
import 'package:front/providers/providers.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final Category? initialCategory;
  final bool autoFocus;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
    this.autoFocus = false,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }

    if (widget.initialQuery?.isNotEmpty == true) {
      _onSearchChanged(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(dashboardProvider.notifier).updateSearchQuery(value);
    });
  }

  void _applyFilters() {
    // Apply filters through dashboard provider
    // This would need to be implemented in the dashboard provider
  }
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final dashboardState = ref.watch(dashboardProvider);
        final filteredPlans =
            dashboardState.plans; // Utiliser plans au lieu de filteredPlans

        return Scaffold(
          appBar: _buildSearchBar(ref),
          body: Column(
            children: [
              if (dashboardState.selectedCategory != null ||
                  dashboardState.searchQuery.isNotEmpty)
                _buildActiveFilters(),
              Expanded(
                child: dashboardState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : dashboardState.error != null
                        ? Center(child: Text('Erreur: ${dashboardState.error}'))
                        : filteredPlans.isEmpty
                            ? _buildEmptyView()
                            : _buildVerticalPlanList(filteredPlans),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildSearchBar(WidgetRef ref) {
    return AppBar(
      title: DashboardSearchBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        autofocus: widget.autoFocus,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _applyFilters,
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return Consumer(
      builder: (context, ref, child) {
        final dashboardState = ref.watch(dashboardProvider);
        final List<Widget> filters = [];

        if (dashboardState.selectedCategory != null) {
          filters.add(
            CustomChip(
              label: dashboardState.selectedCategory!.name,
              onTap: () =>
                  ref.read(dashboardProvider.notifier).selectCategory(null),
              showCloseIcon: true,
              isSelected: true,
            ),
          );
        }

        if (filters.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters,
          ),
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun plan trouvé',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalPlanList(List<Plan> plans) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Consumer(
            builder: (context, ref, child) {
              return FutureBuilder<Category?>(
                future: _getCategoryById(plan.category, ref),
                builder: (context, snapshot) {
                  final category = snapshot.data;
                  return CompactPlanCard(
                    title: plan.title,
                    description: plan.description,
                    category: category,
                    stepsCount: plan.steps.length,
                    onTap: () {
                      // Navigate to plan details
                      context.push('/details-plan', extra: plan.id);
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<Category?> _getCategoryById(String categoryId, WidgetRef ref) async {
    final categoryRepository = ref.read(categoryRepositoryProvider);
    final result = await categoryRepository.getCategoryById(categoryId);
    return result is Ok<Category> ? result.value : null;
  }
}
