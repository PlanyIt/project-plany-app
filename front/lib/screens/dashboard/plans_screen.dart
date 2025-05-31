import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/models/categorie.dart';
import 'package:front/models/plan.dart';
import 'package:front/models/step.dart' as StepModel;
import 'package:front/providers/plan_provider.dart';
import 'package:front/screens/create-plan/create_plans_screen.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/utils/helpers.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/widgets/card/plan_card.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  PlansScreenState createState() => PlansScreenState();
}

class PlansScreenState extends State<PlansScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController;
  bool _isSearching = false;
  String _searchQuery = "";
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Charger les catégories
      final categoryService = CategorieService();
      final categories = await categoryService.getCategories();

      // S'assurer qu'il y a au moins une catégorie "Tous"
      if (!categories.any((c) => c.name == "Tous")) {
        categories.insert(0, Category(id: "all", name: "Tous", icon: "list"));
      }

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;

        // Initialiser le TabController après avoir chargé les catégories
        _tabController = TabController(length: _categories.length, vsync: this);
      });
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() {
        _isLoadingCategories = false;
        _categories = [Category(id: "all", name: "Tous", icon: "list")];
        _tabController = TabController(length: _categories.length, vsync: this);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          Provider.of<PlanProvider>(context, listen: false).fetchPlans();
        } catch (e) {
          print('Erreur lors du chargement des plans: $e');
        }
      }
    });
  }

  void _navigateToDetails(String planId) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: planId,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF8F9FA),
                const Color(0xFFE8EEF7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildSearchAndFilter(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Provider.of<PlanProvider>(context, listen: false)
                          .fetchPlans();
                    },
                    child: _buildPlansList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _isSearching = value.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: "Rechercher un plan...",
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                            _isSearching = false;
                          });
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.all(15),
              ),
            ),
          ),
        ),

        // Categories Carousel
        _buildCategoriesCarousel(),
      ],
    );
  }

  Widget _buildCategoriesCarousel() {
    if (_isLoadingCategories) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
          height: 4,
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF3425B5),
          ),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _tabController?.index == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _tabController?.animateTo(index);
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    getIconData(
                      category.icon,
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[800],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlansList() {
    return Consumer<PlanProvider>(
      builder: (context, planProvider, child) {
        if (planProvider.isLoading) {
          return _buildLoadingView();
        }

        if (planProvider.plans.isEmpty) {
          return _buildEmptyView();
        }

        // Filtrer les plans selon la recherche et la catégorie
        final filteredPlans = planProvider.plans.where((plan) {
          final matchesSearch = _searchQuery.isEmpty ||
              plan.title.toLowerCase().contains(_searchQuery.toLowerCase());

          if (_categories.isEmpty || _tabController == null) {
            return matchesSearch;
          }

          final selectedCategory = _categories[_tabController!.index];
          final matchesCategory = selectedCategory.name == "Tous" ||
              plan.category == selectedCategory.id;

          return matchesSearch && matchesCategory;
        }).toList();

        if (filteredPlans.isEmpty) {
          return _buildNoResultsView();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPlans.length,
          itemBuilder: (context, index) {
            final plan = filteredPlans[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPlanCard(plan),
            );
          },
        );
      },
    );
  }

  Widget _buildPlanCard(Plan plan) {
    // Récupérer les étapes du plan pour calculer le coût total et la durée
    return FutureBuilder<Map<String, dynamic>>(
      future: _getStepData(plan.steps),
      builder: (context, snapshot) {
        // Initialiser des valeurs par défaut
        String? cost;
        String? duration;
        List<String>? imageUrls;

        // Si les données sont chargées, mettre à jour les valeurs
        if (snapshot.hasData) {
          final data = snapshot.data!;
          cost = "${data['cost'].toStringAsFixed(0)} €";
          duration = data['duration'];
          imageUrls = data['imageUrls'];
        }

        return Hero(
          tag: 'plan-${plan.id}',
          child: PlanCard(
            title: plan.title,
            description: plan.description,
            imageUrls: imageUrls,
            category: _getCategoryFromId(plan.category),
            stepsCount: plan.steps.length,
            cost: cost,
            duration: duration,
            onTap: () => _navigateToDetails(plan.id!),
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // Fonction pour récupérer les données des étapes (images, coût, durée)
  Future<Map<String, dynamic>> _getStepData(List<String> stepIds) async {
    final stepService = StepService();
    List<String> imageUrls = [];
    List<StepModel.Step> steps = [];

    try {
      // Récupérer les steps
      for (final stepId in stepIds) {
        final step = await stepService.getStepById(stepId);
        if (step != null) {
          steps.add(step);

          if (step.image != null && step.image!.isNotEmpty) {
            imageUrls.add(step.image!);
          }
        }
      }

      // Calculer le coût total et la durée à l'aide des helpers
      final totalCost = calculateTotalStepsCost(steps);
      final totalDuration = calculateTotalStepsDuration(steps);

      return {
        'imageUrls': imageUrls,
        'cost': totalCost,
        'duration': totalDuration,
      };
    } catch (e) {
      print('Erreur lors de la récupération des données des étapes: $e');
      return {
        'imageUrls': <String>[],
        'cost': 0.0,
        'duration': "0 minute",
      };
    }
  }

// Récupérer la catégorie à partir de son ID
  Category _getCategoryFromId(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return Category(id: categoryId, name: categoryId, icon: "category");
    }
  }

  Widget _buildLoadingView() {
    // Mise à jour pour la vue de chargement
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Carousel d'images des steps amélioré avec gestion d'état
  Widget _buildStepImagesCarousel(Plan plan) {
    // Si aucun step, afficher un placeholder
    if (plan.steps.isEmpty) {
      return _buildImagePlaceholder();
    }

    return _StepImagesCarousel(
      stepIds: plan.steps,
      category: plan.category,
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    // Trouver le nom de la catégorie à partir de l'ID
    final categoryName = _categories
        .firstWhere((c) => c.id == category,
            orElse: () =>
                Category(id: category, name: category, icon: "category"))
        .name;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF3425B5).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        categoryName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_plans.png',
            width: 150,
            height: 150,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.description_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucun plan disponible",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Commencez par créer votre premier plan",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreatePlansScreen()),
              ).then((_) {
                Provider.of<PlanProvider>(context, listen: false).fetchPlans();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3425B5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Créer un plan"),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucun résultat trouvé",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Essayez avec d'autres termes de recherche",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget séparé pour gérer le carrousel d'images avec son propre état
class _StepImagesCarousel extends StatefulWidget {
  final List<String> stepIds;
  final String category;

  const _StepImagesCarousel({
    required this.stepIds,
    required this.category,
  });

  @override
  _StepImagesCarouselState createState() => _StepImagesCarouselState();
}

class _StepImagesCarouselState extends State<_StepImagesCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (_controller.page != null && _controller.page!.round() != _currentPage) {
      setState(() {
        _currentPage = _controller.page!.round();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPageChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Carrousel des images
        PageView.builder(
          controller: _controller,
          itemCount: widget.stepIds.length,
          itemBuilder: (context, index) {
            // Chargement de l'image du step via FutureBuilder
            return FutureBuilder<String?>(
              future: _getStepImageUrl(widget.stepIds[index]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return Image.network(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  );
                }

                return _buildImagePlaceholder();
              },
            );
          },
        ),

        // Indicateurs de pagination
        if (widget.stepIds.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.stepIds.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? const Color(0xFF3425B5)
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

        // Badge catégorie
        Positioned(
          top: 10,
          left: 10,
          child: _buildCategoryBadge(widget.category),
        ),
      ],
    );
  }

  // Méthode pour récupérer l'URL de l'image d'un step à partir de son ID
  Future<String?> _getStepImageUrl(String stepId) async {
    try {
      final stepService = StepService();
      final step = await stepService.getStepById(stepId);
      print(step?.image);
      return step?.image;
    } catch (e) {
      print('Erreur lors de la récupération de l\'image du step: $e');
      return null;
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String categoryId) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF3425B5).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        categoryId, // On utilise l'ID directement comme texte dans le widget enfant
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
