import 'package:flutter/foundation.dart';

import '../../../domain/models/user/user.dart';
import '../../../utils/result.dart';

abstract class AuthRepository extends ChangeNotifier {
  /// Returns true when the user is logged in
  /// Returns [Future] because it will load a stored auth state the first time.
  Future<bool> get isAuthenticated;

  User? get currentUser;

  /// Perform login
  Future<Result<void>> login({required String email, required String password});

  /// Perform logout
  Future<Result<void>> logout();

  // Perform registration
  Future<Result<void>> register({
    required String email,
    required String username,
    required String password,
  });

  @override
  void dispose() {
    super.dispose();
  }
}
