import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as plan_steps;
import 'package:front/domain/models/category/category.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/core/utils/result.dart';
import 'package:front/providers/providers.dart';
import 'package:front/providers/ui/unified_state_management.dart';

// État pour la création de plan
class CreatePlanState extends UnifiedState {
  final List<Category> categories;
  final Category? selectedCategory;
  final List<plan_steps.Step> steps;
  final String planTitle;
  final String planDescription;

  const CreatePlanState({
    this.categories = const [],
    this.selectedCategory,
    this.steps = const [],
    this.planTitle = '',
    this.planDescription = '',
    super.isLoading = false,
    super.error,
    super.isInitialized = false,
  });

  CreatePlanState copyWith({
    List<Category>? categories,
    Category? selectedCategory,
    List<plan_steps.Step>? steps,
    String? planTitle,
    String? planDescription,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return CreatePlanState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      steps: steps ?? this.steps,
      planTitle: planTitle ?? this.planTitle,
      planDescription: planDescription ?? this.planDescription,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  CreatePlanState copyWithBase({
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
  CreatePlanState clearError() {
    return copyWith(error: null);
  }

  @override
  CreatePlanState reset() {
    return const CreatePlanState();
  }
}

class CreatePlanNotifier extends StateNotifier<CreatePlanState>
    with UnifiedStateManagement<CreatePlanState> {
  CreatePlanNotifier(
    this._planRepository,
    this._categoryRepository,
  ) : super(const CreatePlanState());

  final PlanRepository _planRepository;
  final CategoryRepository _categoryRepository;

  Future<void> loadCategories() async {
    await executeWithStateManagement(
      () async {
        final result = await _categoryRepository.getCategoriesList();
        switch (result) {
          case Ok<List<Category>>():
            state = state.copyWith(categories: result.value);
            break;
          case Error<List<Category>>():
            throw Exception('Erreur lors du chargement des catégories');
        }
      },
    );
  }

  void setCategory(Category category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setPlanInfo(String title, String description) {
    state = state.copyWith(
      planTitle: title,
      planDescription: description,
    );
  }

  void addStep(plan_steps.Step step) {
    final updatedSteps = [...state.steps, step];
    state = state.copyWith(steps: updatedSteps);
  }

  void removeStep(int index) {
    final updatedSteps = [...state.steps];
    updatedSteps.removeAt(index);
    state = state.copyWith(steps: updatedSteps);
  }

  void updateStep(int index, plan_steps.Step step) {
    final updatedSteps = [...state.steps];
    updatedSteps[index] = step;
    state = state.copyWith(steps: updatedSteps);
  }

  Future<bool> createPlan() async {
    if (state.selectedCategory == null || state.planTitle.isEmpty) {
      state = state.copyWith(
          error: 'Veuillez remplir tous les champs obligatoires');
      return false;
    }

    return await executeWithStateManagement(
          () async {
            final plan = Plan(
              title: state.planTitle,
              description: state.planDescription,
              category: state.selectedCategory!.id,
              steps: [],
            );

            final result = await _planRepository.createPlan(plan);
            switch (result) {
              case Ok<Plan>():
                return true;
              case Error<Plan>():
                throw Exception('Erreur lors de la création du plan');
            }
          },
        ) ??
        false;
  }

  void clearCreatePlanError() {
    clearError();
  }

  void reset() {
    resetState();
  }
}

final createPlanProvider =
    StateNotifierProvider<CreatePlanNotifier, CreatePlanState>((ref) {
  return CreatePlanNotifier(
    ref.read(planRepositoryProvider),
    ref.read(categoryRepositoryProvider),
  );
});
