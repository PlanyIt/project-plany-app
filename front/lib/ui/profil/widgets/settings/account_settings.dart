import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/helpers.dart';
import '../../../../utils/result.dart';
import '../../view_models/profile_viewmodel.dart';
import '../common/section_text_field.dart';
import '../content/premium_popup.dart';

class AccountSettings extends StatefulWidget {
  final Function onProfileUpdated;
  final Function(String, String) showInfoCard;
  final Function(String) showErrorCard;
  final ProfileViewModel viewModel;

  const AccountSettings({
    super.key,
    required this.onProfileUpdated,
    required this.showInfoCard,
    required this.showErrorCard,
    required this.viewModel,
  });

  @override
  AccountSettingsState createState() => AccountSettingsState();
}

class AccountSettingsState extends State<AccountSettings> {
  Future<void> _showEditEmailPopup() async {
    final user = widget.viewModel.userProfile;
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var obscurePassword = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Modifier votre email',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3425B5))),
                          IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SectionTextField(
                        title: 'Nouvelle adresse email',
                        controller: emailController,
                        labelText: 'Entrez votre nouvelle adresse email',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe actuel',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setStateDialog(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler')),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                final result = await widget.viewModel
                                    .updateEmail(emailController.text,
                                        passwordController.text);
                                if (result is Ok<void>) {
                                  widget.onProfileUpdated();
                                  widget.showInfoCard('Succès',
                                      'Votre adresse email a été modifiée.');
                                } else {
                                  widget.showErrorCard('Erreur: $result');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3425B5)),
                            child: const Text('Mettre à jour'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showChangePasswordPopup() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var obscureCurrent = true, obscureNew = true, obscureConfirm = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Changer mot de passe',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3425B5))),
                          IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe actuel',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(obscureCurrent
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setStateDialog(
                                () => obscureCurrent = !obscureCurrent),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Entrez le mot de passe actuel'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          hintText: 'Nouveau mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                setStateDialog(() => obscureNew = !obscureNew),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Entrez un nouveau mot de passe'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          hintText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setStateDialog(
                                () => obscureConfirm = !obscureConfirm),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirmez le mot de passe';
                          }
                          if (value != newPasswordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler')),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final result =
                                    await widget.viewModel.changePassword(
                                  currentPasswordController.text,
                                  newPasswordController.text,
                                );
                                if (context.mounted) {
                                  context.pop();
                                }
                                if (result is Ok<void>) {
                                  widget.showInfoCard('Succès',
                                      'Votre mot de passe a été changé.');
                                } else {
                                  widget.showErrorCard('Erreur: $result');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3425B5)),
                            child: const Text('Changer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showPremiumPopup() async {
    await PremiumPopup.show(
      context: context,
      viewModel: widget.viewModel,
      showInfoCard: widget.showInfoCard,
      showErrorCard: widget.showErrorCard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.viewModel.userProfile;

    return Column(
      children: [
        _buildInfoRow(
          title: 'Adresse email',
          value: user?.email ?? '',
          icon: Icons.email_outlined,
          onEdit: _showEditEmailPopup,
        ),
        _buildActionRow(
          title: 'Changer le mot de passe',
          icon: Icons.lock_outline,
          onTap: _showChangePasswordPopup,
        ),
        if (user?.createdAt != null)
          _buildInfoRow(
            title: 'Membre depuis',
            value: formatDate(user!.createdAt!),
            icon: Icons.calendar_today_outlined,
          ),
        _buildPremiumStatusRow(
          isPremium: user?.isPremium ?? false,
          onTap: _showPremiumPopup,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required IconData icon,
    bool multiline = false,
    VoidCallback? onEdit,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Color(0xFF3425B5)),
              onPressed: onEdit,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatusRow({
    required bool isPremium,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isPremium
              ? Colors.amber.withAlpha(25)
              : const Color(0xFF3425B5).withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPremium
                ? Colors.amber
                : const Color(0xFF3425B5).withAlpha(50),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.workspace_premium,
                size: 20,
                color: isPremium ? Colors.amber[700] : Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'Premium Actif' : 'Devenir Premium',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isPremium
                          ? Colors.amber[700]
                          : const Color(0xFF3425B5),
                    ),
                  ),
                  Text(
                    isPremium
                        ? 'Vous bénéficiez de toutes les fonctionnalités'
                        : 'Débloquez toutes les fonctionnalités',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPremium
                    ? Colors.amber.withAlpha(50)
                    : const Color(0xFF3425B5).withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPremium ? 'ACTIF' : 'UPGRADE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color:
                      isPremium ? Colors.amber[700] : const Color(0xFF3425B5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
