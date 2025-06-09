import 'package:flutter/material.dart';
import 'package:front/domain/models/category.dart' as app_category;
import 'package:front/domain/models/plan.dart';
import 'package:front/screens/search/search_screen.dart';
import 'package:front/ui/core/ui/bottom_bar.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/widgets/common/plany_logo.dart';
import 'package:front/widgets/dashboard/category_cards.dart';
import 'package:front/widgets/dashboard/horizontal_plan_list.dart';
import 'package:front/widgets/dashboard/search_bar.dart';
import 'package:front/widgets/dashboard/section_header.dart';
import 'package:front/ui/dashboard/widgets/profile_drawer.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({
    super.key,
    required this.viewModel,
  });

  final DashboardViewModel viewModel;

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    // Initialiser avec la valeur actuelle
    _isLoadingCategories = widget.viewModel.categories.isEmpty;

    // Mettre à jour après un délai pour permettre le chargement
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    });
  }

  void _navigateToSearch(BuildContext context,
      {String? query, app_category.Category? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          initialQuery: query,
          initialCategory: category,
          autoFocus: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: ProfileDrawer(
        user: widget.viewModel.user,
        onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
        onLogout: () async {
          await widget.viewModel.logout.execute();
        },
      ),
      body: BottomBar(
        currentPage: SafeArea(
          child: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              // Rafraîchir les données du ViewModel
              await widget.viewModel.load.execute();
            },
            child: CustomScrollView(
              slivers: [
                // App Bar avec logo et bouton de profil
                _buildAppBar(),
                // Barre de recherche
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: InkWell(
                      // Change GestureDetector to InkWell for better tap feedback
                      onTap: () => _navigateToSearch(context),
                      child: AbsorbPointer(
                        // Wrap DashboardSearchBar with AbsorbPointer to prevent direct interactions
                        child: DashboardSearchBar(
                          hintText: 'Rechercher des plans...',
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
                ),

                // Section Catégories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: SectionHeader(
                        title: 'Catégories', onSeeAllPressed: () => ()
                        //_navigateToSearch(context),
                        ),
                  ),
                ),

                // Carrousel de catégories
                SliverToBoxAdapter(
                  child: CategoryCards(
                    categories: widget.viewModel.categories,
                    isLoading: _isLoadingCategories,
                    onCategoryTap: (category) =>
                        _navigateToSearch(context, category: category),
                  ),
                ),

                // Section Plans tendances
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: SectionHeader(
                      title: 'Tendances',
                      onSeeAllPressed: () => _navigateToSearch(context),
                    ),
                  ),
                ),

                // Plans tendances
                SliverToBoxAdapter(
                  child: HorizontalPlanList(
                    stepImages: widget.viewModel.stepImages,
                    plans: _getFilteredTrendingPlans(widget.viewModel.plans),
                    isLoading: widget.viewModel.plans.isEmpty,
                    getCategoryById: (categoryId) =>
                        widget.viewModel.getCategoryById(categoryId),
                    height: 250,
                    cardWidth: 200,
                    onPlanTap: (plan) {
                      // Navigation vers détail du plan
                      /*Navigator.pushNamed(context, '/details',
                            arguments: plan.id);*/
                    },
                    emptyMessage: 'Aucun plan tendance disponible',
                  ),
                ),

                // Section "À découvrir"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: SectionHeader(
                      title: 'À découvrir',
                      onSeeAllPressed: () => _navigateToSearch(context),
                    ),
                  ),
                ),

                // Plans à découvrir
                SliverToBoxAdapter(
                  child: HorizontalPlanList(
                    stepImages: widget.viewModel.stepImages,
                    plans: _getRandomPlans(widget.viewModel.plans),
                    isLoading: widget.viewModel.plans.isEmpty,
                    getCategoryById: (categoryId) =>
                        widget.viewModel.getCategoryById(categoryId),
                    height: 250,
                    cardWidth: 200,
                    onPlanTap: (plan) {
                      // Navigation vers détail du plan
                      /* Navigator.pushNamed(context, '/details',
                            arguments: plan.id);*/
                    },
                    emptyMessage: 'Aucun plan à découvrir disponible',
                  ),
                ),

                // Espace en bas
                const SliverToBoxAdapter(child: SizedBox(height: 32))
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      leading: const SizedBox.shrink(),
      backgroundColor: Colors.transparent,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const PlanyLogo(fontSize: 30),
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
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
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
            ],
          ),
        ),
      ),
    );
  }

  List<Plan> _getFilteredTrendingPlans(List<Plan> allPlans) {
    if (allPlans.isEmpty) return [];
    // Ici vous pourriez implémenter une logique pour filtrer les plans "tendance"
    // Par exemple, prendre les 5 premiers ou les trier par popularité
    return allPlans.take(5).toList();
  }

  List<Plan> _getRandomPlans(List<Plan> allPlans) {
    if (allPlans.isEmpty) return [];
    // Mélanger les plans pour avoir une découverte aléatoire
    final shuffled = List<Plan>.from(allPlans)..shuffle();
    return shuffled.take(8).toList();
  }
}
