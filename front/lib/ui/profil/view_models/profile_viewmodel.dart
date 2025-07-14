import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/category/category.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/user/user.dart';
import '../../../domain/models/user/user_stats.dart';
import '../../../utils/result.dart';
import 'favorites_viewmodel.dart';
import 'followers_viewmodel.dart';
import 'following_viewmodel.dart';
import 'my_plan_viewmodel.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final PlanRepository planRepository;
  final ScrollController scrollController = ScrollController();

  late final MyPlansViewModel myPlansViewModel;
  late final FavoritesViewModel favoritesViewModel;
  late final FollowingViewModel followingViewModel;
  FollowersViewModel? followersViewModel;

  ProfileViewModel({
    required this.authRepository,
    required this.userRepository,
    required this.planRepository,
  }) {
    myPlansViewModel = MyPlansViewModel(planRepository: planRepository);
    favoritesViewModel = FavoritesViewModel(planRepository: planRepository);
    followingViewModel = FollowingViewModel(userRepository: userRepository);
  }

  bool isLoading = true;
  User? userProfile;
  UserStats? userStats;
  bool isFollowing = false;
  bool loadingFollow = false;
  bool isUploadingAvatar = false;
  String selectedSection = 'plans';

  List<Category> userCategories = [];
  bool isLoadingCategories = false;

  bool get isCurrentUser {
    return userProfile?.id == authRepository.currentUser?.id;
  }

  Future<void> loadUserData(String? userId) async {
    isLoading = true;
    notifyListeners();

    final isCurrent =
        userId == null || userId == authRepository.currentUser?.id;

    if (isCurrent) {
      final userResult =
          await userRepository.getUserById(authRepository.currentUser!.id!);
      if (userResult is Ok<User>) {
        userProfile = User(
          id: authRepository.currentUser?.id,
          username: userResult.value.username,
          email: userResult.value.email,
          description: userResult.value.description,
          isPremium: userResult.value.isPremium,
          photoUrl: userResult.value.photoUrl,
          birthDate: userResult.value.birthDate,
          gender: userResult.value.gender,
          followers: userResult.value.followers,
          following: userResult.value.following,
          createdAt: userResult.value.createdAt,
        );
        authRepository.updateCurrentUser(userProfile!);
      }
    } else {
      final userResult = await userRepository.getUserById(userId);
      userProfile = userResult is Ok<User> ? userResult.value : null;
    }

    if (userProfile != null) {
      followersViewModel = FollowersViewModel(
        userRepository: userRepository,
        userId: userProfile!.id ?? '',
      );

      await Future.wait([
        myPlansViewModel.loadPlans(userProfile!.id ?? ''),
        favoritesViewModel.loadFavorites(userProfile!.id ?? ''),
        followingViewModel.loadFollowing(userProfile!.id ?? ''),
        followersViewModel!.loadFollowers(),
        _loadStats(),
        _checkFollowStatus(),
        loadUserCategories(),
      ]);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadStats() async {
    final statsResult = await userRepository.getUserStats(userProfile!.id);
    userStats = statsResult is Ok<UserStats> ? statsResult.value : null;
  }

  Future<void> _checkFollowStatus() async {
    if (userProfile == null) return;
    if (userProfile!.id == authRepository.currentUser?.id) return;

    final followResult =
        await userRepository.isFollowing(userProfile?.id ?? '');
    if (followResult is Ok<bool>) {
      isFollowing = followResult.value;
    }
  }

  Future<void> loadUserCategories() async {
    if (userProfile == null) return;
    try {
      isLoadingCategories = true;
      notifyListeners();

      final plansResult = await planRepository.getPlansByUser(userProfile!.id!);
      final categoryMap = <String, Category>{};

      final userPlans =
          plansResult is Ok<List<Plan>> ? plansResult.value : <Plan>[];

      for (final plan in userPlans) {
        if (plan.category != null &&
            !categoryMap.containsKey(plan.category!.id)) {
          categoryMap[plan.category!.id] = plan.category!;
        }
      }

      userCategories = categoryMap.values.toList();
    } catch (_) {
      userCategories = [];
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> toggleFollow() async {
    if (userProfile == null || loadingFollow) return;

    loadingFollow = true;
    notifyListeners();

    try {
      if (isFollowing) {
        final result = await userRepository.unfollowUser(userProfile?.id ?? '');
        if (result is Ok<void>) isFollowing = false;
      } else {
        final result = await userRepository.followUser(userProfile?.id ?? '');
        if (result is Ok<void>) isFollowing = true;
      }
      await _loadStats();
    } finally {
      loadingFollow = false;
      notifyListeners();
    }
  }

  void selectSection(String section) {
    selectedSection = section;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          420,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> refreshStats() async {
    if (userProfile == null) return;
    await _loadStats();
    notifyListeners();
  }

  void updatePhoto(String url) {
    if (userProfile == null) return;
    userProfile = userProfile!.copyWith(photoUrl: url);
    authRepository.updateCurrentUser(userProfile!);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String username,
    String? description,
    DateTime? birthDate,
    String? gender,
    bool? isPremium,
  }) async {
    userProfile = userProfile!.copyWith(
      username: username,
      description: description,
      birthDate: birthDate,
      email: userProfile!.email,
      isPremium: isPremium ?? userProfile!.isPremium,
      photoUrl: userProfile!.photoUrl,
      gender: gender ?? userProfile!.gender,
    );

    await userRepository.updateUserProfile(userProfile!);
    authRepository.updateCurrentUser(userProfile!);

    notifyListeners();
  }

  Future<void> updateProfilePhoto(File file) async {
    isUploadingAvatar = true;
    notifyListeners();

    final result = await userRepository.uploadImage(file);
    String? imageUrl;
    if (result is Ok<String>) {
      imageUrl = result.value;
      await userRepository.updateUserProfile(
        userProfile!.copyWith(photoUrl: imageUrl),
      );
      authRepository
          .updateCurrentUser(userProfile!.copyWith(photoUrl: imageUrl));
      updatePhoto(imageUrl);

      // Refresh plans with updated avatar
      await myPlansViewModel.loadPlans(userProfile!.id!);
    }

    isUploadingAvatar = false;
    notifyListeners();
  }

  Future<void> removeProfilePhoto() async {
    await userRepository
        .updateUserProfile(userProfile!.copyWith(photoUrl: null));
    authRepository.updateCurrentUser(userProfile!.copyWith(photoUrl: null));
    updatePhoto('');
    await myPlansViewModel.loadPlans(userProfile!.id!);
  }

  Future<Result<void>> updateEmail(String email, String password) async {
    try {
      await userRepository.updateEmail(email, password, userProfile?.id ?? '');
      userProfile = userProfile!.copyWith(email: email);
      authRepository.updateCurrentUser(userProfile!);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  Future<Result<void>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await authRepository.updatePassword(
          currentPassword: currentPassword, newPassword: newPassword);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
