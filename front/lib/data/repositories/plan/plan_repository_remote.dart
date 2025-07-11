import '../../../domain/models/plan/plan.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import 'plan_repository.dart';

/// Remote data source for [Plan].
/// Implements caching using plan ID as the key.
class PlanRepositoryRemote implements PlanRepository {
  PlanRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  List<Plan>? _cachedData;

  @override
  Future<Result<List<Plan>>> getPlanList() async {
    // Toujours charger depuis l'API - pour débugger
    final result = await _apiClient.getPlans();
    if (result is Ok<List<Plan>>) {
      _cachedData = result.value;
      print('🔍 Plans loaded: ${result.value.length}'); // Debug
    } else if (result is Error<List<Plan>>) {
      print('❌ Failed to load plans: ${result.error}'); // Debug
    }
    return result;
  }

  @override
  Future<Result<Plan>> createPlan(Plan plan) async {
    final payload = <String, dynamic>{
      "title": plan.title,
      "description": plan.description,
      "category": plan.category?.id,
      "user": plan.user?.id,
      "steps": plan.steps.map((step) => step.id).toList(),
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

  @override
  Future<void> clearCache() async {
    _cachedData = null; // ❌ Mettre à null, pas []
    print('🧹 Plan cache cleared'); // Debug
  }
}
