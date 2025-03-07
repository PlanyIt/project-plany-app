import 'package:flutter/material.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/widgets/button/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Méthode pour gérer la connexion
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Si l'un des champs est vide, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Tentative de connexion via le service Firebase
      final user = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Rediriger l'utilisateur vers l'écran d'accueil après la connexion réussie
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      // Si la connexion échoue, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion échouée : $e')),
      );
      print('Login failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode pour rediriger vers l'écran de réinitialisation du mot de passe
  void _resetPassword() {
    Navigator.pushNamed(context,
        '/reset-password'); // Redirige vers une page de réinitialisation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  // Lien pour réinitialiser le mot de passe
                  TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: "Connexion",
                      onPressed: _login,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
