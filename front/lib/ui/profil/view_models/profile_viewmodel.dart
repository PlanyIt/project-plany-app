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
import 'my_plan_viewmodel.dart';
import 'user_list_viewmodel.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final PlanRepository planRepository;
  final ScrollController scrollController = ScrollController();

  late final MyPlansViewModel myPlansViewModel;
  late final FavoritesViewModel favoritesViewModel;
  UserListViewModel? userListViewModel;

  ProfileViewModel({
    required this.authRepository,
    required this.userRepository,
    required this.planRepository,
  }) {
    myPlansViewModel = MyPlansViewModel(planRepository: planRepository);
    favoritesViewModel = FavoritesViewModel(planRepository: planRepository);
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
    try {
      isLoading = true;
      notifyListeners();

      final currentUserId = authRepository.currentUser?.id;
      final isCurrent = userId == null;
      final idToFetch = isCurrent ? currentUserId : userId;

      if (idToFetch == null) {
        debugPrint('❌ Aucun utilisateur identifié, arrêt du chargement.');
        userProfile = null;
        return;
      }

      final userResult = await userRepository.getUserById(idToFetch);
      if (userResult is Ok<User>) {
        userProfile = userResult.value;
        if (isCurrent) {
          authRepository.updateCurrentUser(userProfile!);
        }
      } else {
        userProfile = null;
        return;
      }

      userListViewModel = UserListViewModel(
        userRepository: userRepository,
        userId: userProfile!.id!,
      );

      await _loadRelatedData();
    } catch (e, stack) {
      debugPrint('Erreur loadUserData: $e\n$stack');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRelatedData() async {
    final tasks = [
      myPlansViewModel.loadPlans(userProfile!.id!),
      favoritesViewModel.loadFavorites(userProfile!.id!),
      userListViewModel!.loadFollowers(),
      userListViewModel!.loadFollowing(),
      _loadStats(),
      _checkFollowStatus(),
      loadUserCategories(),
    ];

    for (final task in tasks) {
      try {
        await task;
      } catch (e) {
        debugPrint('Erreur dans task loadRelatedData: $e');
      }
    }
  }

  Future<void> loadUserCategories() async {
    if (userProfile == null) return;
    try {
      isLoadingCategories = true;
      notifyListeners();

      final plansResult = await planRepository.getPlansByUser(userProfile!.id!);
      final userPlans =
          plansResult is Ok<List<Plan>> ? plansResult.value : <Plan>[];

      final categoryMap = <String, Category>{};
      for (final plan in userPlans) {
        if (plan.category != null) {
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

  Future<void> _loadStats() async {
    final statsResult = await userRepository.getUserStats(userProfile!.id);
    userStats = statsResult is Ok<UserStats> ? statsResult.value : null;
  }

  Future<void> _checkFollowStatus() async {
    if (userProfile == null || isCurrentUser) return;
    final followResult = await userRepository.isFollowing(userProfile!.id!);
    if (followResult is Ok<bool>) {
      isFollowing = followResult.value;
    }
  }

  Future<void> toggleFollow() async {
    if (userProfile == null || loadingFollow) return;

    loadingFollow = true;
    notifyListeners();

    try {
      if (isFollowing) {
        final result = await userRepository.unfollowUser(userProfile!.id!);
        if (result is Ok<void>) {
          isFollowing = false;
        }
      } else {
        final result = await userRepository.followUser(userProfile!.id!);
        if (result is Ok<void>) {
          isFollowing = true;
        }
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

  Future<void> updateProfilePhoto(File file) async {
    isUploadingAvatar = true;
    notifyListeners();

    final result = await userRepository.uploadImage(file);
    if (result is Ok<String>) {
      final imageUrl = result.value;
      final updatedUser = userProfile!.copyWith(photoUrl: imageUrl);
      await userRepository.updateUserProfile(updatedUser);
      authRepository.updateCurrentUser(updatedUser);
      userProfile = updatedUser;
      await myPlansViewModel.loadPlans(userProfile!.id!);
    }

    isUploadingAvatar = false;
    notifyListeners();
  }

  Future<void> removeProfilePhoto() async {
    final updatedUser = userProfile!.copyWith(photoUrl: null);
    await userRepository.updateUserProfile(updatedUser);
    authRepository.updateCurrentUser(updatedUser);
    userProfile = updatedUser;
    await myPlansViewModel.loadPlans(userProfile!.id!);
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

  Future<Result<void>> updateEmail(String email, String password) async {
    try {
      await userRepository.updateEmail(email, password, userProfile!.id!);
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
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  Future<void> refreshProfile() async {
    if (userProfile == null) return;
    await loadUserData(userProfile!.id);
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
