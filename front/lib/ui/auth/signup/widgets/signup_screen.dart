import 'package:flutter/material.dart';
import 'package:front/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:front/widgets/common/custom_text_field.dart';
import 'package:front/providers/auth/signup_provider.dart';
import 'package:front/widgets/common/plany_logo.dart';
import 'package:front/widgets/common/plany_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Consumer<SignupProvider>(
              builder: (context, provider, _) {
                return provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SafeArea(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.only(
                            left: AppTheme.paddingL,
                            right: AppTheme.paddingL,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 16,
                          ),
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
                                controller: provider.usernameController,
                                labelText: 'Nom d\'utilisateur',
                                hintText: 'Entrez votre nom d\'utilisateur',
                                prefixIcon: Icons.person_outline,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: provider.descriptionController,
                                labelText: 'Description',
                                hintText: 'Entrez une description',
                                prefixIcon: Icons.description_outlined,
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
                              const SizedBox(height: 30),
                              PlanyButton(
                                text: 'Inscription',
                                onPressed: () => provider.signup(
                                  () => Navigator.pushReplacementNamed(
                                      context, '/login'),
                                  (errorMessage) =>
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                    SnackBar(content: Text(errorMessage)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildLoginLink(context, provider),
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
          'Inscription',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Créez un compte pour commencer',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(BuildContext context, SignupProvider provider) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Déjà un compte ? ',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          TextButton(
            onPressed: () => provider.navigateToLogin(context),
            child: Text(
              'Se connecter',
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
