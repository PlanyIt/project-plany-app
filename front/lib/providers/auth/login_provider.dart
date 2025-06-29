import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/utils/result.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this._authRepository) : super(const LoginState());

  final AuthRepository _authRepository;

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result =
        await _authRepository.login(email: email, password: password);

    switch (result) {
      case Ok():
        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: 'Échec de la connexion. Vérifiez vos identifiants.',
        );
        return false;
    }
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

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const LoginState();
  }
}
