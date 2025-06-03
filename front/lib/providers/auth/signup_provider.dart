import 'package:flutter/material.dart';
import 'package:front/services/auth_service.dart';

class SignupProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> signup(Function onSuccess, Function(String) onError) async {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        passwordController.text.isEmpty) {
      onError('Veuillez remplir tous les champs.');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.register(
        usernameController.text,
        descriptionController.text,
        emailController.text,
        passwordController.text,
      );

      // Vérifier que l'utilisateur a bien été retourné
      if (user != null) {
        onSuccess();
      } else {
        onError('Échec de l\'inscription: aucun utilisateur retourné');
      }
    } catch (e) {
      String errorMessage = 'Inscription échouée';

      // Extraire le message d'erreur de l'exception
      final exceptionMessage = e.toString();
      if (exceptionMessage.contains('Exception:')) {
        errorMessage = exceptionMessage.replaceAll('Exception:', '').trim();
      } else {
        errorMessage = '$errorMessage: $exceptionMessage';
      }

      onError(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
