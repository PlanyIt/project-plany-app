
import 'package:front/data/services/api/api_client.dart';
import 'package:front/data/services/api/model/step/step_api_model.dart';
import 'package:front/data/services/api/model/user/user_api_model.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/domain/models/user/user_stats.dart';
import 'package:front/utils/result.dart';

import '../../models/category.dart';
import '../../models/comment.dart';
import '../../models/plan.dart';
import '../../models/step.dart';
import '../../models/user.dart';

class FakeApiClient implements ApiClient {
  // Pour ton test d'auth
  @override
  String? Function()? authHeaderProvider;

  @override
  void Function()? onUnauthorized;

  int requestCount = 0;

  String? get currentAuthHeader => authHeaderProvider?.call();

  @override
  Future<Result<List<Category>>> getCategories() async {
    requestCount++;
    return Result.ok([
      Category(id: '1', name: 'Cat1', icon: 'icon1', color: 'FF0000'),
      Category(id: '2', name: 'Cat2', icon: 'icon2', color: '00FF00'),
      Category(id: '3', name: 'Cat3', icon: 'icon3', color: '0000FF'),
    ]);
  }

  @override
  Future<Result<List<StepApiModel>>> getStepsByPlan(String planId) async {
    requestCount++;
    return Result.ok([
      StepApiModel(
        title: 'Step 1',
        description: 'Desc 1',
        order: 1,
        image: 'image1',
      ),
      StepApiModel(
        title: 'Step 2',
        description: 'Desc 2',
        order: 2,
        image: 'image2',
      ),
    ]);
  }

  @override
  Future<Result<UserApiModel>> updateUserProfile(User user) async {
    requestCount++;
    return Result.ok(userApiModel);
  }

  @override
  Future<Result<Category>> getCategory(String id) async {
    requestCount++;
    return Result.ok(kCategory);
  }

  @override
  Future<Result<List<Plan>>> getPlans() async {
    requestCount++;
    return Result.ok([
      Plan(id: 'plan1', title: 'Plan 1', description: 'Desc 1'),
      Plan(id: 'plan2', title: 'Plan 2', description: 'Desc 2'),
    ]);
  }

  @override
  Future<Result<Plan>> getPlan(String planId) async {
    requestCount++;
    return Result.ok(kPlan);
  }

  @override
  Future<Result<User>> getUserById(String userId) async {
    requestCount++;
    return Result.ok(kUser);
  }

  @override
  Future<Result<List<Plan>>> getPlansByUser(String userId) async {
    requestCount++;
    return Result.ok([
      Plan(id: 'plan1', title: 'User $userId Plan 1', description: 'Desc 1'),
      Plan(id: 'plan2', title: 'User $userId Plan 2', description: 'Desc 2'),
    ]);
  }

  @override
  Future<Result<Plan>> createPlan({required Map<String, dynamic> body}) async {
    requestCount++;
    return Result.ok(
      Plan(
        id: body['id'] ?? 'new_plan',
        title: body['title'] ?? 'New Plan',
        description: body['description'] ?? 'New Description',
      ),
    );
  }

