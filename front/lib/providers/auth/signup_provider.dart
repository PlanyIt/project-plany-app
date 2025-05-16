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

  Future<void> signup(BuildContext context) async {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.register(
        emailController.text,
        passwordController.text,
        usernameController.text,
        descriptionController.text,
      );

      if (user != null) {
        await _authService.saveUserToMongoDB(
          user.uid,
          usernameController.text,
          descriptionController.text,
          emailController.text,
        );
      }

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription échouée : $e')),
      );
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
