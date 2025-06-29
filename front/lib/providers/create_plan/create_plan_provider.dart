import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as plan_steps;
import 'package:front/domain/models/category/category.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/utils/result.dart';

// État pour la création de plan
class CreatePlanState {
  final bool isLoading;
  final String? error;
  final List<Category> categories;
  final Category? selectedCategory;
  final List<plan_steps.Step> steps;
  final String planTitle;
  final String planDescription;

  const CreatePlanState({
    this.isLoading = false,
    this.error,
    this.categories = const [],
    this.selectedCategory,
    this.steps = const [],
    this.planTitle = '',
    this.planDescription = '',
  });

  CreatePlanState copyWith({
    bool? isLoading,
    String? error,
    List<Category>? categories,
    Category? selectedCategory,
    List<plan_steps.Step>? steps,
    String? planTitle,
    String? planDescription,
  }) {
    return CreatePlanState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      steps: steps ?? this.steps,
      planTitle: planTitle ?? this.planTitle,
      planDescription: planDescription ?? this.planDescription,
    );
  }
}

class CreatePlanNotifier extends StateNotifier<CreatePlanState> {
  CreatePlanNotifier(
    this._planRepository,
    this._categoryRepository,
  ) : super(const CreatePlanState());

  final PlanRepository _planRepository;
  final CategoryRepository _categoryRepository;

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true);

    final result = await _categoryRepository.getCategoriesList();
    switch (result) {
      case Ok<List<Category>>():
        state = state.copyWith(
          categories: result.value,
          isLoading: false,
        );
        break;
      case Error<List<Category>>():
        state = state.copyWith(
          error: 'Erreur lors du chargement des catégories',
          isLoading: false,
        );
        break;
    }
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

    state = state.copyWith(isLoading: true);

    final plan = Plan(
      title: state.planTitle,
      description: state.planDescription,
      category: state.selectedCategory!.id,
      steps: [], // Les étapes seront ajoutées après
    );

    final result = await _planRepository.createPlan(plan);
    switch (result) {
      case Ok<Plan>():
        state = state.copyWith(isLoading: false);
        return true;
      case Error<Plan>():
        state = state.copyWith(
          error: 'Erreur lors de la création du plan',
          isLoading: false,
        );
        return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const CreatePlanState();
  }
}
