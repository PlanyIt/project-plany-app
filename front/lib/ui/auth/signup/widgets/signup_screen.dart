import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/navigation/routes.dart';
import 'package:front/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:front/shared/widgets/common/custom_text_field.dart';
import 'package:front/shared/widgets/common/plany_logo.dart';
import 'package:front/ui/core/ui/button/plany_button.dart';
import 'package:front/providers/providers.dart';
import 'package:front/providers/auth/signup_provider.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to state changes for navigation
    ref.listen<SignupState>(signupProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go(Routes.dashboard);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingL),
          child: _SignupForm(),
        ),
      ),
    );
  }
}

class _SignupForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<_SignupForm> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _description.dispose();
    _password.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupProvider);
    final signupNotifier = ref.read(signupProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PlanyLogo(),
        const SizedBox(height: 40),
        CustomTextField(
          controller: _email,
          labelText: 'Email',
          hintText: 'Entrez votre email',
          prefixIcon: Icons.email,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _username,
          labelText: 'Nom d\'utilisateur',
          hintText: 'Entrez votre nom d\'utilisateur',
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _description,
          labelText: 'Description',
          hintText: 'Parlez-nous de vous',
          prefixIcon: Icons.description,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _password,
          labelText: 'Mot de passe',
          hintText: 'Entrez votre mot de passe',
          prefixIcon: Icons.lock,
          suffixIcon: obscurePassword ? Icons.visibility : Icons.visibility_off,
          obscureText: obscurePassword,
          onSuffixIconPressed: togglePasswordVisibility,
        ),
        const SizedBox(height: 24),
        PlanyButton(
          text: 'S\'inscrire',
          isLoading: signupState.isLoading,
          onPressed: () async {
            if (_email.text.isNotEmpty &&
                _username.text.isNotEmpty &&
                _description.text.isNotEmpty &&
                _password.text.isNotEmpty) {
              await signupNotifier.register(
                email: _email.text,
                username: _username.text,
                description: _description.text,
                password: _password.text,
              );
            }
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push(Routes.login),
          child: const Text('Déjà un compte ? Se connecter'),
        ),
      ],
    );
  }
}
