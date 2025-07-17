import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/repositories/auth/auth_repository_remote.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/utils/result.dart';

import '../../../../testing/fakes/services/fake_api_client.dart';
import '../../../../testing/fakes/services/fake_auth_api_client.dart';
import '../../../../testing/fakes/services/fake_auth_storage_service.dart';

void main() {
  group('AuthRepositoryRemote tests', () {
    late FakeApiClient apiClient;
    late FakeAuthApiClient authApiClient;
    late FakeAuthStorageService authStorageService;
    late AuthRepositoryRemote repository;

    setUp(() {
      apiClient = FakeApiClient();
      authApiClient = FakeAuthApiClient();
      authStorageService = FakeAuthStorageService();
      repository = AuthRepositoryRemote(
        apiClient: apiClient,
        authApiClient: authApiClient,
        authStorageService: authStorageService,
      );
    });

    test('fetch on start, has token', () async {
      authStorageService.accessToken = 'TOKEN';
      authStorageService.refreshToken = 'REFRESH';

      final repository = AuthRepositoryRemote(
        apiClient: apiClient,
        authApiClient: authApiClient,
        authStorageService: authStorageService,
      );

      final isAuthenticated = await repository.isAuthenticated;

      expect(isAuthenticated, isTrue);
      await expectAuthHeader(apiClient, 'Bearer TOKEN');
    });

    test('fetch on start, no token', () async {
      authStorageService.accessToken = null;
      authStorageService.refreshToken = null;

      final repository = AuthRepositoryRemote(
        apiClient: apiClient,
        authApiClient: authApiClient,
        authStorageService: authStorageService,
      );

      final isAuthenticated = await repository.isAuthenticated;

      expect(isAuthenticated, isFalse);
      await expectAuthHeader(apiClient, null);
    });

    test('perform login', () async {
      final result = await repository.login(
        email: 'user@email.com',
        password: 'password123',
      );
      expect(result, isA<Ok>());
      expect(await repository.isAuthenticated, isTrue);
      expect(authStorageService.accessToken, isNotNull);
      await expectAuthHeader(
          apiClient, 'Bearer ${authStorageService.accessToken}');
    });

    test('perform register success', () async {
      final result = await repository.register(
        email: 'user@email.com',
        username: 'username',
        password: 'password123',
      );
      expect(result, isA<Ok>());
      expect(await repository.isAuthenticated, isTrue);
      expect(authStorageService.accessToken, isNotNull);
    });

    test('perform register failure', () async {
      final result = await repository.register(
        email: '',
        username: 'username',
        password: 'password',
      );
      expect(result, isA<Error>());
      expect(await repository.isAuthenticated, isFalse);
    });

    test('perform logout', () async {
      authStorageService.accessToken = 'TOKEN';
      authStorageService.refreshToken = 'REFRESH';

      final result = await repository.logout();
      expect(result, isA<Ok>());
      expect(await repository.isAuthenticated, isFalse);
      expect(authStorageService.accessToken, isNull);
      expect(authStorageService.refreshToken, isNull);
      await expectAuthHeader(apiClient, null);
    });

    test('get current user fallback to storage', () async {
      authStorageService.userJson =
          '{"id": "1", "username": "test", "email": "test@email.com"}';
      repository = AuthRepositoryRemote(
        apiClient: apiClient,
        authApiClient: authApiClient,
        authStorageService: authStorageService,
      );
      final user = await repository.getCurrentUser();
      expect(user, isA<Ok>());
    });

    test('update password success', () async {
      final result = await repository.updatePassword(
        currentPassword: 'oldpass',
        newPassword: 'newpass',
      );
      expect(result, isA<Ok>());
    });

    test('get current user fails when none', () async {
      final user = await repository.getCurrentUser();
      expect(user, isA<Error>());
    });

    test('update current user updates storage', () async {
      final user =
          User(id: '1', username: 'updated', email: 'updated@email.com');
      repository.updateCurrentUser(user);
      expect(authStorageService.userJson, isNotNull);
    });

    test('fetch from storage with invalid user JSON', () async {
      authStorageService.accessToken = 'TOKEN';
      authStorageService.refreshToken = 'REFRESH';
      authStorageService.userJson = 'invalid json';
      await repository.isAuthenticated;
      expect(authStorageService.userJson, isNull);
    });

    test('perform register success', () async {
      final result = await repository.register(
        email: 'user@email.com',
        username: 'username',
        password: 'password123',
      );
      expect(result, isA<Ok>());
      expect(await repository.isAuthenticated, isTrue);
      expect(authStorageService.accessToken, isNotNull);
    });

    test('token expiration triggers silent refresh', () async {
      // Set up tokens and expiration in the past
      authStorageService.accessToken = 'TOKEN';
      authStorageService.refreshToken = 'fake_refresh_token';
      repository = AuthRepositoryRemote(
        apiClient: apiClient,
        authApiClient: authApiClient,
        authStorageService: authStorageService,
      );
      // Force fetch from storage
      await repository.isAuthenticated;
      // Simulate expired token
      repository.tokenExpiration =
          DateTime.now().subtract(const Duration(seconds: 1));
      // Should trigger silent refresh on header access
      final header = apiClient.authHeaderProvider?.call();
      expect(header, 'Bearer TOKEN');
      // Wait for silent refresh to complete
      await Future.delayed(const Duration(milliseconds: 100));
      // After refresh, header should be updated
      final refreshedHeader = apiClient.authHeaderProvider?.call();
      expect(refreshedHeader, startsWith('Bearer'));
    });

    test('updateCurrentUser notifies listeners', () async {
      bool notified = false;
      repository.addListener(() {
        notified = true;
      });
      final user = User(id: '2', username: 'new', email: 'new@email.com');
      repository.updateCurrentUser(user);
      expect(repository.currentUser, user);
      expect(notified, isTrue);
    });

    test('logout clears all state and notifies listeners', () async {
      bool notified = false;
      repository.addListener(() {
        notified = true;
      });
      authStorageService.accessToken = 'TOKEN';
      authStorageService.refreshToken = 'REFRESH';
      await repository.logout();
      expect(await repository.isAuthenticated, isFalse);
      expect(repository.currentUser, isNull);
      expect(notified, isTrue);
    });

    test('login error returns Error', () async {
      final result = await repository.login(email: 'bad', password: 'bad');
      expect(result, isA<Error>());
      expect(await repository.isAuthenticated, isFalse);
    });

    test('register error returns Error', () async {
      final result =
          await repository.register(email: '', username: '', password: '');
      expect(result, isA<Error>());
      expect(await repository.isAuthenticated, isFalse);
    });
  });
}

Future<void> expectAuthHeader(
    FakeApiClient apiClient, String? expectedHeader) async {
  final header = apiClient.authHeaderProvider?.call();
  expect(header, expectedHeader);
}
