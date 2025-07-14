import 'package:flutter/material.dart';
import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../data/repositories/plan/plan_repository.dart';
import '../../../../domain/models/plan/plan.dart';
import '../../../../utils/result.dart';
import './plan_details_viewmodel.dart';

class FavoriteViewModel extends ChangeNotifier {
  final PlanRepository _planRepository;
  final AuthRepository _authRepository;

  bool get isFavorite => _isFavorite;
  bool _isFavorite = false;

  FavoriteViewModel(this._planRepository, this._authRepository);

  Future<void> initFavoriteStatus(String planId) async {
    final user = _authRepository.currentUser;
    if (user == null) return;
    print(user);

    final favoritesResult = await _planRepository.getFavoritesByUser(user.id!);
    if (favoritesResult is Ok<List<Plan>>) {
      _isFavorite = favoritesResult.value.any((p) => p.id == planId);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(
      Plan plan, PlanDetailsViewModel planViewModel) async {
    final user = _authRepository.currentUser;
    if (user == null || plan.id == null) return;

    try {
      if (plan.favorites!.contains(user.id)) {
        await _planRepository.removeFromFavorites(plan.id!);
        _isFavorite = false;
      } else {
        await _planRepository.addToFavorites(plan.id!);
        _isFavorite = true;
      }
      notifyListeners();

      planViewModel.updateFavoritesList(isFavorited: _isFavorite);
    } catch (_) {}
  }
}
