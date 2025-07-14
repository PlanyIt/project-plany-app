import 'package:flutter/material.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../utils/result.dart';

class FavoritesViewModel extends ChangeNotifier {
  final PlanRepository planRepository;

  FavoritesViewModel({required this.planRepository});

  List<Plan> favorites = [];
  bool isLoading = true;
  int displayLimit = 5;

  List<Plan> get displayedFavorites => favorites.take(displayLimit).toList();

  Future<void> loadFavorites(String userId) async {
    isLoading = true;
    notifyListeners();

    final result = await planRepository.getFavoritesByUser(userId);
    if (result is Ok<List<Plan>>) {
      favorites = result.value;
    }

    isLoading = false;
    notifyListeners();
  }

  void showMore() {
    displayLimit += 5;
    notifyListeners();
  }

  Future<void> removeFavorite(String planId, String userId) async {
    final result = await planRepository.removeFromFavorites(planId);
    if (result is Ok<void>) {
      favorites.removeWhere((p) => p.id == planId);
      await loadFavorites(userId);
    }
  }
}
