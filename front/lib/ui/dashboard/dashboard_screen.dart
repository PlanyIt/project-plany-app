import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/category/category.dart' as app_category;
import '../../domain/models/plan/plan.dart';
import '../../widgets/card/compact_plan_card.dart';
import '../core/ui/bottom_bar/bottom_bar.dart';
import 'view_models/dashboard_viewmodel.dart';
import 'widgets/app_bar.dart';
import 'widgets/category_cards.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/horizontal_plan_list.dart';
import 'widgets/profile_drawer.dart';
import 'widgets/search_bar.dart';
import 'widgets/section_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    // Gestion des erreurs via SnackBar
    if (widget.viewModel.hasError && widget.viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () {
                widget.viewModel.clearError();
                widget.viewModel.load.execute();
              },
            ),
          ),
        );
        widget.viewModel.clearError();
      });
    }

    // Gestion de la navigation
    final navigationEvent = widget.viewModel.navigationEvent;
    if (navigationEvent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNavigation(navigationEvent);
        widget.viewModel.clearNavigationEvent();
      });
    }
  }

  void _handleNavigation(NavigationEvent event) {
    switch (event.type) {
      case 'search':
        context.pushNamed('search', queryParameters: {
          'query': event.data['query'] ?? '',
          'category': event.data['category'] ?? '',
        });
        break;
      case 'plan':
        context.push('/plan/${event.data['planId']}');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: const BottomBar(currentIndex: 0),
      endDrawer: ProfileDrawer(
        viewModel: widget.viewModel,
        onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
        onLogout: () async => await widget.viewModel.logout.execute(),
      ),
      appBar: DashboardAppBar(scaffoldKey: _scaffoldKey),
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          onRefresh: () => widget.viewModel.load.execute(),
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              final isLoading = widget.viewModel.load.running &&
                  !widget.viewModel.hasLoadedData;

              return CustomScrollView(
                slivers: [
                  _buildSearchBar(context),
                  _buildSectionHeader(
                    context,
                    title: 'Catégories',
                  ),
                  _buildCategoryCardsSection(
                    context,
                    categories: widget.viewModel.categories,
                    isLoading: isLoading,
                  ),
                  _buildSectionHeader(
                    context,
                    title: 'À proximité',
                    seeAll: true,
                    onSeeAll: () => widget.viewModel.navigateToSearch(),
                  ),
                  _buildPlanListSection(
                    context,
                    plans: widget.viewModel.trendingPlans,
                    isLoading: isLoading,
                    emptyMessage: 'Aucun plan à proximité disponible',
                    emptySubMessage:
                        "Consultez cette section plus tard pour découvrir de nouveaux plans",
                  ),
                  _buildSectionHeader(
                    context,
                    title: 'Tendance',
                    seeAll: true,
                    onSeeAll: () => widget.viewModel.navigateToSearch(),
                  ),
                  _buildPlanListSection(
                    context,
                    plans: widget.viewModel.discoveryPlans,
                    isLoading: isLoading,
                    emptyMessage: 'Aucun plan à découvrir disponible',
                    emptySubMessage:
                        'Consultez cette section plus tard pour découvrir de nouveaux plans',
                    emptyIcon: Icons.explore_off_rounded,
                    accentColor: Theme.of(context).colorScheme.secondary,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: InkWell(
          onTap: () => widget.viewModel.navigateToSearch(),
          child: AbsorbPointer(
            child: DashboardSearchBar(
              hintText: 'Rechercher des plans...',
              readOnly: true,
              onTap: () => widget.viewModel.navigateToSearch(),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(
    BuildContext context, {
    required String title,
    bool seeAll = false,
    VoidCallback? onSeeAll,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: SectionHeader(
          title: title,
          onPressed: () => context.go(
            seeAll ? '/search' : '/',
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCardsSection(
    BuildContext context, {
    required List<app_category.Category> categories,
    required bool isLoading,
  }) {
    if (isLoading) {
      return SliverToBoxAdapter(
        child: CategoryCards(
          categories: [],
          isLoading: true,
          onCategoryTap: (_) {},
        ),
      );
    }

    if (categories.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyStateWidget(
          message: 'Aucune catégorie disponible',
          subMessage:
              'Revenez plus tard pour découvrir de nouvelles catégories',
          icon: Icons.category_outlined,
          accentColor: Theme.of(context).primaryColor,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: CategoryCards(
        categories: categories,
        isLoading: false,
        onCategoryTap: (cat) =>
            widget.viewModel.navigateToSearch(category: cat.id),
      ),
    );
  }

  SliverToBoxAdapter _buildPlanListSection(
    BuildContext context, {
    required List<Plan> plans,
    required bool isLoading,
    required String emptyMessage,
    String? emptySubMessage,
    IconData emptyIcon = Icons.map_outlined,
    Color? accentColor,
  }) {
    if (isLoading) {
      return SliverToBoxAdapter(
        child: HorizontalPlanList(
          isLoading: true,
          cards: List.generate(
            widget.viewModel.plans.length,
            (index) => CompactPlanCard(
              title: widget.viewModel.plans[index].title,
              description: widget.viewModel.plans[index].description,
            ),
          ),
          onPressed: (_) {},
        ),
      );
    }

    if (plans.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyStateWidget(
          message: emptyMessage,
          subMessage: emptySubMessage,
          icon: Icons.map_outlined,
          accentColor: accentColor ?? Theme.of(context).primaryColor,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: HorizontalPlanList(
        isLoading: false,
        cards: plans
            .map((plan) => CompactPlanCard(
                  title: plan.title,
                  description: plan.description,
                ))
            .toList(),
        onPressed: (index) =>
            widget.viewModel.navigateToPlan(plans[index].id ?? ''),
      ),
    );
  }
}
