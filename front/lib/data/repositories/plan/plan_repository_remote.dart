import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/utils/result.dart';

/// Remote data source for [Plan].
/// Implements caching using plan ID as the key.
class PlanRepositoryRemote implements PlanRepository {
  PlanRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  // Cache utilisant l'ID du plan comme clé
  final Map<String, Plan> _cachedData = {};

  // Getter pour obtenir tous les plans en cache
  List<Plan> get cachedData => _cachedData.values.toList();

  /// Vide le cache, à appeler après un login/logout
  void clearCache() {
    _cachedData.clear();
  }

  @override
  Future<Result<List<Plan>>> getPlanList() async {
    if (_cachedData.isEmpty) {
      final result = await _apiClient.getPlans();
      if (result is Ok<List<Plan>>) {
        _cachedData.addEntries(
          result.value.where((plan) => plan.id != null).map(
                (plan) => MapEntry(plan.id!, plan),
              ),
        );
      }
      return result;
    } else {
      return Result.ok(cachedData);
    }
  }

  @override
  Future<Result<Plan>> createPlan(Plan plan) async {
    print("Creating plan with title: ${plan.title}");
    final Map<String, dynamic> payload = {
      "title": plan.title,
      "description": plan.description,
      "category": plan.category,
      "userId": plan.userId,
      "steps": plan.steps,
      "isPublic": plan.isPublic,
    };

    final result = await _apiClient.createPlan(body: payload);

    if (result case Ok<Plan>()) {
      final newPlan = result.value;
      if (newPlan.id != null) {
        _cachedData[newPlan.id!] = newPlan;
      }
    }

    return result;
  }

  @override
  Future<Result<Plan>> getPlanById(String id) {
    if (_cachedData.containsKey(id)) {
      return Future.value(Result.ok(_cachedData[id]!));
    }

    return _apiClient.getPlanById(id).then((result) {
      if (result is Ok<Plan>) {
        final plan = result.value;
        if (plan.id != null) {
          _cachedData[plan.id!] = plan;
        }
      }
      return result;
    });
  }

  @override
  Future<Result<Plan>> updatePlan(
      String planId, Map<String, dynamic> data) async {
    final result = await _apiClient.updatePlan(planId, data);

    if (result is Ok<Plan>) {
      final updatedPlan = result.value;
      if (updatedPlan.id != null) {
        _cachedData[updatedPlan.id!] = updatedPlan;
      }
    }

    return result;
  }

  @override
  Future<Result<void>> deletePlan(String planId) async {
    final result = await _apiClient.deletePlan(planId);

    if (result is Ok<void>) {
      _cachedData.remove(planId);
    }

    return result;
  }

  @override
  Future<Result<Map<String, dynamic>>> addToFavorites(String planId) async {
    return _apiClient.addPlanToFavorites(planId);
  }

  @override
  Future<Result<Map<String, dynamic>>> removeFromFavorites(
      String planId) async {
    return _apiClient.removePlanFromFavorites(planId);
  }

  @override
  Future<Result<List<Plan>>> getPlansByUserId(String userId) async {
    return _apiClient.getPlansByUserId(userId);
  }

  @override
  Future<Result<List<Plan>>> getFavoritesByUserId(String userId) async {
    return _apiClient.getFavoritesByUserId(userId);
  }
}
