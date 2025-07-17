import 'package:flutter/material.dart';
import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../domain/models/user/user.dart';
import '../../../../utils/result.dart';
import './plan_details_viewmodel.dart';

class FollowUserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  bool _isFollowing = false;
  bool _isLoading = false;

  bool get isFollowing => _isFollowing;
  bool get isLoading => _isLoading;

  FollowUserViewModel(this._userRepository, this._authRepository);

  Future<void> initFollowStatus(User? user) async {
    if (user == null || user.id == _authRepository.currentUser?.id) return;
    final result = await _userRepository.isFollowing(user.id!);
    if (result is Ok<bool>) {
      _isFollowing = result.value;
    } else {
      _isFollowing = false;
    }
    notifyListeners();
  }

  Future<void> toggleFollow(User? user, PlanDetailsViewModel planVM) async {
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (_isFollowing) {
        await _userRepository.unfollowUser(user.id!);
        _isFollowing = false;
        planVM.updateFollowersList(isFollowing: false);
      } else {
        await _userRepository.followUser(user.id!);
        _isFollowing = true;
        planVM.updateFollowersList(isFollowing: true);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
