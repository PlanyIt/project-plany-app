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

  Future<void> login(Function onSuccess, Function(String) onError) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      onError(Messages.fillAllFields);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _authService.login(
        emailController.text,
        passwordController.text,
      );

      onSuccess();
    } catch (e) {
      String errorMessage;

      // Extraire le message d'erreur de l'exception
      final exceptionMessage = e.toString();
      if (exceptionMessage.contains('Exception:')) {
        errorMessage = exceptionMessage.replaceAll('Exception:', '').trim();
      } else {
        errorMessage = '${Messages.loginFailed} ${e.toString()}';
      }

      onError(errorMessage);
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
