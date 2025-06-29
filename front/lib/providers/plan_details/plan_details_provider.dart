import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as plan_steps;
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/repositories/comment/comment_repository.dart';
import 'package:front/utils/result.dart';

// État pour les détails d'un plan
class PlanDetailsState {
  final bool isLoading;
  final String? error;
  final Plan? plan;
  final List<plan_steps.Step> steps;
  final Category? category;
  final User? author;
  final List<Comment> comments;
  final bool isFavorite;

  const PlanDetailsState({
    this.isLoading = false,
    this.error,
    this.plan,
    this.steps = const [],
    this.category,
    this.author,
    this.comments = const [],
    this.isFavorite = false,
  });

  PlanDetailsState copyWith({
    bool? isLoading,
    String? error,
    Plan? plan,
    List<plan_steps.Step>? steps,
    Category? category,
    User? author,
    List<Comment>? comments,
    bool? isFavorite,
  }) {
    return PlanDetailsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      plan: plan ?? this.plan,
      steps: steps ?? this.steps,
      category: category ?? this.category,
      author: author ?? this.author,
      comments: comments ?? this.comments,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class PlanDetailsNotifier extends StateNotifier<PlanDetailsState> {
  PlanDetailsNotifier(
    this._planRepository,
    this._stepRepository,
    this._categoryRepository,
    this._userRepository,
    this._commentRepository,
  ) : super(const PlanDetailsState());

  final PlanRepository _planRepository;
  final StepRepository _stepRepository;
  final CategoryRepository _categoryRepository;
  final UserRepository _userRepository;
  final CommentRepository _commentRepository;

  Future<void> loadPlan(String planId) async {
    state = state.copyWith(isLoading: true);

    final planResult = await _planRepository.getPlanById(planId);
    switch (planResult) {
      case Ok<Plan>():
        final plan = planResult.value;
        state = state.copyWith(plan: plan);

        // Charger les données associées
        await Future.wait([
          _loadSteps(plan.steps),
          _loadCategory(plan.category),
          _loadAuthor(plan.userId),
          _loadComments(planId),
        ]);

        state = state.copyWith(isLoading: false);
        break;
      case Error<Plan>():
        state = state.copyWith(
          error: 'Erreur lors du chargement du plan',
          isLoading: false,
        );
        break;
    }
  }

  Future<void> _loadSteps(List<String> stepIds) async {
    final List<plan_steps.Step> steps = [];
    for (final stepId in stepIds) {
      final result = await _stepRepository.getStepById(stepId);
      if (result is Ok<plan_steps.Step>) {
        steps.add(result.value);
      }
    }
    state = state.copyWith(steps: steps);
  }

  Future<void> _loadCategory(String categoryId) async {
    final result = await _categoryRepository.getCategoryById(categoryId);
    if (result is Ok<Category>) {
      state = state.copyWith(category: result.value);
    }
  }

  Future<void> _loadAuthor(String? userId) async {
    if (userId != null) {
      final result = await _userRepository.getUserProfile(userId);
      if (result is Ok<User>) {
        state = state.copyWith(author: result.value);
      }
    }
  }

  Future<void> _loadComments(String planId) async {
    final result = await _commentRepository.getCommentsByPlanId(planId);
    if (result is Ok<List<Comment>>) {
      state = state.copyWith(comments: result.value);
    }
  }

  Future<void> toggleFavorite() async {
    if (state.plan == null) return;

    final result = state.isFavorite
        ? await _planRepository.removeFromFavorites(state.plan!.id!)
        : await _planRepository.addToFavorites(state.plan!.id!);

    if (result is Ok) {
      state = state.copyWith(isFavorite: !state.isFavorite);
    }
  }

  Future<void> addComment(Comment comment) async {
    final result = await _commentRepository.createComment(comment);
    if (result is Ok<Comment>) {
      final updatedComments = [...state.comments, result.value];
      state = state.copyWith(comments: updatedComments);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
