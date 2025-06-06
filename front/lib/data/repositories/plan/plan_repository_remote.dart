import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/plan.dart';
import 'package:front/utils/result.dart';

/// Remote data source for [Plan].
/// Implements basic local caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class PlanRepositoryRemote implements PlanRepository {
  PlanRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Plan>? _cachedData;

  @override
  Future<Result<List<Plan>>> getPlanList() async {
    if (_cachedData == null) {
      // No cached data, request plans from API
      final result = await _apiClient.getPlans();
      if (result is Ok<List<Plan>>) {
        // Store value if result Ok
        _cachedData = result.value;
      }
      return result;
    } else {
      // Return cached data if available
      return Result.ok(_cachedData!);
    }
  }
}
