import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/utils/result.dart';

class DashboardState {
  final List<Category> categories;
  final List<Plan> plans;
  final User? user;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final Category? selectedCategory;

  const DashboardState({
    this.categories = const [],
    this.plans = const [],
    this.user,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
  });

  DashboardState copyWith({
    List<Category>? categories,
    List<Plan>? plans,
    User? user,
    bool? isLoading,
    String? error,
    String? searchQuery,
    Category? selectedCategory,
  }) {
    return DashboardState(
      categories: categories ?? this.categories,
      plans: plans ?? this.plans,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(
    this._categoryRepository,
    this._planRepository,
    this._userRepository,
  ) : super(const DashboardState());

  final CategoryRepository _categoryRepository;
  final PlanRepository _planRepository;
  final UserRepository _userRepository;

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load categories
      final categoriesResult = await _categoryRepository.getCategoriesList();
      final plansResult = await _planRepository.getPlanList();
      final userResult = await _userRepository.getCurrentUser();

      List<Category> categories = [];
      List<Plan> plans = [];
      User? user;

      switch (categoriesResult) {
        case Ok():
          categories = categoriesResult.value;
        case Error():
          state = state.copyWith(
              isLoading: false,
              error: 'Erreur lors du chargement des catégories');
          return;
      }

      switch (plansResult) {
        case Ok():
          plans = plansResult.value;
        case Error():
          state = state.copyWith(
              isLoading: false, error: 'Erreur lors du chargement des plans');
          return;
      }

      switch (userResult) {
        case Ok():
          user = userResult.value;
        case Error():
          // User is optional for dashboard
          break;
      }

      state = state.copyWith(
        categories: categories,
        plans: plans,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur inattendue: $e',
      );
    }
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}
