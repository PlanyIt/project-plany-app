import 'package:flutter/material.dart';
import 'package:front/services/auth_service.dart'; // Import de AuthService
import 'package:front/widgets/buttons/primarybutton.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService =
      AuthService(); // Création de l'instance d'AuthService

  // Méthode pour gérer l'inscription via AuthService
  Future<void> _signup() async {
    if (_emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _passwordController.text.isEmpty) {
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
      // Appel du service AuthService pour l'inscription sur Firebase
      final user = await _authService.register(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
        _descriptionController.text,
      );

      if (user != null) {
        // Sauvegarder les informations de l'utilisateur dans MongoDB après l'inscription Firebase
        await _authService.saveUserToMongoDB(
          user.uid, // L'UID Firebase de l'utilisateur
          _usernameController.text,
          _descriptionController.text,
          _emailController.text,
        );
      }

      // Rediriger l'utilisateur vers l'écran de connexion après l'inscription réussie
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Afficher un message d'erreur si l'inscription échoue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription échouée : $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
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
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                    ),
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: _signup,
                      text: 'Inscription',
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
    _usernameController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
