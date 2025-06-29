import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/application/session_manager.dart';
import 'package:front/utils/result.dart';
import 'package:front/providers/providers.dart';
import 'package:front/providers/ui/unified_state_management.dart';

// État global de l'application
class AppState extends UnifiedState {
  final bool isAuthenticated;

  const AppState({
    this.isAuthenticated = false,
    super.isLoading = false,
    super.error,
    super.isInitialized = false,
  });

  AppState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return AppState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  AppState copyWithBase({
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return copyWith(
      isLoading: isLoading,
      error: error,
      isInitialized: isInitialized,
    );
  }

  @override
  AppState clearError() {
    return copyWith(error: null);
  }

  @override
  AppState reset() {
    return const AppState();
  }
}

class AppNotifier extends StateNotifier<AppState>
    with UnifiedStateManagement<AppState> {
  AppNotifier(this._authRepository, this._sessionManager)
      : super(const AppState()) {
    _initialize();
  }

  final AuthRepository _authRepository;
  final SessionManager _sessionManager;

  Future<void> _initialize() async {
    await executeWithStateManagement(
      () async {
        final isAuth = await _authRepository.isAuthenticated;
        state = state.copyWith(
          isInitialized: true,
          isAuthenticated: isAuth,
        );
      },
    );
  }

  Future<void> logout() async {
    await executeWithStateManagement(
      () async {
        final result = await _sessionManager.logout();
        switch (result) {
          case Ok():
            state = state.copyWith(
              isAuthenticated: false,
            );
            break;
          case Error():
            throw Exception('Erreur lors de la déconnexion');
        }
      },
    );
  }

  Future<bool> checkAuthStatus() async {
    return await executeWithStateManagement(
          () async {
            final isAuth = await _authRepository.isAuthenticated;
            state = state.copyWith(isAuthenticated: isAuth);
            return isAuth;
          },
        ) ??
        false;
  }

  void setAuthenticated(bool isAuthenticated) {
    state = state.copyWith(isAuthenticated: isAuthenticated);
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier(
    ref.read(authRepositoryProvider),
    ref.read(sessionManagerProvider),
  );
});
