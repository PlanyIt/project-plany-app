import '../../../domain/models/plan/plan.dart';
import '../../../utils/result.dart';

abstract class PlanRepository {
  /// Returns the list of [Plan].
  Future<Result<List<Plan>>> getPlanList();

  /// Creates a new [Plan].
  Future<Result<Plan>> createPlan(Plan plan);

  /// Clears the cache of plans.
  Future<void> clearCache();
}
