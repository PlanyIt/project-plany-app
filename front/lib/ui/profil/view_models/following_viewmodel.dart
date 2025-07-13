import 'package:flutter/material.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/user/user.dart';
import '../../../utils/result.dart';

class FollowingViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  FollowingViewModel({required this.userRepository});

  List<User> _following = [];
  Set<String> loadingIds = {};
  bool isLoading = true;

  List<User> get following => _following;

  Future<void> loadFollowing(String userId) async {
    isLoading = true;
    notifyListeners();

    final result = await userRepository.getFollowing(userId);
    if (result is Ok<List<User>>) {
      _following = result.value;
    } else {
      _following = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> unfollowUser(String userId) async {
    if (loadingIds.contains(userId)) return;

    loadingIds.add(userId);
    notifyListeners();

    final result = await userRepository.unfollowUser(userId);
    if (result is Ok<void>) {
      _following.removeWhere((u) => u.id == userId);
    }

    loadingIds.remove(userId);
    notifyListeners();
  }
}
