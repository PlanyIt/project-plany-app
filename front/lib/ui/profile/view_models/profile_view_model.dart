import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/user/user.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required PlanRepository planRepository,
    String? userId,
  })  : _userRepository = userRepository,
        _authRepository = authRepository,
        _planRepository = planRepository,
        _userId = userId {
    load = Command0(_load)..execute();
    followUser = Command0(_followUser);
    unfollowUser = Command0(_unfollowUser);
    refreshData = Command0(_refreshData);
  }

  // Repositories
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final PlanRepository _planRepository;
  final Logger _log = Logger('ProfileViewModel');

  // Data
  final String? _userId;
  User? _userProfile;
  List<Plan> _userPlans = [];
  List<User> _followers = [];
  List<User> _following = [];
  bool _isFollowing = false;
  String _selectedSection = 'plans';

  // Commands
  late Command0 load;
  late Command0 followUser;
  late Command0 unfollowUser;
  late Command0 refreshData;

  // Getters
  User? get userProfile => _userProfile;
  List<Plan> get userPlans => _userPlans;
  List<User> get followers => _followers;
  List<User> get following => _following;
  bool get isFollowing => _isFollowing;
  String get selectedSection => _selectedSection;
  bool get isCurrentUser =>
      _userId == null || _userId == _authRepository.currentUser?.id;

  bool get hasLoadedData => _userProfile != null;

  // Stats getters
  int get plansCount => _userPlans.length;
  int get followersCount => _followers.length;
  int get followingCount => _following.length;

  Future<Result<void>> _load() async {
    try {
      // Determine which user to load
      final targetUserId = _userId ?? _authRepository.currentUser?.id;
      if (targetUserId == null) {
        return const Result.error('No user ID available');
      }

      // Load user profile
      final userResult = await _userRepository.getUserProfile(targetUserId);
      if (userResult is Error<User>) {
        _log.warning('Failed to load user profile', userResult.error);
        return userResult;
      }
      _userProfile = (userResult as Ok<User>).value;

      // Load user plans
      final plansResult = await _planRepository.getPlanList();
      if (plansResult is Ok<List<Plan>>) {
        // Filter plans for this user - vous devrez peut-être ajuster selon votre modèle
        _userPlans = (plansResult.value)
            .where((plan) => plan.userId == targetUserId)
            .toList();
      }

      // Load social data if not current user
      if (!isCurrentUser) {
        await _loadSocialData(targetUserId);
      } else {
        // Load social data for current user
        await _loadSocialData(targetUserId);
      }

      _log.info('Profile data loaded successfully');
      return const Result.ok(null);
    } catch (e) {
      _log.severe('Error loading profile data', e);
      return Result.error(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadSocialData(String userId) async {
    // Load followers
    final followersResult = await _userRepository.getUserFollowers(userId);
    if (followersResult is Ok<List<User>>) {
      _followers = followersResult.value;
    }

    // Load following
    final followingResult = await _userRepository.getUserFollowing(userId);
    if (followingResult is Ok<List<User>>) {
      _following = followingResult.value;
    }

    // Check if current user is following this user (only if not current user)
    if (!isCurrentUser) {
      final isFollowingResult = await _userRepository.isFollowing(userId);
      if (isFollowingResult is Ok<bool>) {
        _isFollowing = isFollowingResult.value;
      }
    }
  }

  Future<Result<void>> _followUser() async {
    if (_userProfile == null || isCurrentUser) {
      return const Result.error('Cannot follow user');
    }

    try {
      final result = await _userRepository.followUser(_userProfile!.id);
      if (result is Ok<void>) {
        _isFollowing = true;
        _followers.add(_authRepository.currentUser!);
        notifyListeners();
      }
      return result;
    } catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> _unfollowUser() async {
    if (_userProfile == null || isCurrentUser) {
      return const Result.error('Cannot unfollow user');
    }

    try {
      final result = await _userRepository.unfollowUser(_userProfile!.id);
      if (result is Ok<void>) {
        _isFollowing = false;
        _followers
            .removeWhere((user) => user.id == _authRepository.currentUser?.id);
        notifyListeners();
      }
      return result;
    } catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> _refreshData() async {
    return await _load();
  }

  void setSelectedSection(String section) {
    _selectedSection = section;
    notifyListeners();
  }

  void updateUserPhoto(String newPhotoUrl) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(profilePicture: newPhotoUrl);
      notifyListeners();
    }
  }

  // Method to get plans filtered by a specific criteria if needed
  List<Plan> getFilteredPlans({String? categoryId}) {
    if (categoryId == null) return _userPlans;
    return _userPlans.where((plan) => plan.categoryId == categoryId).toList();
  }
}
