import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../data/repositories/comment/comment_repository.dart';
import '../../../../data/repositories/plan/plan_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../data/services/location_service.dart';
import '../../../../domain/models/plan/plan.dart';
import '../../../../domain/models/step/step.dart' as custom;
import '../../../../domain/models/user/user.dart';
import '../../../../routing/routes.dart';
import '../../../../utils/helpers.dart';
import '../../../../utils/result.dart';
import '../comment/comment_input_viewmodel.dart';
import '../comment/comment_list_viewmodel.dart';
import '../comment/comment_section_viewmodel.dart';

class PlanDetailsViewModel extends ChangeNotifier {
  final PlanRepository _planRepository;
  final LocationService _locationService;
  final AuthRepository _authRepository;

  late final CommentSectionViewModel commentSectionViewModel;

  Plan? _plan;
  int _currentStepIndex = 0;
  String? _distanceToStep;
  bool _isCalculatingDistance = false;
  bool _showStepInfo = false;

  Plan? get plan => _plan;
  int get currentStepIndex => _currentStepIndex;
  String? get distanceToStep => _distanceToStep;
  bool get isCalculatingDistance => _isCalculatingDistance;
  List<custom.Step> get steps => _plan?.steps ?? [];
  User? get currentUser => _authRepository.currentUser;
  bool get isCurrentUserPlan => currentUser?.id == _plan?.user?.id;
  bool get showStepInfo => _showStepInfo;

  Color? get planCategoryColor =>
      colorFromPlanCategory(_plan?.category?.color ?? '');

  custom.Step? get selectedStep {
    if (_currentStepIndex >= 0 && _currentStepIndex < steps.length) {
      return steps[_currentStepIndex];
    }
    return null;
  }

  PlanDetailsViewModel({
    required PlanRepository planRepository,
    required LocationService locationService,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required CommentRepository commentRepository,
    required String planId,
  })  : _planRepository = planRepository,
        _locationService = locationService,
        _authRepository = authRepository {
    commentSectionViewModel = CommentSectionViewModel(
      commentListViewModel: CommentListViewModel(
        authRepository: authRepository,
        userRepository: userRepository,
        commentRepository: commentRepository,
        planId: planId,
      ),
      commentInputViewModel: CommentInputViewModel(
        authRepository: authRepository,
        commentRepository: commentRepository,
        planId: planId,
      ),
    );
  }

  Future<void> loadPlan(String planId) async {
    final result = await _planRepository.getPlan(planId);
    if (result is Ok<Plan>) {
      _plan = result.value;
      notifyListeners();
      await commentSectionViewModel.commentListViewModel
          .loadComments(reset: true);
    }
  }

  Future<void> selectStep(int index) async {
    if (index < 0 || index >= steps.length) return;
    _currentStepIndex = index;
    _distanceToStep = null;
    await _calculateDistanceToStep(steps[index]);
    notifyListeners();
  }

  Future<void> _calculateDistanceToStep(custom.Step step) async {
    if (step.latitude == null || step.longitude == null) return;
    _isCalculatingDistance = true;
    notifyListeners();

    try {
      final userPosition = _locationService.currentPosition;
      _distanceToStep = formatDistance(
        calculateDistanceBetween(
          userPosition?.latitude ?? 0.0,
          userPosition?.longitude ?? 0.0,
          step.latitude!,
          step.longitude!,
        ),
      );
    } finally {
      _isCalculatingDistance = false;
      notifyListeners();
    }
  }

  void navigateToUserProfile(BuildContext context, String? userId) {
    if (userId == null) return;
    context.push(Routes.profile, extra: userId);
  }

  void updateFollowersList({required bool isFollowing}) {
    if (_plan?.user == null) return;
    final user = _plan!.user!;
    final followers = user.followers.toList();
    final userId = _authRepository.currentUser?.id;
    if (userId == null) return;

    isFollowing ? followers.add(userId) : followers.remove(userId);

    _plan = _plan!.copyWith(user: user.copyWith(followers: followers));
    notifyListeners();
  }

  void updateFavoritesList({required bool isFavorited}) {
    if (_plan == null) return;
    final userId = _authRepository.currentUser?.id;
    if (userId == null) return;

    final favorites = _plan!.favorites?.toList() ?? [];

    if (isFavorited && !favorites.contains(userId)) {
      favorites.add(userId);
    } else if (!isFavorited && favorites.contains(userId)) {
      favorites.remove(userId);
    }

    _plan = _plan!.copyWith(favorites: favorites);
    notifyListeners();
  }

  void showStepInformation(bool show) {
    _showStepInfo = show;
    notifyListeners();
  }
}
