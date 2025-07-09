import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../../../core/localization/applocalization.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/ui/button/plany_button.dart';
import '../../../core/ui/form/custom_text_field.dart';
import '../../../core/ui/logo/plany_logo.dart';
import '../view_models/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.login.addListener(_onLoginResult);
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.login.removeListener(_onLoginResult);
    widget.viewModel.login.addListener(_onLoginResult);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    widget.viewModel.login.removeListener(_onLoginResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              left: AppTheme.paddingL,
              right: AppTheme.paddingL,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(child: PlanyLogo(fontSize: 50)),
                const SizedBox(height: 40),
                _buildWelcomeText(context),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 8),
                _buildForgotPassword(context),
                const SizedBox(height: 30),
                _buildLoginButton(context),
                const SizedBox(height: 20),
                _buildRegisterRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _email,
      labelText: 'Email',
      hintText: 'Entrez votre email',
      prefixIcon: Icons.email_outlined,
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      controller: _password,
      labelText: 'Mot de passe',
      hintText: 'Entrez votre mot de passe',
      prefixIcon: Icons.lock_outline,
      obscureText: widget.viewModel.obscurePassword,
      suffixIcon: widget.viewModel.obscurePassword
          ? Icons.visibility_off
          : Icons.visibility,
      onSuffixIconPressed: widget.viewModel.togglePasswordVisibility,
    );
  }

  Widget _buildForgotPassword(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => context.go(Routes.reset),
          child: Text(
            'Mot de passe oublié ?',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  Widget _buildLoginButton(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel.login,
      builder: (context, _) {
        return PlanyButton(
          text: AppLocalization.of(context).login,
          isLoading: widget.viewModel.login.running,
          onPressed: _handleLogin,
        );
      },
    );
  }

  Widget _buildRegisterRow(BuildContext context) => Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pas encore de compte ? ',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .7),
              ),
            ),
            TextButton(
              onPressed: () => context.go(Routes.register),
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

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context).login,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenue ! Veuillez vous connecter pour continuer',
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

  void _handleLogin() {
    widget.viewModel.clearError();
    widget.viewModel.login.execute(
      (_email.text, _password.text),
    );
  }

  void _onLoginResult() {
    if (widget.viewModel.login.completed) {
      widget.viewModel.login.clearResult();
      context.go(Routes.dashboard);
      return;
    }

    if (widget.viewModel.login.error) {
      widget.viewModel.login.clearResult();

      // Afficher l'erreur via SnackBar
      if (widget.viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: AppLocalization.of(context).tryAgain,
              textColor: Colors.white,
              onPressed: _handleLogin,
            ),
          ),
        );
      }
    }
  }
}