  @override
  Future<Result<void>> addPlanToFavorites(String planId) async {
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> removePlanFromFavorites(String planId) async {
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deletePlan(String planId) async {
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<Step>> createStep(Step step) async {
    requestCount++;
    return Result.ok(kStep);
  }

  @override
  Future<Result<void>> updateEmail(
      String email, String password, String userId) async {
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<List<Plan>>> getFavoritesByUser(String userId) async {
    requestCount++;
    return Result.ok([
      Plan(id: 'fav1', title: 'Favorite 1', description: 'Desc 1'),
      Plan(id: 'fav2', title: 'Favorite 2', description: 'Desc 2'),
    ]);
  }

  @override
  Future<Result<List<User>>> getFollowers(String userId) async {
    requestCount++;
    return Result.ok([
      User(id: 'follower1', username: 'Follower1', email: 'f1@email.com'),
      User(id: 'follower2', username: 'Follower2', email: 'f2@email.com'),
    ]);
  }

  @override
  Future<Result<List<User>>> getFollowing(String userId) async {
    requestCount++;
    return Result.ok([
      User(id: 'following1', username: 'Following1', email: 'fo1@email.com'),
      User(id: 'following2', username: 'Following2', email: 'fo2@email.com'),
    ]);
  }

  @override
  Future<Result<UserStats>> getUserStats(String userId) async {
    requestCount++;
    return Result.ok(UserStats(
      plansCount: 2,
      followersCount: 2,
      followingCount: 2,
      favoritesCount: 2,
    ));
  }

  @override
  Future<Result<List<Comment>>> getComments(String planId,
      {int page = 1, int limit = 10}) async {
    requestCount++;
    return Result.ok([
      Comment(content: 'Comment 1', planId: planId),
      Comment(content: 'Comment 2', planId: planId),
    ]);
  }

  @override
  Future<Result<List<Comment>>> getCommentResponses(String commentId) async {
    requestCount++;
    return Result.ok([
      Comment(content: 'Response 1', planId: 'plan1'),
      Comment(content: 'Response 2', planId: 'plan1'),
    ]);
  }

  // Function fields for test overrides
  Future<Result<Comment>> Function(String, dynamic)? createCommentFn;
  Future<Result<void>> Function(String, dynamic)? editCommentFn;
  Future<Result<void>> Function(String)? deleteCommentFn;
  Future<Result<Comment>> Function(String)? getCommentByIdFn;
  Future<Result<void>> Function(String)? likeCommentFn;
  Future<Result<void>> Function(String)? unlikeCommentFn;
  Future<Result<Comment>> Function(String, dynamic)? respondToCommentFn;
  Future<Result<void>> Function(String, String)? deleteResponseFn;
  Future<Result<void>> Function(String, String)? addResponseToCommentFn;

  @override
  Future<Result<Comment>> createComment(String planId, Comment comment) async {
    if (createCommentFn != null) {
      return await createCommentFn!(planId, comment);
    }
    requestCount++;
    return Result.ok(kComment);
  }

  @override
  Future<Result<void>> editComment(String commentId, Comment comment) async {
    if (editCommentFn != null) {
      return await editCommentFn!(commentId, comment);
    }
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    if (deleteCommentFn != null) {
      return await deleteCommentFn!(commentId);
    }
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<Comment>> getCommentById(String commentId) async {
    if (getCommentByIdFn != null) {
      return await getCommentByIdFn!(commentId);
    }
    requestCount++;
    return Result.ok(kComment);
  }

  @override
  Future<Result<void>> likeComment(String commentId) async {
    if (likeCommentFn != null) {
      return await likeCommentFn!(commentId);
    }
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> unlikeComment(String commentId) async {
    if (unlikeCommentFn != null) {
      return await unlikeCommentFn!(commentId);
    }
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<Comment>> respondToComment(
      String commentId, Comment comment) async {
    if (respondToCommentFn != null) {
      return await respondToCommentFn!(commentId, comment);
    }
    requestCount++;
    return Result.ok(kComment);
  }

  @override
  Future<Result<void>> deleteResponse(
      String commentId, String responseId) async {
    if (deleteResponseFn != null) {
      return await deleteResponseFn!(commentId, responseId);
    }
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> addResponseToComment(
      String commentId, String responseId) async {
    if (addResponseToCommentFn != null) {
      return await addResponseToCommentFn!(commentId, responseId);
    }
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> followUser(String userId) async {
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> unfollowUser(String userId) async {
    requestCount++;
    return const Result.ok(null);
  }

  @override
  Future<Result<bool>> isFollowing(String userId) async {
    requestCount++;
    return Result.ok(true);
  }

  @override
  Future<Result<void>> changePassword(
      String currentPassword, String newPassword) async {
    requestCount++;
    return const Result.ok(null);
  }
}
