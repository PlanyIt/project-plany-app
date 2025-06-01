import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:dashboard/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final UserService _userService = UserService();

  firebase_auth.User? get currentUser => _auth.currentUser;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // For development mode, bypass actual Firebase authentication
      if (kDebugMode &&
          email == "admin@example.com" &&
          password == "password123") {
        // Wait a moment to simulate network request
        await Future.delayed(const Duration(milliseconds: 500));
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Normal authentication flow
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final isAdmin = await checkAdminRole(_auth.currentUser!.uid);
      if (!isAdmin) {
        await _auth.signOut();
        _error = 'Only admin users can access the dashboard';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> checkAdminRole(String uid) async {
    try {
      if (kDebugMode) {
        // Always return true in debug mode
        return true;
      }

      final user = await _userService.getUserByFirebaseId(uid);
      return user != null && user.role == 'admin';
    } catch (e) {
      if (kDebugMode) {
        print('Error checking admin role: $e');
      }
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
