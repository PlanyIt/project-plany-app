import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/application/session_manager.dart';
import 'package:front/utils/result.dart';
import 'package:front/providers/providers.dart';

// État global de l'application
class AppState {
  final bool isInitialized;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AppState({
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier(this._authRepository, this._sessionManager)
      : super(const AppState()) {
    _initialize();
  }

  final AuthRepository _authRepository;
  final SessionManager _sessionManager;

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final isAuth = await _authRepository.isAuthenticated;
      state = state.copyWith(
        isInitialized: true,
        isAuthenticated: isAuth,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final result = await _sessionManager.logout();
    switch (result) {
      case Ok():
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
        break;
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: 'Erreur lors de la déconnexion',
        );
        break;
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      final isAuth = await _authRepository.isAuthenticated;
      state = state.copyWith(isAuthenticated: isAuth);
      return isAuth;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier(
    ref.read(authRepositoryProvider),
    ref.read(sessionManagerProvider),
  );
});
