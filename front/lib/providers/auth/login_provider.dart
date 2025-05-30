import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/utils/messages.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Messages.fillAllFields)),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(
        emailController.text,
        passwordController.text,
      );

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Utilisateur non trouvé.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mot de passe incorrect.';
      } else {
        errorMessage = Messages.loginFailed;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void navigateToResetPassword(BuildContext context) {
    Navigator.pushNamed(context, '/reset-password');
  }

  void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }
}
