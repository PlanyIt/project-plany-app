import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/comment/comment_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/navigation_service.dart';
import '../../../domain/models/category/category.dart' as custom_category;
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart' as custom_step;
import '../../../domain/models/user/user.dart';
import '../../../utils/command.dart';
import '../../../utils/helpers.dart';
import '../../../utils/result.dart';
import 'comment_viewmodel.dart';

class PlanDetailsViewModel extends ChangeNotifier {
  PlanDetailsViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required CommentRepository commentRepository,
    required PlanRepository planRepository,
  })  : _commentRepository = commentRepository,
        _authRepository = authRepository,
        _planRepository = planRepository,
        _userRepository = userRepository {
    _commentViewModel = CommentViewModel(
      commentRepository: _commentRepository,
      authRepository: _authRepository,
      userRepository: _userRepository,
      planId: '',
      currentUserId: _authRepository.currentUser,
    );

    load = Command0(_load)..execute();
  }

  Plan? _plan;
  int _currentStepIndex = 0;
  bool _showStepInfo = false;
  double? _distanceToStep;
  bool _isCalculatingDistance = false;
  late CommentViewModel _commentViewModel;
  late Command0 load;

  final CommentRepository _commentRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final PlanRepository _planRepository;

  // === Getters ===
  bool get isPlanInitialized => _plan != null;
  CommentViewModel get commentViewModel => _commentViewModel;
  User? get currentUser => _authRepository.currentUser;
  int get currentStepIndex => _currentStepIndex;
  bool get showStepInfo => _showStepInfo;
  bool get isCalculatingDistance => _isCalculatingDistance;
  double? get distanceToSelectedStep => _distanceToStep;

  Plan get plan {
    if (_plan == null) {
      throw StateError('Plan not set in PlanDetailsViewModel');
    }
    return _plan!;
  }

  List<custom_step.Step> get steps => plan.steps;
  String get planTitle => plan.title;
  String get planDescription => plan.description;
  custom_category.Category? get planCategory => plan.category;
  String? get planCategoryIcon => plan.category?.icon;
  String get planId => plan.id ?? '';
  Color? get planCategoryColor =>
      colorFromPlanCategory(plan.category?.color ?? '');

  custom_step.Step? get selectedStep =>
      (_currentStepIndex >= 0 && _currentStepIndex < steps.length)
          ? steps[_currentStepIndex]
          : null;

  // === Setter ===
  void setPlan(Plan newPlan) {
    _plan = newPlan;
    _commentViewModel = CommentViewModel(
      commentRepository: _commentRepository,
      authRepository: _authRepository,
      userRepository: _userRepository,
      planId: newPlan.id ?? '',
      currentUserId: _authRepository.currentUser,
    );
    notifyListeners();
  }

  Future<Result> _load() async {
    try {
      if (_plan == null) {
        throw StateError('Plan not set in PlanDetailsViewModel');
      }
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to load plan details: $e'));
    }
  }

  // === Step Selection Logic ===
  Future<void> selectStep(int index) async {
    if (index < 0 || index >= steps.length) return;

    _currentStepIndex = index;
    _showStepInfo = true;
    _distanceToStep = null;
    notifyListeners();

    await _calculateDistanceToStep(steps[index]);
  }

  void closeStepInfo() {
    _showStepInfo = false;
    notifyListeners();
  }

  Future<void> _calculateDistanceToStep(custom_step.Step step) async {
    if (step.position == null) return;

    _isCalculatingDistance = true;
    notifyListeners();

    try {
      final distance = LocationService().calculateDistanceToPoint(
        step.position!.latitude,
        step.position!.longitude,
      );
      _distanceToStep = distance;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du calcul de distance : $e");
      }
    } finally {
      _isCalculatingDistance = false;
      notifyListeners();
    }
  }

  // === Navigation Logic ===
  Future<void> openDirections(BuildContext context) async {
    if (steps.isEmpty) {
      _showSnackBar(context, "Aucune étape disponible pour la navigation");
      return;
    }

    final validSteps = steps
        .where((step) => step.latitude != null && step.longitude != null)
        .toList();

    if (validSteps.isEmpty) {
      _showSnackBar(context, "Aucune étape avec des coordonnées valides");
      return;
    }

    NavigationService.navigateToStep(context, validSteps.first);
  }

  // === Calendar Integration ===
  Future<void> addToCalendar(BuildContext context) async {
    try {
      final start = DateTime.now().add(const Duration(days: 1));
      final end = start.add(const Duration(hours: 2));

      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.INSERT',
          data: 'content://com.android.calendar/events',
          arguments: {
            'title': 'Plany: $planTitle',
            'description': planDescription,
            'beginTime': start.millisecondsSinceEpoch,
            'endTime': end.millisecondsSinceEpoch,
            'eventLocation': 'Voir itinéraire dans l\'application Plany',
            'allDay': false,
          },
        );
        await intent.launch();
      } else {
        final event = Event(
          title: 'Plany: $planTitle',
          description: planDescription,
          location: 'Voir itinéraire dans l\'application Plany',
          startDate: start,
          endDate: end,
          allDay: false,
        );

        final success = await Add2Calendar.addEvent2Cal(event);
        if (!success) {
          throw Exception("Impossible d'ajouter l'événement");
        }

        if (context.mounted) {
          _showSnackBar(context, "Événement ajouté au calendrier");
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, "Erreur lors de l'ajout au calendrier : $e");
      }
    }
  }

  // === User Operations ===
  Future<User> getUserProfile(String userId) async {
    try {
      final result = await _userRepository.getUserById(userId);
      if (result is Error) {
        throw Exception('Failed to get user profile: $result');
      }
      return result as User;
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération du profil utilisateur : $e');
    }
  }

  Future<bool> isFollowing(String userId) async {
    try {
      final result = await _userRepository.isFollowing(userId);
      if (result is Error) {
        throw Exception('Failed to check following status: $result');
      }
      return result is Ok<bool> ? result.value : false;
    } catch (e) {
      throw Exception('Failed to check following status: $e');
    }
  }

  Future<void> followUser(String userId) async {
    final result = await _userRepository.followUser(userId);
    if (result is Error) {
      throw Exception('Failed to follow user: ${result.error}');
    }
    notifyListeners();
  }

  Future<void> unfollowUser(String userId) async {
    final result = await _userRepository.unfollowUser(userId);
    if (result is Error) {
      throw Exception('Failed to unfollow user: ${result.error}');
    }
    notifyListeners();
  }

  // === Favorites Operations ===
  Future<void> addToFavorites() async {
    if (_plan == null) return;

    final result = await _planRepository.addToFavorites(_plan!.id!);
    if (result is Error) {
      throw Exception('Failed to add to favorites: ${result.error}');
    }
    notifyListeners();
  }

  Future<void> removeFromFavorites() async {
    if (_plan == null) return;

    final result = await _planRepository.removeFromFavorites(_plan!.id!);
    if (result is Error) {
      throw Exception('Failed to remove from favorites: ${result.error}');
    }
    notifyListeners();
  }

  // === Helper Methods ===
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
