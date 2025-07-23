
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/services/location_service.dart';
import '../../domain/models/category/category.dart' as app_category;
import '../../domain/models/plan/plan.dart';
import '../../routing/routes.dart';
import '../core/ui/bottom_bar/bottom_bar.dart';
import '../core/ui/card/compact_plan_card.dart';
import '../core/ui/list/horizontal_plan_list.dart';
import '../core/ui/placeholder/empty_state_widget.dart';
import '../core/ui/search_bar/search_bar.dart';
import 'view_models/dashboard_viewmodel.dart';
import 'widgets/app_bar.dart';
import 'widgets/category_cards.dart';
import 'widgets/profile_drawer.dart';
import 'widgets/section_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final bool isInTest = bool.fromEnvironment('IS_TEST');

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationService = context.read<LocationService>();
      if (!isInTest &&
          !locationService.hasLocation &&
          !locationService.isLoading) {
        locationService.getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (widget.viewModel.hasError && widget.viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
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
        }
      });
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
          onRefresh: () async {
            if (!isInTest) {
              await context
                  .read<LocationService>()
                  .getCurrentLocation(forceRefresh: true);
            }
            return widget.viewModel.load.execute();
          },
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              final isLoading = widget.viewModel.load.running &&
                  !widget.viewModel.hasLoadedData;

              return CustomScrollView(
                slivers: [
                  _buildSearchBar(context),
                  _buildLocationStatus(context),
                  _buildSectionHeader(context,
                      title: 'Catégories',
                      seeAll: true,
                      onSeeAll: () => {
                            context.go('/search'),
                          }),
                  _buildCategoryCardsSection(
                    context,
                    categories: widget.viewModel.categories,
                    isLoading: isLoading,
                  ),
                  _buildSectionHeader(context,
                      title: 'À proximité',
                      seeAll: true,
                      onSeeAll: () => {
                            context.go('/search'),
                          }),
                  _buildNearbyPlansSection(context, isLoading: isLoading),
                  _buildSectionHeader(context,
                      title: 'Populaire',
                      seeAll: true,
                      onSeeAll: () => {
                            context.go('/search'),
                          }),
                  _buildPlanListSection(
                    context,
                    plans: widget.viewModel.discoveryPlans,
                    isLoading: isLoading,
                    emptyMessage: 'Aucun plan disponible',
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
          onTap: () => context.go('/search'),
          child: AbsorbPointer(
            child: DashboardSearchBar(
                hintText: 'Rechercher des plans...',
                readOnly: true,
                onTap: () => context.go('/search')),
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
          onPressed: seeAll && onSeeAll != null ? onSeeAll : () {},
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
          viewModel: widget.viewModel,
          onPressed: (category) => context
              .go('/search?category=${Uri.encodeComponent(category.id)}'),
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
        viewModel: widget.viewModel,
        onPressed: (category) =>
            context.go('/search?category=${Uri.encodeComponent(category.id)}'),
      ),
    );
  }

  /// Widget pour afficher le statut de la géolocalisation
  Widget _buildLocationStatus(BuildContext context) {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        if (locationService.isLoading) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Localisation en cours...',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (locationService.errorMessage != null) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      locationService.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      if (!isInTest && locationService.serviceDisabled) {
                        await locationService.requestLocationService();
                      }
                      await locationService.getCurrentLocation(
                          forceRefresh: true);
                    },
                    icon: Icon(
                      Icons.refresh,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                    label: Text(
                      'Réessayer',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (locationService.hasLocation) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Position actualisée',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      await locationService.getCurrentLocation(
                          forceRefresh: true);
                    },
                    icon: Icon(
                      Icons.my_location,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    label: Text(
                      'Actualiser',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  /// Section pour les plans à proximité
  Widget _buildNearbyPlansSection(BuildContext context,
      {required bool isLoading}) {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        final nearbyPlans = widget.viewModel.nearbyPlans;

        if (isLoading || locationService.isLoading) {
          return _buildPlanListSection(
            context,
            plans: [],
            isLoading: true,
            emptyMessage: 'Chargement des plans à proximité...',
          );
        }

        if (!locationService.hasLocation) {
          return _buildPlanListSection(
            context,
            plans: [],
            isLoading: false,
            emptyMessage:
                'Activez la géolocalisation pour voir les plans à proximité',
            emptySubMessage: 'Aucun plan à proximité sans géolocalisation',
          );
        }

        if (nearbyPlans.isEmpty) {
          return _buildPlanListSection(
            context,
            plans: [],
            isLoading: false,
            emptyMessage: 'Aucun plan à moins de 10km',
            emptySubMessage: 'Aucun plan disponible à proximité',
            showDistance: false,
          );
        }

        return _buildPlanListSection(
          context,
          plans: nearbyPlans,
          isLoading: false,
          emptyMessage: 'Plans à proximité',
          emptySubMessage: 'Triés du plus proche au plus loin',
          showDistance: true,
        );
      },
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
    bool showDistance = false,
  }) {
    if (isLoading) {
      return SliverToBoxAdapter(
        child: HorizontalPlanList(
          isLoading: true,
          cards: List.generate(
            3,
            (index) => CompactPlanCard(
              title: '',
              description: '',
              category: null,
              user: null,
              imageUrl: null,
              stepsCount: 0,
              totalCost: 0,
              totalDuration: 0,
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
          icon: emptyIcon,
          accentColor: accentColor ?? Theme.of(context).primaryColor,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: HorizontalPlanList(
        isLoading: isLoading,
        cards: plans
            .map((plan) => CompactPlanCard(
                  title: plan.title,
                  description: plan.description,
                  category: plan.category,
                  user: plan.user,
                  imageUrl:
                      plan.steps.isNotEmpty ? plan.steps.first.image : null,
                  stepsCount: plan.steps.length,
                  totalCost: plan.totalCost,
                  totalDuration: plan.totalDuration,
                  distance: showDistance
                      ? widget.viewModel.getFormattedDistanceForPlan(plan)
                      : null,
                ))
            .toList(),
        onPressed: (index) =>
            context.push('${Routes.planDetails}?id=${plans[index].id}'),
      ),
    );
  }
}
