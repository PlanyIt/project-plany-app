import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/utils/result.dart';

class FakePlanRepository extends PlanRepository {
  final List<Plan> _plans = [
    Plan(
      id: 'plan1',
      title: 'Plan 1',
      description: 'Description 1',
      category: Category(id: '1', name: 'Cat1', icon: 'icon1', color: 'FF0000'),
      user: User(id: 'user1', username: 'User1', email: 'user1@email.com'),
      steps: [],
    ),
    Plan(
      id: 'plan2',
      title: 'Plan 2',
      description: 'Description 2',
      category: Category(id: '2', name: 'Cat2', icon: 'icon2', color: '00FF00'),
      user: User(id: 'user2', username: 'User2', email: 'user2@email.com'),
      steps: [],
    ),
  ];
  final List<String> _favoritePlanIds = [];
  int _idCounter = 0;

  List<Plan> get plans => _plans;

  /// Permet de forcer le résultat de createPlan dans les tests.
  Result<Plan>? createPlanResult;

  @override
  Future<Result<List<Plan>>> getPlanList() async {
    return Result.ok(List<Plan>.from(_plans));
  }

  @override
  Future<Result<Plan>> getPlan(String planId) async {
    final plan = _plans.firstWhere(
      (p) => p.id == planId,
      orElse: () => Plan(
        id: planId,
        title: 'Unknown',
        description: 'Unknown',
        category: Category(id: 'cat1', name: 'Catégorie', icon: 'icon'),
        user: User(id: 'user1', username: 'user', email: 'email'),
        steps: [],
      ),
    );
    return Result.ok(plan);
  }

  @override
  Future<Result<Plan>> createPlan(Plan plan) async {
    if (createPlanResult != null) {
      return createPlanResult!;
    }
    final newPlan = plan.copyWith(id: 'plan_${_idCounter++}');
    _plans.add(newPlan);
    return Result.ok(newPlan);
  }

  @override
  Future<Result<void>> addToFavorites(String planId) async {
    if (!_favoritePlanIds.contains(planId)) {
      _favoritePlanIds.add(planId);
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> removeFromFavorites(String planId) async {
    _favoritePlanIds.remove(planId);
    return const Result.ok(null);
  }

  @override
  Future<void> clearCache() async {
    _plans.clear();
    _favoritePlanIds.clear();
  }

  @override
  Future<Result<List<Plan>>> getPlansByUser(String userId) async {
    return Result.ok(List<Plan>.from(_plans));
  }

  @override
  Future<Result<void>> deletePlan(String planId) async {
    _plans.removeWhere((p) => p.id == planId);
    _favoritePlanIds.remove(planId);
    return const Result.ok(null);
  }

  @override
  Future<Result<List<Plan>>> getFavoritesByUser(String userId) async {
    final favorites =
        _plans.where((p) => _favoritePlanIds.contains(p.id)).toList();
    return Result.ok(favorites);
  }
}
