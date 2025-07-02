import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/domain/models/category/category.dart' as app_category;
import 'package:front/providers/plan_provider.dart';
import 'package:front/screens/search/search_screen.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/ui/core/ui/logo/plany_logo.dart';
import 'package:front/ui/dashboard/widgets/card/category_cards.dart';
import 'package:front/ui/dashboard/widgets/list/horizontal_plan_list.dart';
import 'package:front/ui/dashboard/widgets/search_bar/search_bar.dart';
import 'package:front/ui/dashboard/widgets/header/section_header.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/plan/plan.dart';

class DashboardHomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const DashboardHomeScreen({
    super.key,
    this.onProfileTap,
  });

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  List<app_category.Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlanProvider>(context, listen: false).fetchPlans();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategorieService().getCategories();
      if (mounted) {
        setState(() {
          _categories = List<app_category.Category>.from(categories);
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du chargement des catégories: $e");
      }
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
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

  app_category.Category? _getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              await _loadCategories();
              await planProvider.fetchPlans();
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
                      title: 'Catégories',
                      onSeeAllPressed: () => _navigateToSearch(context),
                    ),
                  ),
                ),

                // Carrousel de catégories
                SliverToBoxAdapter(
                  child: CategoryCards(
                    categories: _categories,
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
                    plans: _getFilteredTrendingPlans(planProvider.plans),
                    isLoading: planProvider.isLoading,
                    getCategoryById: (categoryId) =>
                        _getCategoryById(categoryId as String),
                    height: 250,
                    cardWidth: 200,
                    onPlanTap: (plan) {
                      // Navigation vers détail du plan
                      Navigator.pushNamed(context, '/details',
                          arguments: plan.id);
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
                    plans: _getRandomPlans(planProvider.plans),
                    isLoading: planProvider.isLoading,
                    getCategoryById: (categoryId) =>
                        _getCategoryById(categoryId as String),
                    height: 250, // Augmenter la hauteur pour le carousel
                    cardWidth: 200,
                    onPlanTap: (plan) {
                      // Navigation vers détail du plan
                      Navigator.pushNamed(context, '/details',
                          arguments: plan.id);
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
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const PlanyLogo(fontSize: 30),
              GestureDetector(
                onTap: widget.onProfileTap,
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
