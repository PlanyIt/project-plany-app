import 'package:flutter/foundation.dart';
import 'package:front/domain/models/user.dart';
import 'package:front/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading =
      true; // Commence par true pour indiquer la vérification initiale
  bool _isAuthenticated = false;
  final AuthService _authService = AuthService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    // Vérifier l'état d'authentification au démarrage
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('Vérification de l\'état d\'authentification...');
      }

      _isAuthenticated = await _authService.isAuthenticated();

      if (_isAuthenticated) {
        _user = await _authService.getUser();
        if (kDebugMode) {
          print('Utilisateur authentifié: ${_user?.username}');
        }
      } else {
        if (kDebugMode) {
          print('Aucun utilisateur authentifié');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la vérification de l\'authentification: $e');
      }
      _isAuthenticated = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String description, String email,
      String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user =
          await _authService.register(username, description, email, password);
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _isAuthenticated = false;
      _user = null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la déconnexion: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
