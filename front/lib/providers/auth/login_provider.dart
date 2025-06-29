import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/utils/result.dart';
import 'package:front/providers/providers.dart';
import 'package:front/providers/ui/unified_state_management.dart';

class LoginState extends UnifiedState {
  final bool isAuthenticated;

  const LoginState({
    this.isAuthenticated = false,
    super.isLoading = false,
    super.error,
    super.isInitialized = false,
  });

  LoginState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return LoginState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  LoginState copyWithBase({
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
  LoginState clearError() {
    return copyWith(error: null);
  }

  @override
  LoginState reset() {
    return const LoginState();
  }
}

class LoginNotifier extends StateNotifier<LoginState>
    with UnifiedStateManagement<LoginState> {
  LoginNotifier(this._authRepository) : super(const LoginState());

  final AuthRepository _authRepository;

  Future<bool> login(String email, String password) async {
    return await executeWithStateManagement(
          () async {
            final result =
                await _authRepository.login(email: email, password: password);

            switch (result) {
              case Ok():
                state = state.copyWith(isAuthenticated: true);
                return true;
              case Error():
                throw Exception(
                    'Échec de la connexion. Vérifiez vos identifiants.');
            }
          },
        ) ??
        false;
  }

  Future<bool> isAuthenticated() async {
    try {
      final isAuth = await _authRepository.isAuthenticated;
      state = state.copyWith(isAuthenticated: isAuth);
      return isAuth;
    } catch (e) {
      return false;
    }
  }

  void clearLoginError() {
    clearError();
  }

  void reset() {
    resetState();
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.read(authRepositoryProvider));
});
