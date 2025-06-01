import 'package:dashboard/models/plan.dart';
import 'package:dashboard/services/api_service.dart';

class PlanService {
  final ApiService _apiService = ApiService();

  Future<List<Plan>> getPlans() async {
    final response = await _apiService.get('/api/plans');
    return (response as List).map((data) => Plan.fromJson(data)).toList();
  }

  Future<Plan> getPlanById(String id) async {
    final response = await _apiService.get('/api/plans/$id');
    return Plan.fromJson(response);
  }

  Future<List<Plan>> getPlansByCategory(String categoryId) async {
    final response = await _apiService.get('/api/plans/category/$categoryId');
    return (response as List).map((data) => Plan.fromJson(data)).toList();
  }

  Future<List<Plan>> getPlansByUser(String userId) async {
    final response = await _apiService.get('/api/plans/user/$userId');
    return (response as List).map((data) => Plan.fromJson(data)).toList();
  }

  Future<Plan> createPlan(Plan plan) async {
    final response = await _apiService.post('/api/plans', plan.toJson());
    return Plan.fromJson(response);
  }

  Future<Plan> updatePlan(String id, Plan plan) async {
    final response = await _apiService.put('/api/plans/$id', plan.toJson());
    return Plan.fromJson(response);
  }

  Future<void> deletePlan(String id) async {
    await _apiService.delete('/api/plans/$id');
  }

  Future<Map<String, dynamic>> getPlanStats() async {
    final response = await _apiService.get('/api/plans/stats');
    return response;
  }
}
