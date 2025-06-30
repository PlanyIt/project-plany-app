import 'package:front/domain/models/plan/plan.dart';
import 'package:front/core/utils/result.dart';

abstract class PlanRepository {
  /// Returns the list of [Plan].
  Future<Result<List<Plan>>> getPlanList();

  /// Returns the [Plan] by its ID.
  Future<Result<Plan>> getPlanById(String id);

  /// Creates a new [Plan].
  Future<Result<Plan>> createPlan(Plan plan);

  /// Updates an existing [Plan].
  Future<Result<Plan>> updatePlan(String planId, Map<String, dynamic> data);

  /// Deletes a [Plan] by its ID.
  Future<Result<void>> deletePlan(String planId);

  /// Adds a plan to user's favorites.
  Future<Result<Map<String, dynamic>>> addToFavorites(String planId);

  /// Removes a plan from user's favorites.
  Future<Result<Map<String, dynamic>>> removeFromFavorites(String planId);

  /// Gets plans created by a specific user.
  Future<Result<List<Plan>>> getPlansByUserId(String userId);

  /// Gets favorite plans of a specific user.
  Future<Result<List<Plan>>> getFavoritesByUserId(String userId);
}
