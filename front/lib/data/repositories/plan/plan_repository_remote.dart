import 'package:flutter/material.dart';

import '../../../domain/models/plan/plan.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import 'plan_repository.dart';

/// Remote data source for [Plan].
/// Implements caching using plan ID as the key.
class PlanRepositoryRemote implements PlanRepository {
  PlanRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  @visibleForTesting
  List<Plan>? get cachedData => _cachedData;

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
      "isAccessible": plan.isAccessible,
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

  @override
  Future<Result<List<Plan>>> getPlansByUser(String userId) {
    return _apiClient.getPlansByUser(userId).then((result) {
      switch (result) {
        case Ok<List<Plan>>():
          return Result.ok(result.value);
        case Error<List<Plan>>():
          return Result.error(result.error);
      }
    });
  }

  @override
  Future<Result<void>> deletePlan(String planId) {
    return _apiClient.deletePlan(planId).then((result) {
      switch (result) {
        case Ok<void>():
          _cachedData?.removeWhere((plan) => plan.id == planId);
          return const Result.ok(null);
        case Error<void>():
          return Result.error(result.error);
      }
    });
  }

  @override
  Future<Result<List<Plan>>> getFavoritesByUser(String userId) {
    return _apiClient.getFavoritesByUser(userId).then((result) {
      switch (result) {
        case Ok<List<Plan>>():
          return Result.ok(result.value);
        case Error<List<Plan>>():
          return Result.error(result.error);
      }
    });
  }

  @override
  Future<Result<Plan>> getPlan(String planId) {
    return _apiClient.getPlan(planId).then((result) {
      switch (result) {
        case Ok<Plan>():
          return Result.ok(result.value);
        case Error<Plan>():
          return Result.error(result.error);
      }
    });
  }
}
