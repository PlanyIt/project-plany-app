import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/core/utils/result.dart';
import 'package:front/core/utils/exceptions.dart';
import 'package:logging/logging.dart';

/// Remote data source for [Plan].
/// Implements caching using plan ID as the key.
class PlanRepositoryRemote implements PlanRepository {
  PlanRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;
  final _log = Logger('PlanRepositoryRemote');

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
    try {
      if (_cachedData.isEmpty) {
        _log.info('Fetching plans from API');
        final result = await _apiClient.getPlans();

        switch (result) {
          case Ok<List<Plan>>():
            _cachedData.addEntries(
              result.value.where((plan) => plan.id != null).map(
                    (plan) => MapEntry(plan.id!, plan),
                  ),
            );
            _log.info('Successfully cached ${result.value.length} plans');
            return result;
          case Error<List<Plan>>():
            _log.warning('Failed to fetch plans: ${result.error}');
            return result;
        }
      } else {
        _log.info('Returning cached plans (${cachedData.length} items)');
        return Result.ok(cachedData);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error getting plans list', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la récupération des plans'),
      );
    }
  }

  @override
  Future<Result<Plan>> createPlan(Plan plan) async {
    try {
      // Validate input
      if (plan.title.isEmpty) {
        _log.warning('createPlan called with empty title');
        return Result.error(
          const ValidationException('Le titre du plan est requis'),
        );
      }
      if (plan.userId?.isEmpty ?? true) {
        _log.warning('createPlan called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      _log.info("Creating plan with title: ${plan.title}");
      final Map<String, dynamic> payload = {
        "title": plan.title,
        "description": plan.description,
        "category": plan.category,
        "userId": plan.userId,
        "steps": plan.steps,
        "isPublic": plan.isPublic,
      };

      final result = await _apiClient.createPlan(body: payload);

      switch (result) {
        case Ok<Plan>():
          final newPlan = result.value;
          if (newPlan.id != null) {
            _cachedData[newPlan.id!] = newPlan;
            _log.info('Successfully created and cached plan: ${newPlan.id}');
          }
          return result;
        case Error<Plan>():
          _log.warning('Failed to create plan: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error creating plan', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la création du plan'),
      );
    }
  }

  @override
  Future<Result<Plan>> getPlanById(String id) async {
    try {
      // Validate input
      if (id.isEmpty) {
        _log.warning('getPlanById called with empty ID');
        return Result.error(
          const ValidationException('ID du plan requis'),
        );
      }

      if (_cachedData.containsKey(id)) {
        _log.info('Plan found in cache: $id');
        return Result.ok(_cachedData[id]!);
      }

      _log.info('Fetching plan from API: $id');
      final result = await _apiClient.getPlanById(id);

      switch (result) {
        case Ok<Plan>():
          final plan = result.value;
          if (plan.id != null) {
            _cachedData[plan.id!] = plan;
            _log.info('Successfully fetched and cached plan: $id');
          }
          return result;
        case Error<Plan>():
          _log.warning('Failed to fetch plan $id: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error getting plan by ID: $id', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la récupération du plan'),
      );
    }
  }

  @override
  Future<Result<Plan>> updatePlan(
      String planId, Map<String, dynamic> data) async {
    try {
      // Validate input
      if (planId.isEmpty) {
        _log.warning('updatePlan called with empty planId');
        return Result.error(
          const ValidationException('ID du plan requis'),
        );
      }

      if (data.isEmpty) {
        _log.warning('updatePlan called with empty data');
        return Result.error(
          const ValidationException('Données de mise à jour requises'),
        );
      }

      // Validate title if provided
      if (data.containsKey('title') && (data['title'] as String).isEmpty) {
        return Result.error(
          const ValidationException('Le titre du plan ne peut pas être vide'),
        );
      }

      _log.info('Updating plan: $planId');
      final result = await _apiClient.updatePlan(planId, data);

      switch (result) {
        case Ok<Plan>():
          final updatedPlan = result.value;
          if (updatedPlan.id != null) {
            _cachedData[updatedPlan.id!] = updatedPlan;
            _log.info('Successfully updated and cached plan: $planId');
          }
          return result;
        case Error<Plan>():
          _log.warning('Failed to update plan $planId: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error updating plan: $planId', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la mise à jour du plan'),
      );
    }
  }

  @override
  Future<Result<void>> deletePlan(String planId) async {
    try {
      // Validate input
      if (planId.isEmpty) {
        _log.warning('deletePlan called with empty planId');
        return Result.error(
          const ValidationException('ID du plan requis'),
        );
      }

      _log.info('Deleting plan: $planId');
      final result = await _apiClient.deletePlan(planId);

      switch (result) {
        case Ok<void>():
          _cachedData.remove(planId);
          _log.info(
              'Successfully deleted plan and removed from cache: $planId');
          return result;
        case Error<void>():
          _log.warning('Failed to delete plan $planId: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error deleting plan: $planId', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la suppression du plan'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> addToFavorites(String planId) async {
    try {
      // Validate input
      if (planId.isEmpty) {
        _log.warning('addToFavorites called with empty planId');
        return Result.error(
          const ValidationException('ID du plan requis'),
        );
      }

      _log.info('Adding plan to favorites: $planId');
      final result = await _apiClient.addPlanToFavorites(planId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          _log.info('Successfully added plan to favorites: $planId');
          return result;
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to add plan to favorites: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error adding plan to favorites: $planId', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de l\'ajout aux favoris'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> removeFromFavorites(
      String planId) async {
    try {
      // Validate input
      if (planId.isEmpty) {
        _log.warning('removeFromFavorites called with empty planId');
        return Result.error(
          const ValidationException('ID du plan requis'),
        );
      }

      _log.info('Removing plan from favorites: $planId');
      final result = await _apiClient.removePlanFromFavorites(planId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          _log.info('Successfully removed plan from favorites: $planId');
          return result;
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to remove plan from favorites: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error removing plan from favorites: $planId', e,
          stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la suppression des favoris'),
      );
    }
  }

  @override
  Future<Result<List<Plan>>> getPlansByUserId(String userId) async {
    try {
      // Validate input
      if (userId.isEmpty) {
        _log.warning('getPlansByUserId called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      _log.info('Fetching plans for user: $userId');
      final result = await _apiClient.getPlansByUserId(userId);

      switch (result) {
        case Ok<List<Plan>>():
          _log.info(
              'Successfully fetched ${result.value.length} plans for user: $userId');
          return result;
        case Error<List<Plan>>():
          _log.warning(
              'Failed to fetch plans for user $userId: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error getting plans by user ID: $userId', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la récupération des plans utilisateur'),
      );
    }
  }

  @override
  Future<Result<List<Plan>>> getFavoritesByUserId(String userId) async {
    try {
      // Validate input
      if (userId.isEmpty) {
        _log.warning('getFavoritesByUserId called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      _log.info('Fetching favorites for user: $userId');
      final result = await _apiClient.getFavoritesByUserId(userId);

      switch (result) {
        case Ok<List<Plan>>():
          _log.info(
              'Successfully fetched ${result.value.length} favorites for user: $userId');
          return result;
        case Error<List<Plan>>():
          _log.warning(
              'Failed to fetch favorites for user $userId: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error getting favorites by user ID: $userId', e,
          stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la récupération des favoris'),
      );
    }
  }
}
