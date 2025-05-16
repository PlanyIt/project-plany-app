import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/models/categorie.dart';
import 'package:front/models/plan.dart';
import 'package:front/providers/plan_provider.dart';
import 'package:front/screens/search/search_screen.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/widgets/card/plan_card.dart';
import 'package:front/widgets/common/plany_logo.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  final TextEditingController _searchController = TextEditingController();

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
        // Vérifier si le widget est toujours monté
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des catégories: $e");
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  void _navigateToSearch(BuildContext context,
      {String? query, Category? category}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(
            initialQuery: query,
            initialCategory: category,
          ),
        ));
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
                          CircleAvatar(
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person_outline,
                              color: Theme.of(context).primaryColor,
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
                    child: GestureDetector(
                      onTap: () => _navigateToSearch(context),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Rechercher un plan...',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.tune,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Section Catégories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Catégories',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                        ),
                        TextButton(
                          onPressed: () => _navigateToSearch(context),
                          child: Text(
                            'Voir tout',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Carrousel de catégories
                SliverToBoxAdapter(
                  child: _isLoadingCategories
                      ? _buildCategoryShimmer()
                      : _buildCategoryCarousel(),
                ),

                // Section Plans tendances
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tendances",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                        ),
                        TextButton(
                          onPressed: () => _navigateToSearch(context),
                          child: Text(
                            'Voir tout',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Plans tendances
                SliverToBoxAdapter(
                  child: planProvider.isLoading
                      ? _buildTrendingShimmer()
                      : _buildTrendingSection(planProvider.plans),
                ),

                // Section "À découvrir"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "À découvrir",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                        ),
                        TextButton(
                          onPressed: () => _navigateToSearch(context),
                          child: Text(
                            'Voir tout',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Plans à découvrir (peut être filtrés autrement que les tendances)
                SliverToBoxAdapter(
                  child: planProvider.isLoading
                      ? _buildDiscoverShimmer()
                      : _buildDiscoverSection(planProvider.plans),
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

  Widget _buildCategoryCarousel() {
    print(
        "Construction du carrousel de catégories. Nombre: ${_categories.length}");

    if (_categories.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('Aucune catégorie disponible'),
        ),
      );
    }

    // Palette de couleurs harmonisées avec le thème existant
    final List<List<Color>> categoryGradients = [
      [const Color(0xFF6C63FF), const Color(0xFF837DFF)], // Secondaire
      [const Color(0xFFFF7B9C), const Color(0xFFFF5C84)], // Accent
      [const Color(0xFF3F8CFF), const Color(0xFF1F78FF)], // Bleu vif
      [const Color(0xFF7250DE), const Color(0xFF5E41C2)], // Violet royal
      [const Color(0xFF3AB6BC), const Color(0xFF2DA0A6)], // Turquoise
      [const Color(0xFFFF6B6B), const Color(0xFFFF5252)], // Rouge vif
      [const Color(0xFF9C42F5), const Color(0xFF8333E1)], // Violet électrique
      [const Color(0xFF00B8A9), const Color(0xFF00A396)], // Vert menthe
      [const Color(0xFFFF8A48), const Color(0xFFFF7730)], // Orange moderne
      [const Color(0xFF6A0572), const Color(0xFF4E0058)], // Violet sombre
    ];

    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final gradientColors =
              categoryGradients[index % categoryGradients.length];

          return GestureDetector(
            onTap: () => _navigateToSearch(context, category: category),
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[1].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: Stack(
                children: [
                  // Éléments décoratifs modernes
                  Positioned(
                    top: -15,
                    right: -15,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Contenu principal avec meilleur contraste
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            getIconData(category.icon),
                            color: gradientColors[0],
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return Container(
      height: 140, // Hauteur correspondant à la nouvelle taille des cartes
      margin: const EdgeInsets.only(top: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemBuilder: (context, index) {
            return Container(
              width:
                  110, // Largeur correspondant à la nouvelle taille des cartes
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            );
          },
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
      height: 270,
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
            child: PlanCard(
              title: plan.title,
              description: plan.description,
              imageUrls: plan.steps,
              category: _getCategoryById(plan.category),
              tags: const [], // À enrichir si vous avez les tags
              stepsCount: plan.steps.length,
              onTap: () {
                // Naviguer vers la page de détail du plan
                // Navigator.push...
              },
              borderRadius: BorderRadius.circular(16),
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
      height: 220,
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
            child: PlanCard(
              title: plan.title,
              description: plan.description,
              imageUrls: plan.steps,
              category: _getCategoryById(plan.category),
              tags: const [], // À enrichir si vous avez les tags
              stepsCount: plan.steps.length,
              onTap: () {
                // Naviguer vers la page de détail du plan
              },
              borderRadius: BorderRadius.circular(16),
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
}
