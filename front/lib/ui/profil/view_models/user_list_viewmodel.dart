import 'package:flutter/material.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../domain/models/user/user.dart';
import '../../../../utils/result.dart';

class UserListViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final String userId;

  UserListViewModel({
    required this.userRepository,
    required this.userId,
  });

  List<User> followers = [];
  List<User> following = [];

  bool isLoading = true;
  Set<String> loadingIds = {};
  Map<String, bool> followingStatus = {};

  Future<void> loadFollowers() async {
    isLoading = true;
    notifyListeners();

    final result = await userRepository.getFollowers(userId);
    if (result is Ok<List<User>>) {
      followers = result.value;
      for (final user in followers) {
        final status = await userRepository.isFollowing(user.id ?? '');
        if (status is Ok<bool>) {
          followingStatus[user.id ?? ''] = status.value;
        }
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadFollowing() async {
    isLoading = true;
    notifyListeners();

    final result = await userRepository.getFollowing(userId);
    if (result is Ok<List<User>>) {
      following = result.value;
      for (final user in following) {
        final status = await userRepository.isFollowing(user.id ?? '');
        if (status is Ok<bool>) {
          followingStatus[user.id ?? ''] = status.value;
        }
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFollow(User user) async {
    loadingIds.add(user.id ?? '');
    notifyListeners();

    try {
      if (followingStatus[user.id] == true) {
        final res = await userRepository.unfollowUser(user.id ?? '');
        if (res is Ok<void>) {
          followingStatus[user.id ?? ''] = false;
        }
      } else {
        final res = await userRepository.followUser(user.id ?? '');
        if (res is Ok<void>) {
          followingStatus[user.id ?? ''] = true;
        }
      }
    } finally {
      loadingIds.remove(user.id);
      notifyListeners();
    }
  }
}
