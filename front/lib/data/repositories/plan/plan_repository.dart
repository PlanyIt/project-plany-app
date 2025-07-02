import '../../../domain/models/plan/plan.dart';
import '../../../utils/result.dart';

abstract class PlanRepository {
  /// Returns the list of [Plan].
  Future<Result<List<Plan>>> getPlanList();
}
