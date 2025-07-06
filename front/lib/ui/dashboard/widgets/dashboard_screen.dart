import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/category/category.dart' as app_category;
import '../../../domain/models/plan/plan.dart';
import '../../../routing/routes.dart';
import '../../../widgets/card/compact_plan_card.dart';
import '../../core/ui/bottom_bar/bottom_bar.dart';
import '../view_models/dashboard_viewmodel.dart';
import 'app_bar.dart';
import 'category_cards.dart';
import 'empty_state_widget.dart';
import 'horizontal_plan_list.dart';
import 'profile_drawer.dart';
import 'search_bar.dart';
import 'section_header.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key, required this.viewModel});

  final DashboardViewModel viewModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: const BottomBar(currentIndex: 0),
      endDrawer: ProfileDrawer(
        viewModel: viewModel,
        user: viewModel.user,
        onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
        onLogout: () async => await viewModel.logout.execute(),
      ),
      appBar: DashboardAppBar(scaffoldKey: _scaffoldKey),
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          onRefresh: () => viewModel.load.execute(),
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final isLoading =
                  viewModel.load.running && !viewModel.hasLoadedData;

              return CustomScrollView(
                slivers: [
                  _buildSearchBar(context),
                  _buildSectionHeader(
                    context,
                    title: 'Catégories',
                  ),
                  _buildCategoryCardsSection(
                    context,
                    categories: viewModel.categories,
                    isLoading: isLoading,
                  ),
                  _buildSectionHeader(
                    context,
                    title: 'À proximité',
                    seeAll: true,
                    onSeeAll: () =>
                        context.pushNamed('search', queryParameters: {
                      'query': '',
                      'category': '',
                    }),
                  ),
                  _buildPlanListSection(
                    context,
                    plans: viewModel.trendingPlans,
                    isLoading: isLoading,
                    emptyMessage: 'Aucun plan à proximité disponible',
                    emptySubMessage:
                        "Consultez cette section plus tard pour découvrir de nouveaux plans",
                  ),
                  _buildSectionHeader(
                    context,
                    title: 'Tendance',
                    seeAll: true,
                    onSeeAll: () =>
                        context.pushNamed('search', queryParameters: {
                      'query': '',
                      'category': '',
                    }),
                  ),
                  _buildPlanListSection(
                    context,
                    plans: viewModel.discoveryPlans,
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
          onTap: () => context.pushNamed('search', queryParameters: {
            'query': '',
            'category': '',
          }),
          child: AbsorbPointer(
            child: DashboardSearchBar(
              hintText: 'Rechercher des plans...',
              readOnly: true,
              onTap: () => context.pushNamed(
                Routes.search,
                queryParameters: {
                  'query': '',
                  'category': '',
                },
              ),
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
        onCategoryTap: (cat) => GoRouter.of(context).pushNamed(
          'search',
          queryParameters: {
            'query': '',
            'category': cat.id,
          },
        ),
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
            viewModel.plans.length,
            (index) => CompactPlanCard(
              title: viewModel.plans[index].title,
              description: viewModel.plans[index].description,
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
        cards: [],
        onPressed: (_) {},
      ),
    );
  }
}
