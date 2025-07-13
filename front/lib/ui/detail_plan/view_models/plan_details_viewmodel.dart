import 'dart:io';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/comment/comment_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart' as custom;
import '../../../domain/models/user/user.dart';
import '../../../utils/helpers.dart';
import '../../../utils/result.dart';
import 'comment/comment_input_viewmodel.dart';
import 'comment/comment_list_viewmodel.dart';
import 'comment/comment_section_viewmodel.dart';

class PlanDetailsViewModel extends ChangeNotifier {
  PlanDetailsViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required CommentRepository commentRepository,
    required PlanRepository planRepository,
    required LocationService locationService,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _commentRepository = commentRepository,
        _planRepository = planRepository,
        _locationService = locationService;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final CommentRepository _commentRepository;
  final PlanRepository _planRepository;
  final LocationService _locationService;

  Plan? _plan;
  User? get currentUser => _authRepository.currentUser;

  late final CommentListViewModel commentListViewModel;
  late final CommentInputViewModel commentInputViewModel;
  late final CommentSectionViewModel commentSectionViewModel;

  bool _isFavorite = false;
  bool _isFollowing = false;
  int _favoritesCount = 0;
  bool _isLoadingFollow = false;

  int _currentStepIndex = 0;
  bool _showStepInfo = false;
  String? _distanceToStep;
  bool _isCalculatingDistance = false;

  Plan? get plan => _plan;
  bool get isFavorite => _isFavorite;
  bool get isFollowing => _isFollowing;
  bool get isLoadingFollow => _isLoadingFollow;
  int get favoritesCount => _favoritesCount;
  bool get isCurrentUserPlan => currentUser?.id == _plan?.user?.id;
  Color? get planCategoryColor =>
      colorFromPlanCategory(_plan?.category?.color ?? '');
  bool get isPlanInitialized => _plan != null;

  List<custom.Step> get steps => _plan?.steps ?? <custom.Step>[];
  int get currentStepIndex => _currentStepIndex;
  bool get isCalculatingDistance => _isCalculatingDistance;
  String? get distanceToSelectedStep => _distanceToStep;
  bool get showStepInfo => _showStepInfo;

  custom.Step? get selectedStep {
    if (_currentStepIndex >= 0 && _currentStepIndex < steps.length) {
      return steps[_currentStepIndex];
    }
    return null;
  }

  void setPlan(Plan newPlan) {
    _plan = newPlan;
    _isFavorite = newPlan.isFavorite;
    _favoritesCount = newPlan.favorites?.length ?? 0;

    commentListViewModel = CommentListViewModel(
      authRepository: _authRepository,
      userRepository: _userRepository,
      commentRepository: _commentRepository,
      planId: newPlan.id!,
    );

    commentInputViewModel = CommentInputViewModel(
      authRepository: _authRepository,
      commentRepository: _commentRepository,
      planId: newPlan.id!,
    );

    commentSectionViewModel = CommentSectionViewModel(
      commentListViewModel: commentListViewModel,
      commentInputViewModel: commentInputViewModel,
    );

    commentListViewModel.loadComments(reset: true);

    _initializeFollowing();
    notifyListeners();
  }

  Future<void> _initializeFollowing() async {
    if (_plan?.user == null || isCurrentUserPlan) return;
    try {
      final isFollowed =
          await _userRepository.isFollowing(_plan!.user!.id ?? '');
      _isFollowing = isFollowed is Ok<bool> ? isFollowed.value : false;
    } catch (_) {
      _isFollowing = false;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    if (_plan == null) return;
    try {
      if (_isFavorite) {
        await _planRepository.removeFromFavorites(_plan!.id!);
        _isFavorite = false;
        _favoritesCount--;
      } else {
        await _planRepository.addToFavorites(_plan!.id!);
        _isFavorite = true;
        _favoritesCount++;
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleFollow() async {
    if (_plan?.user == null || isCurrentUserPlan || _isLoadingFollow) return;
    _isLoadingFollow = true;
    notifyListeners();
    try {
      if (_isFollowing) {
        await _userRepository.unfollowUser(_plan!.user!.id!);
        _isFollowing = false;
      } else {
        await _userRepository.followUser(_plan!.user!.id!);
        _isFollowing = true;
      }
    } catch (_) {
    } finally {
      _isLoadingFollow = false;
      notifyListeners();
    }
  }

  Future<void> sharePlan() async {
    final planUrl = "https://plany.app/plans/${_plan!.id}";
    final shareText = """
🗺️ Découvrez ce plan "${capitalize(_plan!.title)}" sur Plany !

📍 ${_plan!.category?.name ?? 'Sans catégorie'}
⏱️ ${formatDurationToString(_plan!.totalDuration ?? 0)}
💰 ${(calculateTotalStepsCost(_plan!.steps)).toStringAsFixed(2)} €

${_plan!.description.length > 100 ? '${_plan!.description.substring(0, 100)}...' : _plan!.description}

Voir le plan complet : $planUrl
""";
    await Share.share(shareText, subject: 'Découvrez ce plan Plany');
  }

  Future<void> navigateToUserProfile(
      BuildContext context, String? userId) async {
    if (userId == null) return;
    Navigator.of(context).pushNamed('/profile', arguments: {'userId': userId});
  }

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

  Future<void> _calculateDistanceToStep(custom.Step step) async {
    if (step.latitude == null || step.longitude == null) return;
    _isCalculatingDistance = true;
    notifyListeners();
    try {
      final userPosition = _locationService.currentPosition;
      _distanceToStep = formatDistance(calculateDistanceBetween(
        userPosition?.latitude ?? 0.0,
        userPosition?.longitude ?? 0.0,
        step.latitude!,
        step.longitude!,
      ));
    } catch (e) {
      debugPrint("Erreur lors du calcul de distance : $e");
    } finally {
      _isCalculatingDistance = false;
      notifyListeners();
    }
  }

  Future<void> openDirections(BuildContext context) async {
    if (_plan?.steps.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Aucune étape disponible pour la navigation")),
      );
      return;
    }

    final validSteps = _plan!.steps
        .where((step) => step.latitude != null && step.longitude != null)
        .toList();

    if (validSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Aucune étape avec des coordonnées valides")),
      );
      return;
    }

    // NavigationService.navigateToStep(context, validSteps.first);
  }

  Future<void> addToCalendar(BuildContext context) async {
    try {
      final start = DateTime.now().add(const Duration(days: 1));
      final end = start.add(const Duration(hours: 2));

      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.INSERT',
          data: 'content://com.android.calendar/events',
          arguments: {
            'title': 'Plany: ${_plan?.title}',
            'description': _plan?.description ?? '',
            'beginTime': start.millisecondsSinceEpoch,
            'endTime': end.millisecondsSinceEpoch,
            'eventLocation': 'Voir itinéraire dans l\'application Plany',
            'allDay': false,
          },
        );
        await intent.launch();
      } else {
        final event = Event(
          title: 'Plany: ${_plan?.title}',
          description: _plan?.description ?? '',
          location: 'Voir itinéraire dans l\'application Plany',
          startDate: start,
          endDate: end,
          allDay: false,
        );

        final success = await Add2Calendar.addEvent2Cal(event);
        if (!success) {
          throw Exception("Impossible d'ajouter l'événement");
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Événement ajouté au calendrier")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ajout au calendrier : $e")),
        );
      }
    }
  }
}
