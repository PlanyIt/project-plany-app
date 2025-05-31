import 'package:flutter/material.dart';
import 'package:front/models/categorie.dart';
import 'package:front/models/plan.dart';
import 'package:front/providers/plan_provider.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/widgets/card/plan_card.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final Category? initialCategory;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;
  String _searchQuery = "";
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _showFilterSheet = false;
  bool _isLoadingFilters = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _searchQuery = widget.initialQuery ?? '';
    _selectedCategory = widget.initialCategory;

    _loadFilters();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<PlanProvider>(context, listen: false).fetchPlans();
      }
    });
  }

  Future<void> _loadFilters() async {
    try {
      // Charger les catégories
      final categories = await CategorieService().getCategories();

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingFilters = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des filtres: $e');
      if (mounted) {
        setState(() {
          _isLoadingFilters = false;
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

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);

    // Filtrer les plans selon la recherche, la catégorie
    final filteredPlans = planProvider.plans.where((plan) {
      // Match par recherche texte
      final matchesSearch = _searchQuery.isEmpty ||
          plan.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plan.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Match par catégorie
      final matchesCategory =
          _selectedCategory == null || plan.category == _selectedCategory!.id;



      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: _buildSearchBar(),
      body: Stack(
        children: [
          // Contenu principal
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildContent(filteredPlans, planProvider),
          ),

          // Bottom sheet des filtres
          if (_showFilterSheet) _buildFilterSheet(),
        ],
      ),
    );
  }

  AppBar _buildSearchBar() {
    return AppBar(
      titleSpacing: 0,
      title: Container(
        height: 45,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(23),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onTap: () {
            setState(() {
              _isSearchFocused = true;
            });
          },
          onSubmitted: (value) {
            setState(() {
              _isSearchFocused = false;
            });
          },
          decoration: InputDecoration(
            hintText: 'Rechercher...',
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.filter_list),
              if (_selectedCategory != null)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      (_selectedCategory != null ? 1 : 0) >
                              9
                          ? '9+'
                          : '${(_selectedCategory != null ? 1 : 0)}',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            setState(() {
              _showFilterSheet = !_showFilterSheet;
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(List<Plan> filteredPlans, PlanProvider planProvider) {
    if (planProvider.isLoading) {
      return _buildLoadingView();
    }

    if (filteredPlans.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPlans.length,
      itemBuilder: (context, index) {
        final plan = filteredPlans[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FutureBuilder<List<String>>(
            future: _getStepImages(plan.steps),
            builder: (context, snapshot) {
              final imageUrls = snapshot.data ??
                  ['https://via.placeholder.com/300x200/EDEDED/888888?text=Plany'];
              return PlanCard(
                title: plan.title,
                description: plan.description,
                imageUrls: imageUrls,
                category: _getCategoryById(plan.category),
                stepsCount: plan.steps.length,
                onTap: () => _navigateToDetails(plan.id!),

              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 180,
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

  Widget _buildEmptyView() {
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
            "Aucun résultat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Modifiez vos critères de recherche",
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {}, // Empêche la propagation du tap pour fermer le sheet
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtres',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showFilterSheet = false;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Catégories
              Text(
                'Catégorie',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),

              if (_isLoadingFilters)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory?.id == category.id;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                getIconData(category.icon),
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                              const SizedBox(width: 6),
                              Text(category.name),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategory = category;
                              } else {
                                _selectedCategory = null;
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showFilterSheet = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),

              // Espace pour le padding en bas
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
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
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
