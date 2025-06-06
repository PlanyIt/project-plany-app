import 'package:front/domain/models/plan.dart';
import 'package:front/utils/result.dart';

abstract class PlanRepository {
  /// Returns the list of [Plan].
  Future<Result<List<Plan>>> getPlanList();
}
