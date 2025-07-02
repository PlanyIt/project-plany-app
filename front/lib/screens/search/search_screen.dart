import 'dart:async';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/providers/plan_provider.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/widgets/card/compact_plan_card.dart';
import 'package:front/widgets/tag/cutom_chip.dart';
import 'package:front/ui/dashboard/widgets/search_bar/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final Category? initialCategory;
  final bool autoFocus;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
    this.autoFocus = false,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = "";
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _showFilterSheet = false;
  bool _isLoadingFilters = true;

  // Ajout d'un timer pour la fonction de debounce
  Timer? _debounce;

  // Ajout des attributs pour les filtres de coût et durée
  RangeValues _costRange = const RangeValues(0, 1000);
  RangeValues _durationRange =
      const RangeValues(0, 1440); // en minutes (24h max)

  // Valeurs max pour les sliders
  final double _maxCostValue = 1000;
  final double _maxDurationValue = 1440; // 24 heures en minutes

  // Option de tri sélectionnée
  String? _sortBy;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _searchQuery = widget.initialQuery ?? '';
    _selectedCategory = widget.initialCategory;

    _loadFilters();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Charger les plans avec les filtres par défaut
        _searchPlansWithFilters();

        // Donner le focus au champ de recherche si demandé
        if (widget.autoFocus) {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        }
      }
    });
  }

  // Mise à jour de la méthode pour rechercher des plans avec filtres
  Future<void> _searchPlansWithFilters() async {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    try {
      setState(() {
        // Montrer un indicateur de chargement si nécessaire
      });

      if (kDebugMode) {
        print('Recherche avec query: "$_searchQuery"');
      }

      await planProvider.searchPlansWithFilters(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        categoryId: _selectedCategory?.id,
        minCost: _costRange.start == 0 ? null : _costRange.start,
        maxCost: _costRange.end == _maxCostValue ? null : _costRange.end,
        minDuration:
            _durationRange.start == 0 ? null : _durationRange.start.toInt(),
        maxDuration: _durationRange.end == _maxDurationValue
            ? null
            : _durationRange.end.toInt(),
        sortBy: _sortBy,
        ascending: _sortAscending,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la recherche: $e');
      }
    }
  }

  Future<void> _loadFilters() async {
    try {
      final categories = await CategorieService().getCategories();

      if (mounted) {
        setState(() {
          _categories = categories.cast<Category>();
          _isLoadingFilters = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des filtres: $e');
      }
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

    // Filtrer localement les plans si nécessaire
    final List<Plan> filteredPlans = _searchQuery.isNotEmpty
        ? _applyLocalSearchFilter(planProvider.plans)
        : planProvider.plans;

    if (kDebugMode && filteredPlans.length != planProvider.plans.length) {
      print(
          'Filtrage local: ${planProvider.plans.length} → ${filteredPlans.length} plans');
    }

    return Scaffold(
      // Add resizeToAvoidBottomInset to handle keyboard properly
      resizeToAvoidBottomInset: true,
      appBar: _buildSearchBar(),
      body: Stack(
        children: [
          // Contenu principal
          Column(
            children: [
              // Indicateurs de filtres actifs
              if (_selectedCategory != null) _buildActiveFilters(),

              // Liste des résultats
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildContent(filteredPlans, planProvider),
                ),
              ),
            ],
          ),

          // Bottom sheet des filtres
          if (_showFilterSheet) _buildFilterOverlay(),
        ],
      ),
    );
  }

  AppBar _buildSearchBar() {
    return AppBar(
      toolbarHeight: 80,
      titleSpacing: 0,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8),
        child: Hero(
          tag: 'searchBar',
          child: DashboardSearchBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: widget.autoFocus,
            onChanged: (value) {
              // Fermer la bottomsheet si elle est ouverte lorsqu'on tape dans la recherche
              if (_showFilterSheet) {
                setState(() {
                  _showFilterSheet = false;
                });
              }

              setState(() {
                _searchQuery = value;
              });

              // Ajouter un délai avant de déclencher la recherche (debounce)
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _searchPlansWithFilters();
                }
              });
            },
            onSubmitted: (value) {
              // S'assurer que la bottomsheet est fermée lors de la soumission
              if (_showFilterSheet) {
                setState(() {
                  _showFilterSheet = false;
                });
              }
              // Déclencher immédiatement la recherche lors de la soumission
              _searchPlansWithFilters();
            },
            onTap: () {
              // Fermer la bottomsheet lorsqu'on clique sur la barre de recherche
              if (_showFilterSheet) {
                setState(() {
                  _showFilterSheet = false;
                });
              }
            },
            hintText: 'Rechercher...',
          ),
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: (_selectedCategory != null)
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
              onPressed: () {
                // Ne pas afficher le filtre si le clavier est visible
                if (MediaQuery.of(context).viewInsets.bottom > 0) {
                  // D'abord fermer le clavier
                  FocusScope.of(context).unfocus();
                  // Puis attendre que le clavier se ferme avant d'ouvrir le filtre
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      setState(() {
                        _showFilterSheet = !_showFilterSheet;
                      });
                    }
                  });
                } else {
                  setState(() {
                    _showFilterSheet = !_showFilterSheet;
                  });
                }
              },
            ),
            if (_selectedCategory != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${(_selectedCategory != null ? 1 : 0)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Nouvelle méthode pour formater la durée en minutes
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomChip(
                  label: _selectedCategory!.name,
                  icon: getIconData(_selectedCategory!.icon),
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                    _searchPlansWithFilters();
                  },
                  isSelected: true,
                  showCloseIcon: true,
                ),
              ),
            if (_costRange.start > 0 || _costRange.end < _maxCostValue)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomChip(
                  label:
                      '${_costRange.start.toInt()}€-${_costRange.end.toInt()}€',
                  icon: Icons.euro,
                  onTap: () {
                    setState(() {
                      _costRange = RangeValues(0, _maxCostValue);
                    });
                    _searchPlansWithFilters();
                  },
                  isSelected: true,
                  showCloseIcon: true,
                ),
              ),
            if (_durationRange.start > 0 ||
                _durationRange.end < _maxDurationValue)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomChip(
                  label:
                      '${_formatDuration(_durationRange.start.toInt())}-${_formatDuration(_durationRange.end.toInt())}',
                  icon: Icons.access_time,
                  onTap: () {
                    setState(() {
                      _durationRange = RangeValues(0, _maxDurationValue);
                    });
                    _searchPlansWithFilters();
                  },
                  isSelected: true,
                  showCloseIcon: true,
                ),
              ),
            if (_sortBy != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomChip(
                  label:
                      'Tri: ${_sortBy == 'cost' ? 'Coût' : 'Durée'} ${_sortAscending ? '↓' : '↑'}',
                  icon: _sortBy == 'cost' ? Icons.euro : Icons.access_time,
                  onTap: () {
                    setState(() {
                      _sortBy = null;
                    });
                    _searchPlansWithFilters();
                  },
                  isSelected: true,
                  showCloseIcon: true,
                ),
              ),
            if (_selectedCategory != null ||
                _costRange.start > 0 ||
                _costRange.end < _maxCostValue ||
                _durationRange.start > 0 ||
                _durationRange.end < _maxDurationValue ||
                _sortBy != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _costRange = RangeValues(0, _maxCostValue);
                    _durationRange = RangeValues(0, _maxDurationValue);
                    _sortBy = null;
                    _sortAscending = true;
                  });
                  _searchPlansWithFilters();
                },
                child: Text(
                  'Effacer tout',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<Plan> filteredPlans, PlanProvider planProvider) {
    if (planProvider.isLoading) {
      return _buildLoadingView();
    }

    if (filteredPlans.isEmpty) {
      return _buildEmptyView();
    }

    // Utiliser une ListView.builder avec caching pour améliorer les performances
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPlans.length,
      // Ajouter physics pour un meilleur défilement
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      // Optimisation de la construction des éléments avec keys uniques
      itemBuilder: (context, index) {
        final plan = filteredPlans[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          // Utiliser une clé pour éviter les reconstructions inutiles
          key: ValueKey('plan-${plan.id}'),
          child: _buildPlanItem(plan, planProvider, index),
        );
      },
      // Ajouter un cacheExtent pour précharger les items
      cacheExtent: 500,
    );
  }

  Widget _buildPlanItem(Plan plan, PlanProvider planProvider, int index) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeInOut,
      child: FutureBuilder<List<dynamic>>(
        future: _getPlanData(plan, planProvider),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildPlanLoadingItem();
          }

          if (snapshot.hasError) {
            return _buildPlanErrorItem(plan);
          }

          final data = snapshot.data;
          final images =
              data != null && data.length > 0 ? data[0] as List<String> : null;
          final cost =
              data != null && data.length > 1 ? data[1] as double : null;
          final duration =
              data != null && data.length > 2 ? data[2] as int : null;

          // Utiliser un Material pour avoir un feedback tactile
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Navigation vers la page de détail du plan
                _navigateToPlanDetail(plan);
              },
              child: CompactPlanCard(
                title: plan.title,
                description: plan.description,
                imageUrls: images,
                category: _getCategoryById(plan.category),
                stepsCount: plan.steps.length,
                totalCost: cost,
                totalDuration: duration,
                onTap: () => _navigateToPlanDetail(plan),
              ),
            ),
          );
        },
      ),
    );
  }

  // Optimiser en utilisant un cache Map pour stocker les données des plans
  final Map<String, Future<List<dynamic>>> _planDataCache = {};

  Future<List<dynamic>> _getPlanData(Plan plan, PlanProvider planProvider) {
    final String planId = plan.id ?? 'unknown';
    // Utiliser le cache si disponible
    if (_planDataCache.containsKey(planId)) {
      return _planDataCache[planId]!;
    }

    final future = Future.wait([
      _getStepImages(plan),
      planProvider.calculatePlanTotalCost(plan),
      planProvider.calculatePlanTotalDuration(plan),
    ]);

    _planDataCache[planId] = future;
    return future;
  }

  void _navigateToPlanDetail(Plan plan) {
    // Fermer le clavier et les filtres d'abord
    FocusScope.of(context).unfocus();
    if (_showFilterSheet) {
      setState(() {
        _showFilterSheet = false;
      });
    }

    // TODO: Implémenter la navigation vers la page de détail
    // Navigator.push(context, MaterialPageRoute(...));
  }

  Widget _buildPlanLoadingItem() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanErrorItem(Plan plan) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 32),
            const SizedBox(height: 8),
            Text(
              plan.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Erreur de chargement",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour récupérer les images des étapes
  Future<List<String>> _getStepImages(Plan plan) async {
    final stepService = StepService();
    final List<String> images = [];

    // Limiter à 5 étapes maximum pour éviter trop de requêtes
    final stepsToFetch =
        plan.steps.length > 5 ? plan.steps.sublist(0, 5) : plan.steps;

    for (final stepId in stepsToFetch) {
      try {
        final step = await stepService.getStepById(stepId);
        if (step != null && step.image != null && step.image!.isNotEmpty) {
          images.add(step.image!);
        }
      } catch (e) {
        // Ignorer les erreurs de chargement d'images
      }
    }
    return images;
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

  Widget _buildFilterOverlay() {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          // Close the keyboard first
          FocusScope.of(context).unfocus();
          // Then close the filter sheet after a small delay
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _showFilterSheet = false;
              });
            }
          });
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _buildFilterSheet(),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSheet() {
    return GestureDetector(
      onTap: () {}, // Prevent tap propagation
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: NotificationListener<LayoutChangedNotification>(
          onNotification: (notification) {
            // Si le clavier apparaît, fermer le filtre
            if (MediaQuery.of(context).viewInsets.bottom > 0 &&
                _showFilterSheet) {
              setState(() {
                _showFilterSheet = false;
              });
              return true;
            }
            return false;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtres',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
              ),

              const Divider(),

              // Content with scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories
                      Text(
                        'Catégorie',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),

                      if (_isLoadingFilters)
                        const Center(child: CircularProgressIndicator())
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _categories.map((category) {
                            final isSelected =
                                _selectedCategory?.id == category.id;
                            return CustomChip(
                              label: category.name,
                              icon: getIconData(category.icon),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedCategory = null;
                                  } else {
                                    _selectedCategory = category;
                                  }
                                });
                              },
                              isSelected: isSelected,
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 24),

                      // Options de tri
                      Text(
                        'Trier par',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Options de tri
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          CustomChip(
                            label: 'Pertinence',
                            icon: Icons.sort,
                            onTap: () {
                              setState(() {
                                _sortBy = null;
                              });
                            },
                            isSelected: _sortBy == null,
                          ),
                          CustomChip(
                            label: 'Coût ${_sortAscending ? '↓' : '↑'}',
                            icon: Icons.euro,
                            onTap: () {
                              setState(() {
                                if (_sortBy == 'cost') {
                                  _sortAscending = !_sortAscending;
                                } else {
                                  _sortBy = 'cost';
                                  _sortAscending = true;
                                }
                              });
                              _searchPlansWithFilters();
                            },
                            isSelected: _sortBy == 'cost',
                          ),
                          CustomChip(
                            label: 'Durée ${_sortAscending ? '↓' : '↑'}',
                            icon: Icons.access_time,
                            onTap: () {
                              setState(() {
                                if (_sortBy == 'duration') {
                                  _sortAscending = !_sortAscending;
                                } else {
                                  _sortBy = 'duration';
                                  _sortAscending = true;
                                }
                              });
                              _searchPlansWithFilters();
                            },
                            isSelected: _sortBy == 'duration',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom + 8
                      : MediaQuery.of(context).padding.bottom + 16,
                  top: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _costRange = const RangeValues(0, 1000);
                            _durationRange = const RangeValues(0, 1440);
                            _sortBy = null;
                            _sortAscending = true;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                          _searchPlansWithFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
              ),
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

  @override
  void dispose() {
    // Annuler le timer de debounce lors de la destruction du widget
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose(); // Libérer le FocusNode
    super.dispose();
  }

  // Ajouter un filtrage local pour s'assurer que la recherche fonctionne
  List<Plan> _applyLocalSearchFilter(List<Plan> plans) {
    if (_searchQuery.isEmpty) return plans;

    final query = _searchQuery.toLowerCase();
    return plans.where((plan) {
      return plan.title.toLowerCase().contains(query) ||
          plan.description.toLowerCase().contains(query);
    }).toList();
  }
}
