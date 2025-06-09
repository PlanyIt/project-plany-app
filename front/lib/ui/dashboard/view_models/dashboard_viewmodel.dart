import 'package:flutter/material.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/domain/models/category.dart';
import 'package:front/domain/models/plan.dart';
import 'package:front/domain/models/user.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required CategoryRepository categoryRepository,
    required UserRepository userRepository,
    required PlanRepository planRepository,
    required StepRepository stepRepository,
  })  : _categoryRepository = categoryRepository,
        _userRepository = userRepository,
        _planRepository = planRepository,
        _stepRepository = stepRepository {
    load = Command0(_load)..execute();
  }

  final CategoryRepository _categoryRepository;
  final PlanRepository _planRepository;
  final UserRepository _userRepository;
  final StepRepository _stepRepository;
  final _log = Logger('DashboardViewModel');
  List<Category> _categories = [];
  List<Plan> _plans = [];
  User? _user;
  List<String> _stepImages = [];

  late Command0 load;

  List<Category> get categories => _categories;
  List<Plan> get plans => _plans;
  List<String> get stepImages => _stepImages;

  /// Loads categort by id
  late final Command1<void, String> categoryById;

  User? get user => _user;

  // Ajoutez ou modifiez la propriété isLoading
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<Result> _load() async {
    try {
      _log.info('Starting to load dashboard data...');

      // Load categories
      _log.info('Fetching categories...');
      final result = await _categoryRepository.getCategoriesList();
      switch (result) {
        case Ok<List<Category>>():
          _categories = result.value;
          _log.info('Successfully loaded ${_categories.length} categories');
        case Error<List<Category>>():
          _log.severe('Failed to load categories', result.error);
          return result;
      }

      // Load plans
      _log.info('Fetching plans...');
      final planResult = await _planRepository.getPlanList();
      switch (planResult) {
        case Ok<List<Plan>>():
          _plans = planResult.value;
          _log.fine('Loaded plans');
        case Error<List<Plan>>():
          _log.warning('Failed to load plans', planResult.error);
          return planResult;
      }

      // Load steps for each plan
      _log.info('Fetching steps for each plan...');
      List<String> allStepImages = [];
      for (final plan in _plans) {
        for (final stepId in plan.steps) {
          final stepResult = await _stepRepository.getStepById(stepId);
          switch (stepResult) {
            case Ok(value: final step):
              if (step.image.isNotEmpty) {
                allStepImages.add(step.image);
              }
            case Error():
              _log.warning('Failed to load step with ID: $stepId');
          }
        }
      }
      _stepImages = allStepImages;

      _log.info('Total step images loaded: ${_stepImages.length}');

      // Load user
      _log.info('Fetching user profile...');
      final userResult = await _userRepository.getUser();
      switch (userResult) {
        case Ok<User>():
          _user = userResult.value;
          _log.fine('Loaded user');
        case Error<User>():
          _log.warning('Failed to load user', userResult.error);
      }

      return userResult;
    } catch (e, stackTrace) {
      _log.severe('Unexpected error in _load()', e, stackTrace);
      return Result<void>.error(Exception('Unexpected error: $e'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Result<Category>> getCategoryById(String id) async {
    final result = await _categoryRepository.getCategoryById(id);
    switch (result) {
      case Ok<Category>():
        _log.fine('Loaded category by id: $id');
        return result;
      case Error<Category>():
        _log.warning('Failed to load category by id: $id', result.error);
        return result;
    }
  }
}
