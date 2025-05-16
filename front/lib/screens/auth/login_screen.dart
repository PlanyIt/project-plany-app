import 'package:flutter/material.dart';
import 'package:front/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:front/widgets/common/custom_text_field.dart';
import 'package:front/providers/auth/login_provider.dart';
import 'package:front/widgets/common/plany_logo.dart';
import 'package:front/widgets/common/plany_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: Scaffold(
        body: Stack(
          children: [
            Consumer<LoginProvider>(
              builder: (context, provider, _) {
                return provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.paddingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              _buildLogo(),
                              const SizedBox(height: 40),
                              _buildWelcomeText(context),
                              const SizedBox(height: 40),
                              CustomTextField(
                                controller: provider.emailController,
                                labelText: 'Email',
                                hintText: 'Entrez votre email',
                                prefixIcon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: provider.passwordController,
                                labelText: 'Mot de passe',
                                hintText: 'Entrez votre mot de passe',
                                prefixIcon: Icons.lock_outline,
                                obscureText: provider.obscurePassword,
                                suffixIcon: provider.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                onSuffixIconPressed:
                                    provider.togglePasswordVisibility,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      provider.navigateToResetPassword(context),
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              PlanyButton(
                                text: 'Connexion',
                                onPressed: () => provider.login(context),
                              ),
                              const SizedBox(height: 20),
                              _buildRegisterLink(context, provider),
                            ],
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: PlanyLogo(fontSize: 50),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connexion',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenue ! Veuillez vous connecter pour continuer',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(BuildContext context, LoginProvider provider) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Pas encore de compte ? ',
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          TextButton(
            onPressed: () => provider.navigateToRegister(context),
            child: Text(
              'S\'enregistrer',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
