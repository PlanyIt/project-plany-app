// filepath: c:\Users\gaell\Documents\Dev\plany\front\lib\providers\ui\unified_state_management.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/utils/error_handler.dart';
import 'package:front/core/utils/result.dart' as result_utils;
import 'package:logging/logging.dart';

// ============================================================================
// ARCHITECTURE UNIFIÉE DE GESTION D'ÉTAT
// ============================================================================

/// Classe d'état de base unifiée pour tous les providers
abstract class UnifiedState {
  const UnifiedState({
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  final bool isLoading;
  final String? error;
  final bool isInitialized;

  /// Méthode abstraite pour copier l'état avec les propriétés de base
  UnifiedState copyWithBase({
    bool? isLoading,
    String? error,
    bool? isInitialized,
  });

  /// Méthode abstraite pour nettoyer l'erreur
  UnifiedState clearError();

  /// Méthode abstraite pour réinitialiser l'état
  UnifiedState reset();
}

/// Mixin unifié pour la gestion d'état dans les StateNotifiers
mixin UnifiedStateManagement<T extends UnifiedState> on StateNotifier<T> {
  final _log = Logger('UnifiedStateManagement');

  /// Exécute une action avec gestion automatique du loading et des erreurs
  Future<R?> executeWithStateManagement<R>(
    Future<R> Function() action, {
    String? context,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      state = state.copyWithBase(isLoading: true, error: null) as T;
    }

    try {
      final result = await action();

      if (showLoading) {
        state = state.copyWithBase(isLoading: false) as T;
      }

      return result;
    } catch (error, stackTrace) {
      ErrorHandler.logError(error, stackTrace, context);

      final errorMessage = ErrorHandler.handleError(error);

      state = state.copyWithBase(
        isLoading: false,
        error: errorMessage,
      ) as T;

      return null;
    }
  }

  /// Exécute une opération qui renvoie un type Result
  Future<R?> executeResultOperation<R>(
    Future<result_utils.Result<R>> Function() operation, {
    String? context,
    bool showLoading = true,
  }) async {
    return executeWithStateManagement(
      () async {
        final result = await operation();
        switch (result) {
          case result_utils.Ok<R>():
            return result.value;
          case result_utils.Error<R>():
            throw result.error;
        }
      },
      context: context,
      showLoading: showLoading,
    );
  }

  /// Nettoie l'erreur courante
  void clearError() {
    state = state.clearError() as T;
  }

  /// Réinitialise complètement l'état
  void resetState() {
    state = state.reset() as T;
  }

  /// Vérifie si l'erreur courante est récupérable
  bool get isRecoverableError {
    if (state.error == null) return false;

    // Cela doit être implémenté en fonction de vos types d'erreurs
    // Pour l'instant, supposons que les erreurs de réseau et de délai d'attente sont récupérables
    return state.error!.contains('réseau') ||
        state.error!.contains('timeout') ||
        state.error!.contains('serveur');
  }

  /// Obtient un message de réessai pour l'erreur courante
  String? get retryMessage {
    if (state.error == null) return null;

    if (state.error!.contains('réseau')) {
      return 'Vérifiez votre connexion et réessayez';
    } else if (state.error!.contains('timeout')) {
      return 'Délai d\'attente dépassé, réessayez';
    } else if (state.error!.contains('serveur')) {
      return 'Problème serveur, réessayez plus tard';
    }
    return 'Réessayez plus tard';
  }
}
