import '../../../domain/models/plan/plan.dart';
import '../../../utils/result.dart';

abstract class PlanRepository {
  /// Returns the list of [Plan].
  Future<Result<List<Plan>>> getPlanList();

  /// Creates a new [Plan].
  Future<Result<Plan>> createPlan(Plan plan);

  /// Adds a plan to favorites.
  Future<Result<void>> addToFavorites(String planId);

  /// Removes a plan from favorites.
  Future<Result<void>> removeFromFavorites(String planId);

  /// Clears the cache of plans.
  Future<void> clearCache();
}
