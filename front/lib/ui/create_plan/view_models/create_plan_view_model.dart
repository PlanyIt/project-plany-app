import 'dart:io';

import 'package:flutter/material.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/category/category_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/repositories/step/step_repository.dart';
import '../../../domain/models/category/category.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart' as step_model;
import '../../../domain/models/user/user.dart';
import '../../../domain/use_cases/plan/create_plan_use_case.dart';
import '../../../utils/command.dart';
import '../../../utils/helpers.dart';
import '../../../utils/result.dart';
import 'create_step_viewmodel.dart';

class CreatePlanViewModel extends ChangeNotifier {
  CreatePlanViewModel({
    required AuthRepository authRepository,
    required CategoryRepository categoryRepository,
    required PlanRepository planRepository,
    required StepRepository stepRepository,
  })  : _authRepository = authRepository,
        _categoryRepository = categoryRepository,
        _createPlanUseCase = CreatePlanUseCase(
          planRepository: planRepository,
          stepRepository: stepRepository,
        ) {
    load = Command0(_load)..execute();
  }

  final AuthRepository _authRepository;
  final CategoryRepository _categoryRepository;
  final CreatePlanUseCase _createPlanUseCase;

  late final Command0 load;

  final ValueNotifier<String> title = ValueNotifier('');
  final ValueNotifier<String> description = ValueNotifier('');
  final ValueNotifier<List<StepData>> steps = ValueNotifier([]);
  final ValueNotifier<int> currentStep = ValueNotifier(1);

  /// 🔥 Nouveaux ValueNotifier pour switches
  final ValueNotifier<bool> isPublic = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isAccessible = ValueNotifier<bool>(false);

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;
  String? _error;
  User? _user;

  AnimationController? _animationController;

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<Result> _load() async {
    try {
      _setLoading(true);
      _user = _authRepository.currentUser;

      final result = await _categoryRepository.getCategoriesList();
      if (result is Ok<List<Category>>) {
        _categories = result.value;
        return Result.ok(null);
      } else {
        _setError('Erreur lors du chargement des catégories');
        return result;
      }
    } catch (e) {
      _setError('Erreur lors du chargement des données: $e');
      return Result.error(Exception('Chargement échoué'));
    } finally {
      _setLoading(false);
    }
  }

  void addOrEditStep(StepData data, {int? index}) {
    final updated = List<StepData>.from(steps.value);
    if (index != null && index >= 0 && index < updated.length) {
      updated[index] = data;
    } else {
      updated.add(data);
    }
    steps.value = updated;
  }

  void removeStepAt(int index) {
    final updated = List<StepData>.from(steps.value)..removeAt(index);
    steps.value = updated;
  }

  void reorderSteps(int oldIndex, int newIndex) {
    final updated = List<StepData>.from(steps.value);
    if (newIndex > oldIndex) newIndex -= 1;
    final step = updated.removeAt(oldIndex);
    updated.insert(newIndex, step);
    steps.value = updated;
  }

  Future<bool> createPlan() async {
    try {
      _setLoading(true);
      _setError(null);

      if (title.value.trim().isEmpty ||
          description.value.trim().isEmpty ||
          _selectedCategory == null ||
          steps.value.isEmpty) {
        _setError('Vérifiez tous les champs avant de continuer.');
        return false;
      }

      final stepModels = <step_model.Step>[];
      final stepImages = <File?>[];

      for (var i = 0; i < steps.value.length; i++) {
        final s = steps.value[i];
        if (s.imageUrl.isEmpty) {
          _setError('L\'image est obligatoire pour l\'étape ${i + 1}');
          return false;
        }

        final formattedDuration = formatDurationToMinutes(
            '${s.duration} ${s.durationUnit?.toLowerCase()}');

        stepModels.add(step_model.Step(
          title: s.title,
          description: s.description,
          order: i + 1,
          duration: formattedDuration,
          cost: s.cost,
          latitude: s.location?.latitude,
          longitude: s.location?.longitude,
          image: s.imageUrl,
        ));

        stepImages.add(File(s.imageUrl));
      }

      final plan = Plan(
        title: title.value.trim(),
        description: description.value.trim(),
        category: _selectedCategory!,
        user: _user!,
        steps: const [],
        isPublic: isPublic.value,
        isAccessible: isAccessible.value,
      );

      final result = await _createPlanUseCase(
        plan: plan,
        steps: stepModels,
        stepImages: stepImages,
      );

      if (result is! Ok<Plan>) {
        _setError('Erreur lors de la création du plan');
        return false;
      }

      resetAllFields();
      return true;
    } catch (e) {
      _setError('Erreur interne: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void resetAllFields() {
    title.value = '';
    description.value = '';
    _selectedCategory = null;
    steps.value = [];
    isPublic.value = true;
    isAccessible.value = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<bool> handleNextStep(PageController controller) async {
    if (currentStep.value < 3) {
      if (!validateCurrentStep()) return false;

      currentStep.value++;
      _animationController?.forward();
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    } else {
      final success = await createPlan();
      return success;
    }
  }

  void handlePreviousStep(PageController controller) {
    if (currentStep.value > 1) {
      currentStep.value--;
      _animationController?.reverse();
      controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool validateCurrentStep() {
    _setError(null);
    switch (currentStep.value) {
      case 1:
        if (title.value.trim().isEmpty ||
            description.value.trim().isEmpty ||
            _selectedCategory == null) {
          _setError('Veuillez remplir tous les champs du plan.');
          return false;
        }
        return true;
      case 2:
        if (steps.value.isEmpty) {
          _setError('Ajoutez au moins une étape.');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void initAnimationController(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    steps.dispose();
    currentStep.dispose();
    isPublic.dispose();
    isAccessible.dispose();
    _animationController?.dispose();
    super.dispose();
  }
}
