import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/core/utils/result.dart';
import 'package:front/providers/providers.dart';
import 'package:front/providers/ui/unified_state_management.dart';

class SignupState extends UnifiedState {
  final bool isAuthenticated;

  const SignupState({
    this.isAuthenticated = false,
    super.isLoading = false,
    super.error,
    super.isInitialized = false,
  });

  SignupState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return SignupState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  SignupState copyWithBase({
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
  SignupState clearError() {
    return copyWith(error: null);
  }

  @override
  SignupState reset() {
    return const SignupState();
  }
}

class SignupNotifier extends StateNotifier<SignupState>
    with UnifiedStateManagement<SignupState> {
  SignupNotifier(this._authRepository) : super(const SignupState());

  final AuthRepository _authRepository;

  Future<bool> register({
    required String email,
    required String username,
    required String description,
    required String password,
  }) async {
    return await executeWithStateManagement(
          () async {
            final result = await _authRepository.register(
              email: email,
              username: username,
              description: description,
              password: password,
            );

            switch (result) {
              case Ok():
                state = state.copyWith(isAuthenticated: true);
                return true;
              case Error():
                throw Exception(
                    'Échec de l\'inscription. Vérifiez vos informations.');
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

  void clearSignupError() {
    clearError();
  }
}

final signupProvider =
    StateNotifierProvider<SignupNotifier, SignupState>((ref) {
  return SignupNotifier(ref.read(authRepositoryProvider));
});
