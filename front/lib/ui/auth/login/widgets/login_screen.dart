import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/routing/routes.dart';
import 'package:front/ui/core/theme/app_theme.dart';
import 'package:front/shared/widgets/common/custom_text_field.dart';
import 'package:front/ui/core/ui/button/plany_button.dart';
import 'package:front/shared/widgets/common/plany_logo.dart';
import 'package:front/providers/auth/login_provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter les changements d'état pour la navigation
    ref.listen<LoginState>(loginProvider, (previous, next) {
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
          child: _LoginForm(),
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
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
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);

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
          text: 'Se connecter',
          isLoading: loginState.isLoading,
          onPressed: () async {
            if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
              await loginNotifier.login(_email.text, _password.text);
            }
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push(Routes.register),
          child: const Text('Pas encore de compte ? S\'inscrire'),
        ),
      ],
    );
  }
}
