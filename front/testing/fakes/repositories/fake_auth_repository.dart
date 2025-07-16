import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/utils/result.dart';

class FakeAuthRepository extends AuthRepository {
  String? token = 'fake_token';
  User? _user = User(
    id: 'user1',
    username: 'TestUser',
    email: 'test@email.com',
  );

  @override
  Future<bool> get isAuthenticated async => token != null;

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    token = 'fake_token';
    _user = User(
      id: 'fake_id',
      username: 'fake_user',
      email: email,
    );
    notifyListeners();
    return Result.ok(null);
  }

  @override
  Future<Result<void>> logout() async {
    token = null;
    _user = null;

    notifyListeners();
    return const Result.ok(null);
  }

  @override
  User? get currentUser => _user;

  @override
  Future<Result<User>> getCurrentUser() async {
    // Corrigé : toujours retourne ok avec _user par défaut
    return Result.ok(_user!);
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    token = 'fake_token';
    _user = User(
      id: 'new_fake_id',
      username: username,
      email: email,
    );
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  void updateCurrentUser(User user) {
    _user = user;
    notifyListeners();
  }

  @override
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return const Result.ok(null);
  }

  /// Allows tests to set the authentication state directly.
  void setAuthenticated(bool authenticated, {User? user}) {
    if (authenticated) {
      token = 'fake_token';
      _user = user ??
          User(
            id: 'user1',
            username: 'TestUser',
            email: 'test@email.com',
          );
    } else {
      token = null;
      _user = null;
    }
    notifyListeners();
  }
}
