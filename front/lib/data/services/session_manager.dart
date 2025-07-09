import 'package:flutter/foundation.dart';

import '../../utils/result.dart';
import '../repositories/auth/auth_repository.dart';
import '../repositories/category/category_repository.dart';
import '../repositories/plan/plan_repository.dart';
import '../repositories/step/step_repository.dart';

/// Gère les actions transversales comme login/logout,
/// et vide les caches si nécessaire.
class SessionManager extends ChangeNotifier {
  SessionManager({
    required AuthRepository authRepository,
    required PlanRepository planRepository,
    required CategoryRepository categoryRepository,
    required StepRepository stepRepository,
  })  : _authRepository = authRepository,
        _planRepository = planRepository,
        _categoryRepository = categoryRepository,
        _stepRepository = stepRepository;

  final AuthRepository _authRepository;
  final PlanRepository _planRepository;
  final CategoryRepository _categoryRepository;
  final StepRepository _stepRepository;

  /// Connecte l'utilisateur et nettoie les caches pour repartir sur une base propre
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (result is Ok) {
        // Nettoyer les caches pour éviter les données d'un ancien utilisateur
        await _clearAllCaches();
      }
      return result;
    } catch (e) {
      return Result.error(Exception('Erreur de connexion: $e'));
    }
  }

  /// Déconnecte l'utilisateur et nettoie tous les caches
  Future<Result<void>> logout() async {
    try {
      final result = await _authRepository.logout();

      if (result is Ok<void>) {
        // Vider TOUS les caches
        await _clearAllCaches();

        notifyListeners();
      }

      return result;
    } catch (e) {
      return Result.error(Exception('Logout failed: $e'));
    }
  }

  /// Inscrit un nouvel utilisateur et nettoie les caches
  Future<Result<void>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final result = await _authRepository.register(
        email: email,
        username: username,
        password: password,
      );

      if (result is Ok) {
        // Nettoyer les caches pour repartir sur une base propre
        await _clearAllCaches();
      }

      return result;
    } catch (e) {
      return Result.error(Exception('Erreur d\'inscription: $e'));
    }
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    try {
      return await _authRepository.isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  /// Remet à zéro la session (nettoie tous les caches)
  /// Utile en cas d'erreur ou de changement d'utilisateur
  Future<void> resetSession() async {
    await _clearAllCaches();
  }

  /// Force la vérification de l'authentification et nettoie les caches si nécessaire
  Future<bool> checkAuthAndCleanIfNeeded() async {
    final isAuth = await isAuthenticated();

    if (!isAuth) {
      await _clearAllCaches();
    }

    return isAuth;
  }

  /// Nettoie tous les caches de l'application
  Future<void> _clearAllCaches() async {
    try {
      // Utiliser Future.wait pour paralléliser les opérations
      await Future.wait([
        _clearRepositoryCache(
            'Plans', () async => (_planRepository as dynamic).clearCache()),
        _clearRepositoryCache('Categories',
            () async => (_categoryRepository as dynamic).clearCache()),
        _clearRepositoryCache(
            'Steps', () async => (_stepRepository as dynamic).clearCache()),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du nettoyage des caches: $e');
      }
    } finally {
      if (kDebugMode) {
        print('✅ Tous les caches ont été nettoyés');
      }
    }
  }

  /// Helper pour nettoyer un cache spécifique avec gestion d'erreur
  Future<void> _clearRepositoryCache(
      String repositoryName, Future<void> Function() clearFunction) async {
    try {
      await clearFunction();
      if (kDebugMode) {
        print('  ✅ Cache $repositoryName nettoyé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('  ❌ Erreur lors du nettoyage du cache $repositoryName: $e');
      }
    }
  }

  /// Nettoie seulement les caches spécifiques (pour des cas particuliers)
  Future<void> clearSpecificCaches({
    bool plans = false,
    bool categories = false,
    bool steps = false,
    bool users = false,
  }) async {
    final clearOperations = <Future<void>>[];

    if (plans) {
      clearOperations.add(_clearRepositoryCache(
          'Plans', () async => (_planRepository as dynamic).clearCache()));
    }
    if (categories) {
      clearOperations.add(_clearRepositoryCache('Categories',
          () async => (_categoryRepository as dynamic).clearCache()));
    }
    if (steps) {
      clearOperations.add(_clearRepositoryCache(
          'Steps', () async => (_stepRepository as dynamic).clearCache()));
    }

    if (clearOperations.isNotEmpty) {
      await Future.wait(clearOperations);
      if (kDebugMode) {
        print('✅ Nettoyage sélectif terminé');
      }
    } else {
      if (kDebugMode) {
        print('ℹ️ Aucun cache sélectionné pour le nettoyage');
      }
    }
  }
}
