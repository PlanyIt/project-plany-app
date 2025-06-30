import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/core/utils/result.dart' as result_utils;
import 'package:front/providers/providers.dart';
import 'package:front/providers/ui/unified_state_management.dart';

class DashboardState extends UnifiedState {
  final List<Category> categories;
  final List<Plan> plans;
  final User? user;
  final String searchQuery;
  final Category? selectedCategory;

  const DashboardState({
    this.categories = const [],
    this.plans = const [],
    this.user,
    this.searchQuery = '',
    this.selectedCategory,
    super.isLoading = false,
    super.error,
    super.isInitialized = false,
  });

  DashboardState copyWith({
    List<Category>? categories,
    List<Plan>? plans,
    User? user,
    String? searchQuery,
    Category? selectedCategory,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return DashboardState(
      categories: categories ?? this.categories,
      plans: plans ?? this.plans,
      user: user ?? this.user,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  DashboardState copyWithBase({
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return copyWith(
      isLoading: isLoading,
      error: error,
      isInitialized: isInitialized,
    );
  }

  @override
  DashboardState clearError() {
    return copyWith(error: null);
  }

  @override
  DashboardState reset() {
    return const DashboardState();
  }
}

class DashboardNotifier extends StateNotifier<DashboardState>
    with UnifiedStateManagement<DashboardState> {
  DashboardNotifier(
    this._categoryRepository,
    this._planRepository,
    this._userRepository,
  ) : super(const DashboardState());

  final CategoryRepository _categoryRepository;
  final PlanRepository _planRepository;
  final UserRepository _userRepository;

  Future<void> loadInitialData() async {
    await executeWithStateManagement(
      () async {
        // Load categories
        final categoriesResult = await _categoryRepository.getCategoriesList();
        final plansResult = await _planRepository.getPlanList();
        final userResult = await _userRepository.getCurrentUser();

        List<Category> categories = [];
        List<Plan> plans = [];
        User? user;
        switch (categoriesResult) {
          case result_utils.Ok():
            categories = categoriesResult.value;
          case result_utils.Error():
            throw Exception('Erreur lors du chargement des catégories');
        }

        switch (plansResult) {
          case result_utils.Ok():
            plans = plansResult.value;
          case result_utils.Error():
            throw Exception('Erreur lors du chargement des plans');
        }

        switch (userResult) {
          case result_utils.Ok():
            user = userResult.value;
          case result_utils.Error():
            // User is optional for dashboard
            break;
        }

        state = state.copyWith(
          categories: categories,
          plans: plans,
          user: user,
        );
      },
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(Category? category) {
    state = state.copyWith(selectedCategory: category);
  }

  List<Plan> get filteredPlans {
    var filtered = state.plans;

    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((plan) =>
              plan.title
                  .toLowerCase()
                  .contains(state.searchQuery.toLowerCase()) ||
              plan.description
                  .toLowerCase()
                  .contains(state.searchQuery.toLowerCase()))
          .toList();
    }

    if (state.selectedCategory != null) {
      filtered = filtered
          .where((plan) => plan.category == state.selectedCategory!.id)
          .toList();
    }

    return filtered;
  }

  void clearDashboardError() {
    clearError();
  }
}

// Utiliser StateNotifierProvider pour une gestion d'état cohérente avec Riverpod
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    ref.read(categoryRepositoryProvider),
    ref.read(planRepositoryProvider),
    ref.read(userRepositoryProvider),
  );
});
