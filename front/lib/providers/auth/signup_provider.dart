import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/utils/result.dart';

class SignupState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const SignupState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  SignupState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class SignupNotifier extends StateNotifier<SignupState> {
  SignupNotifier(this._authRepository) : super(const SignupState());

  final AuthRepository _authRepository;

  Future<bool> register({
    required String email,
    required String username,
    required String description,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.register(
      email: email,
      username: username,
      description: description,
      password: password,
    );

    switch (result) {
      case Ok():
        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      case Error():
        state = state.copyWith(
            isLoading: false,
            error: 'Échec de l\'inscription. Vérifiez vos informations.');
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
}
