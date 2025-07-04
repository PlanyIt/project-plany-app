import '../../../domain/models/plan/plan.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import 'plan_repository.dart';

/// Remote data source for [Plan].
/// Implements caching using plan ID as the key.
class PlanRepositoryRemote implements PlanRepository {
  PlanRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  List<Plan>? _cachedData = [];

  @override
  Future<Result<List<Plan>>> getPlanList() async {
    if (_cachedData == null) {
      final result = await _apiClient.getPlans();
      if (result is Ok<List<Plan>>) {
        _cachedData = result.value;
      }
      return result;
    } else {
      return Result.ok(_cachedData!);
    }
  }

  @override
  Future<Result<Plan>> createPlan(Plan plan) async {
    final payload = <String, dynamic>{
      "title": plan.title,
      "description": plan.description,
      "categoryId": plan.categoryId,
      "userId": plan.userId,
      "steps": plan.steps,
      "isPublic": plan.isPublic,
    };

    final result = await _apiClient.createPlan(body: payload);

    if (result case Ok<Plan>()) {
      final newPlan = result.value;
      if (newPlan.id != null) {
        _cachedData ??= [];
        _cachedData!.add(newPlan);
      }
    }

    return result;
  }
}
