import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/models/category.dart' as app_category;
import 'package:front/models/plan.dart';
import 'package:front/providers/plan_provider.dart';
import 'package:front/screens/search/search_screen.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/widgets/card/plan_card.dart';
import 'package:front/widgets/common/plany_logo.dart';
import 'package:front/widgets/dashboard/category_cards.dart';
import 'package:front/widgets/dashboard/horizontal_plan_list.dart';
import 'package:front/widgets/dashboard/search_bar.dart';
import 'package:front/widgets/dashboard/section_header.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

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

  void _navigateToDetails(String planId) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: planId,
    );
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
                SliverAppBar(
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
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                              child: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Icon(
                                  Icons.person_outline,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

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

  Widget _buildTrendingShimmer() {
    return Container(
      height: 270,
      margin: const EdgeInsets.only(top: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemBuilder: (context, index) {
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildTrendingSection(List<Plan> plans) {
    if (plans.isEmpty) {
      return const SizedBox(
        height: 270,
        child: Center(
          child: Text('Aucun plan tendance disponible'),
        ),
      );
    }

    // Prendre les 5 premiers plans ou ceux avec le plus d'étapes pour les "tendances"
    final trendingPlans = plans.take(5).toList();

    return Container(
      height: 300,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trendingPlans.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final plan = trendingPlans[index];
          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 16),
            child: FutureBuilder<List<String>>(
              future: _getStepImages(plan.steps),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }
                return PlanCard(
                  title: plan.title,
                  description: plan.description,
                  imageUrls: snapshot.data,
                  category: _getCategoryById(plan.category),
                  stepsCount: plan.steps.length,
                  onTap: () => _navigateToDetails(plan.id!),
                  borderRadius: BorderRadius.circular(16),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscoverShimmer() {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(top: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildDiscoverSection(List<Plan> plans) {
    if (plans.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text('Aucun plan à découvrir disponible'),
        ),
      );
    }

    // Pour les plans à découvrir, on peut prendre un ordre différent
    // Par exemple, les plans les plus récents ou filtrer par une catégorie spécifique
    final discoverPlans = List<Plan>.from(plans)..shuffle();
    final displayPlans = discoverPlans.take(8).toList();

    return Container(
      height: 300,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayPlans.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final plan = displayPlans[index];
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 16),
            child: FutureBuilder<List<String>>(
              future: _getStepImages(plan.steps),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }
                return PlanCard(
                  title: plan.title,
                  description: plan.description,
                  imageUrls: snapshot.data,
                  category: _getCategoryById(plan.category),
                  stepsCount: plan.steps.length,
                  onTap: () => _navigateToDetails(plan.id!),
                  borderRadius: BorderRadius.circular(16),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Category? _getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> _getStepImages(List<String> stepIds) async {
    final images = <String>[];
    final stepService = StepService();
    
    for (String id in stepIds) {
      try {
        final step = await stepService.getStepById(id);
        if (step != null && step.image.isNotEmpty) {
          images.add(step.image);
        }
      } catch (e) {
        print('Erreur lors de la récupération de l\'image pour step $id: $e');
      }
    }
    
    if (images.isEmpty) {
      images.add('https://via.placeholder.com/300x200/EDEDED/888888?text=Plany');
    }
    
    return images;
  }
  
}
