import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes_new.dart';
import '../../../core/localization/applocalization.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/ui/button/plany_button.dart';
import '../../../core/ui/form/custom_text_field.dart';
import '../../../core/ui/logo/plany_logo.dart';
import '../view_models/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.viewModel});

  final RegisterViewModel viewModel;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.register.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant RegisterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.register.removeListener(_onResult);
    widget.viewModel.register.addListener(_onResult);
  }

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    widget.viewModel.register.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
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
              _buildLogo(),
              const SizedBox(height: 40),
              _buildWelcomeText(context),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _email,
                labelText: 'Email',
                hintText: 'Entrez votre email',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _username,
                labelText: 'Nom d\'utilisateur',
                hintText: 'Entrez votre nom d\'utilisateur',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _password,
                labelText: 'Mot de passe',
                hintText: 'Entrez votre mot de passe',
                prefixIcon: Icons.lock_outline,
                obscureText: obscurePassword,
                suffixIcon:
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                onSuffixIconPressed: togglePasswordVisibility,
              ),
              const SizedBox(height: 30),
              ListenableBuilder(
                  listenable: widget.viewModel.register,
                  builder: (context, _) {
                    return PlanyButton(
                      text: AppLocalization.of(context).register,
                      isLoading: widget.viewModel.register.running,
                      onPressed: () {
                        widget.viewModel.register.execute(
                          (
                            _email.value.text,
                            _username.value.text,
                            _password.value.text
                          ),
                        );
                      },
                    );
                  }),
              const SizedBox(height: 20),
              _buildLoginLink(context),
            ],
          ),
        ),
      ),
    );
  }

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void _onResult() {
    if (widget.viewModel.register.completed) {
      widget.viewModel.register.clearResult();
      context.go(Routes.dashboard);
    }

    if (widget.viewModel.register.error) {
      widget.viewModel.register.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.of(context).errorWhileRegister),
          action: SnackBarAction(
            label: AppLocalization.of(context).tryAgain,
            onPressed: () => widget.viewModel.register.execute((
              _email.value.text,
              _username.value.text,
              _password.value.text,
            )),
          ),
        ),
      );
    }
  }
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
        AppLocalization.of(context).register,
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

Widget _buildLoginLink(BuildContext context) {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        TextButton(
          onPressed: () => context.push(Routes.login),
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
