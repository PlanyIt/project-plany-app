import 'package:flutter/material.dart';
import 'package:front/domain/models/category/category.dart' as app_category;
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/ui/dashboard/widgets/card/category_cards.dart';
import 'package:front/ui/dashboard/widgets/list/horizontal_plan_list.dart';
import 'package:front/ui/dashboard/widgets/screen/search_screen.dart';
import 'package:front/ui/core/ui/bottom_bar/bottom_bar.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/widgets/common/plany_logo.dart';
import 'package:front/ui/dashboard/widgets/placeholder/empty_state_widget.dart';
import 'package:front/ui/dashboard/widgets/search_bar/search_bar.dart';
import 'package:front/ui/dashboard/widgets/header/section_header.dart';
import 'package:front/ui/dashboard/widgets/drawer/profile_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:front/utils/result.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.viewModel});
  final DashboardViewModel viewModel;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardViewModel get viewModel => widget.viewModel;
  @override
  void initState() {
    super.initState();

    // Éviter d'appeler load pendant le build en utilisant addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!viewModel.hasLoadedData) {
        viewModel.load.execute();
      }
    });

    viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _navigateToSearch(
      {String? query,
      app_category.Category? category,
      bool fromSearchBar = false}) {
    // Mettre à jour les filtres de recherche dans le viewModel
    if (query != null) viewModel.searchQuery = query;
    if (category != null) viewModel.selectedCategory = category;

    // Déclencher une recherche avec les nouveaux filtres
    viewModel.load.execute();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          viewModel: viewModel,
          initialQuery: query,
          initialCategory: category,
          autoFocus:
              fromSearchBar, // Uniquement autofocus si on vient de la barre de recherche
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = !viewModel.hasLoadedData && viewModel.load.running;

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: const BottomBar(currentIndex: 0),
      endDrawer: ProfileDrawer(
        user: viewModel.user,
        onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
        onLogout: () async => await viewModel.logout.execute(),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const PlanyLogo(fontSize: 30),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              child: Hero(
                tag: 'profileAvatar',
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(
                      Icons.person_outline,
                      color: Theme.of(context).primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          onRefresh: () => viewModel.load.execute(),
          child: CustomScrollView(
            slivers: [
              _buildSearchBar(),
              _buildSectionHeader('Catégories'),
              SliverToBoxAdapter(
                child: CategoryCards(
                  categories: viewModel.categories,
                  isLoading: isLoading,
                  onCategoryTap: (cat) =>
                      _navigateToSearch(category: cat, fromSearchBar: false),
                ),
              ),
              _buildSectionHeader('Tendances', seeAll: true),
              _buildPlanListSection(
                plans: _getFilteredTrendingPlans(viewModel.plans),
                isLoading: isLoading,
                emptyMessage: 'Aucun plan tendance disponible',
              ),
              _buildSectionHeader('À découvrir', seeAll: true),
              _buildPlanListSection(
                plans: _getRandomPlans(viewModel.plans),
                isLoading: isLoading,
                emptyMessage: 'Aucun plan à découvrir disponible',
                emptySubMessage:
                    'Consultez cette section plus tard pour découvrir de nouveaux plans',
                emptyIcon: Icons.explore_off_rounded,
                accentColor: Theme.of(context).colorScheme.secondary,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: InkWell(
          onTap: () => _navigateToSearch(
              fromSearchBar:
                  true), // Activer l'autofocus quand on tape sur la barre de recherche
          child: AbsorbPointer(
            child: DashboardSearchBar(
              hintText: 'Rechercher des plans...',
              readOnly: true,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title, {bool seeAll = false}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: SectionHeader(
          title: title,
          onSeeAllPressed:
              seeAll ? () => _navigateToSearch(fromSearchBar: false) : null,
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildPlanListSection({
    required List<Plan> plans,
    required bool isLoading,
    required String emptyMessage,
    String? emptySubMessage,
    IconData emptyIcon = Icons.trending_up_rounded,
    Color? accentColor,
  }) {
    if (isLoading) {
      return SliverToBoxAdapter(
        child: HorizontalPlanList(
          plans: const [],
          planSteps: const {},
          isLoading: true,
          getCategoryById: (id) async => Result.error(Exception('Chargement')),
          onPlanTap: (_) {},
          emptyMessage: '',
        ),
      );
    }

    if (plans.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyStateWidget(
          message: emptyMessage,
          subMessage: emptySubMessage,
          icon: emptyIcon,
          accentColor: accentColor ?? Theme.of(context).primaryColor,
        ),
      );
    }
    return SliverToBoxAdapter(
      child: HorizontalPlanList(
        plans: plans,
        planSteps: viewModel.planSteps,
        isLoading: false,
        getCategoryById: viewModel.getCategoryById,
        onPlanTap: (plan) => GoRouter.of(context).pushNamed(
          'detailsPlan',
          queryParameters: {'planId': plan.id},
        ),
        emptyMessage: '',
        userLatitude: viewModel.userLatitude,
        userLongitude: viewModel.userLongitude,
      ),
    );
  }

  List<Plan> _getFilteredTrendingPlans(List<Plan> plans) =>
      plans.take(5).toList();

  List<Plan> _getRandomPlans(List<Plan> plans) => List.of(plans)..shuffle();
}
