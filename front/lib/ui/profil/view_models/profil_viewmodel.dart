import 'dart:io';
import 'package:flutter/material.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/services/imgur_service.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as plan_steps;
import 'package:front/domain/models/user/user.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';

class ProfilViewModel extends ChangeNotifier {
  ProfilViewModel({
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
  final _log = Logger('ProfilViewModel');

  User? _user;

  late Command0 load;

  User? get user => _user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  Future<Result> _load() async {
    try {
      _log.info('Starting to load profile data...');

      // Load user
      _log.info('Fetching user profile...');
      final userResult = await _userRepository.getCurrentUser();

      switch (userResult) {
        case Ok<User>():
          _user = userResult.value;
          _log.fine('Loaded user with plansCount: ${_user?.plansCount}');
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

  Future<User?> updateProfilePhoto(String userId, File imageFile) async {
    try {
      _log.info('Starting profile photo update...');

      // 1. Upload image to Imgur
      _log.info('Uploading image to Imgur...');
      final imgurService = ImgurService();
      final imgurResponse = await imgurService.uploadImage(imageFile);
      final imageUrl = imgurResponse;

      _log.info('Image uploaded successfully to: $imageUrl');

      // 2. Update user profile with new photo URL
      final updateResult = await _userRepository.patchCurrentUser({
        'photoUrl': imageUrl,
      });

      switch (updateResult) {
        case Ok<User>():
          _user = updateResult.value;
          _log.info('User profile updated successfully');
          notifyListeners();
          return _user;
        case Error<User>():
          _log.warning('Failed to update user profile', updateResult.error);
          throw updateResult.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error updating profile photo', e, stackTrace);
      rethrow;
    }
  }

  Future<User?> removeProfilePhoto(String userId) async {
    try {
      _log.info('Removing profile photo...');

      // Update user profile to remove photo URL
      final updateResult = await _userRepository.patchCurrentUser({
        'photoUrl': null,
      });

      switch (updateResult) {
        case Ok<User>():
          _user = updateResult.value;
          _log.info('Profile photo removed successfully');
          notifyListeners();
          return _user;
        case Error<User>():
          _log.warning('Failed to remove profile photo', updateResult.error);
          throw updateResult.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error removing profile photo', e, stackTrace);
      rethrow;
    }
  }

  Future<User?> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      _log.info('Updating user profile with data: $data');

      final updateResult = await _userRepository.patchCurrentUser(data);

      switch (updateResult) {
        case Ok<User>():
          _user = updateResult.value;
          _log.info('User profile updated successfully');
          notifyListeners();
          return _user;
        case Error<User>():
          _log.warning('Failed to update user profile', updateResult.error);
          throw updateResult.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error updating user profile', e, stackTrace);
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      _log.info('Getting current user...');

      final userResult = await _userRepository.getCurrentUser();

      switch (userResult) {
        case Ok<User>():
          _user = userResult.value;
          _log.info('Current user retrieved successfully');
          return _user;
        case Error<User>():
          _log.warning('Failed to get current user', userResult.error);
          throw userResult.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting current user', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      _log.info('Getting categories...');

      final categoriesResult = await _categoryRepository.getCategoriesList();

      switch (categoriesResult) {
        case Ok<List<Category>>():
          _log.info('Categories retrieved successfully');
          return categoriesResult.value;
        case Error<List<Category>>():
          _log.warning('Failed to get categories', categoriesResult.error);
          throw categoriesResult.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting categories', e, stackTrace);
      rethrow;
    }
  }

  Future<List<dynamic>> getUserPlans(String userId) async {
    try {
      _log.info('Getting user plans for userId: $userId');

      final plansResult = await _planRepository.getPlansByUserId(userId);

      switch (plansResult) {
        case Ok<List<Plan>>():
          _log.info('User plans retrieved successfully');
          return plansResult.value;
        case Error<List<Plan>>():
          _log.warning('Failed to get user plans', plansResult.error);
          throw plansResult.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting user plans', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Plan>> getUserFavoritePlans(String userId) async {
    try {
      _log.info('Getting user favorite plans for userId: $userId');

      final favoritesResult =
          await _planRepository.getFavoritesByUserId(userId);

      switch (favoritesResult) {
        case Ok<List<Plan>>():
          _log.info('User favorite plans retrieved successfully');
          return favoritesResult.value;
        case Error<List<Plan>>():
          _log.warning(
              'Failed to get user favorite plans', favoritesResult.error);
          throw favoritesResult.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting user favorite plans', e, stackTrace);
      rethrow;
    }
  }

  Future<plan_steps.Step?> getStepById(String stepId) async {
    try {
      _log.info('Getting step by id: $stepId');

      final stepResult = await _stepRepository.getStepById(stepId);

      switch (stepResult) {
        case Ok<plan_steps.Step>():
          _log.info('Step retrieved successfully');
          return stepResult.value;
        case Error<plan_steps.Step>():
          _log.warning('Failed to get step', stepResult.error);
          return null;
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting step by id', e, stackTrace);
      return null;
    }
  }

  Future<void> removeFromFavorites(String planId) async {
    try {
      _log.info('Removing plan from favorites: $planId');

      final result = await _planRepository.removeFromFavorites(planId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          _log.info('Plan removed from favorites successfully');
          break;
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to remove plan from favorites', result.error);
          throw result.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error removing plan from favorites', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> deletePlan(String planId) async {
    try {
      _log.info('Deleting plan: $planId');

      final result = await _planRepository.deletePlan(planId);

      switch (result) {
        case Ok<void>():
          _log.info('Plan deleted successfully');
          return true;
        case Error<void>():
          _log.warning('Failed to delete plan', result.error);
          throw result.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error deleting plan', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> isFollowing(String userId) async {
    try {
      _log.info('Checking if following user: $userId');

      final currentUserResult = await _userRepository.getCurrentUser();
      if (currentUserResult is Ok<User>) {
        final currentUserId = currentUserResult.value.id;
        final result =
            await _userRepository.checkFollowing(currentUserId, userId);

        if (result is Ok<Map<String, dynamic>>) {
          final isFollowing = result.value['isFollowing'] == true;
          _log.info('Is following: $isFollowing');
          return isFollowing;
        }
      }
      return false;
    } catch (e, stackTrace) {
      _log.severe('Error checking follow status', e, stackTrace);
      return false;
    }
  }

  Future<bool> followUser(String userId) async {
    try {
      _log.info('Following user: $userId');

      final result = await _userRepository.followUser(userId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          _log.info('User followed successfully');
          return true;
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to follow user', result.error);
          return false;
      }
    } catch (e, stackTrace) {
      _log.severe('Error following user', e, stackTrace);
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      _log.info('Unfollowing user: $userId');

      final result = await _userRepository.unfollowUser(userId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          _log.info('User unfollowed successfully');
          return true;
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to unfollow user', result.error);
          return false;
      }
    } catch (e, stackTrace) {
      _log.severe('Error unfollowing user', e, stackTrace);
      return false;
    }
  }

  Future<List<User>> getUserFollowers(String userId) async {
    try {
      _log.info('Getting followers for user: $userId');

      final result = await _userRepository.getUserFollowers(userId);

      switch (result) {
        case Ok<List<User>>():
          _log.info('User followers retrieved successfully');
          return result.value;
        case Error<List<User>>():
          _log.warning('Failed to get user followers', result.error);
          throw result.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting user followers', e, stackTrace);
      rethrow;
    }
  }

  Future<List<User>> getUserFollowing(String userId) async {
    try {
      _log.info('Getting following for user: $userId');

      final result = await _userRepository.getUserFollowing(userId);

      switch (result) {
        case Ok<List<User>>():
          _log.info('User following retrieved successfully');
          return result.value;
        case Error<List<User>>():
          _log.warning('Failed to get user following', result.error);
          throw result.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting user following', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> updatePremiumStatus(String userId, bool isPremium) async {
    try {
      _log.info('Updating premium status for user: $userId to $isPremium');

      final result =
          await _userRepository.updateUserPremiumStatus(userId, isPremium);

      switch (result) {
        case Ok<User>():
          _user = result.value;
          _log.info('Premium status updated successfully');
          notifyListeners();
          return true;
        case Error<User>():
          _log.warning('Failed to update premium status', result.error);
          return false;
      }
    } catch (e, stackTrace) {
      _log.severe('Error updating premium status', e, stackTrace);
      return false;
    }
  }

  Future<User> updateUserEmail(
      String userId, String email, String password) async {
    try {
      _log.info('Updating user email for user: $userId');

      final result = await _userRepository.updateUserEmail(userId, email);

      switch (result) {
        case Ok<User>():
          _user = result.value;
          _log.info('User email updated successfully');
          notifyListeners();
          return result.value;
        case Error<User>():
          _log.warning('Failed to update user email', result.error);
          throw result.error;
      }
    } catch (e, stackTrace) {
      _log.severe('Error updating user email', e, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _log.info('Logging out user');

      // Clear local user data
      _user = null;

      // You can add any additional logout logic here
      // For example, clearing tokens, cache, etc.

      _log.info('User logged out successfully');
      notifyListeners();
    } catch (e, stackTrace) {
      _log.severe('Error during logout', e, stackTrace);
      rethrow;
    }
  }
}
