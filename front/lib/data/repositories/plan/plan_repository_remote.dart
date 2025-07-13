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

    print('🚀 Creating plan with payload: $payload'); // Debug

    final result = await _apiClient.createPlan(body: payload);

    if (result case Ok<Plan>()) {
      final newPlan = result.value;
      print('✅ Plan created successfully: ${newPlan.id}'); // Debug
      if (newPlan.id != null) {
        _cachedData ??= [];
        _cachedData!.add(newPlan);
      }
    } else if (result case Error()) {
      print('❌ Plan creation failed: ${result.error}'); // Debug
    }

    return result;
  }

  @override
  Future<Result<void>> addToFavorites(String planId) async {
    try {
      await _apiClient.addPlanToFavorites(planId);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to add plan to favorites: $e'));
    }
  }

  @override
  Future<Result<void>> removeFromFavorites(String planId) async {
    try {
      await _apiClient.removePlanFromFavorites(planId);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(
          Exception('Failed to remove plan from favorites: $e'));
    }
  }

  @override
  Future<void> clearCache() async {
    _cachedData = null; // ❌ Mettre à null, pas []
    print('🧹 Plan cache cleared'); // Debug
  }
}
