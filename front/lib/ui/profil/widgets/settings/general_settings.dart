import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/user/user.dart';
import '../../../../routing/routes.dart';
import '../../view_models/profile_viewmodel.dart';

class GeneralSettings extends StatefulWidget {
  final User userProfile;
  final Function(String, String) showInfoCard;
  final Function(String) showErrorCard;
  final ProfileViewModel viewModel;

  const GeneralSettings({
    super.key,
    required this.userProfile,
    required this.showInfoCard,
    required this.showErrorCard,
    required this.viewModel,
  });

  @override
  GeneralSettingsState createState() => GeneralSettingsState();
}

class GeneralSettingsState extends State<GeneralSettings> {
  void _showPrivacyPolicy() {
    widget.showInfoCard(
      'Politique de confidentialité',
      """
Plany attache une grande importance à la protection de vos données personnelles et s'engage à respecter la réglementation en vigueur, notamment le Règlement Général sur la Protection des Données (RGPD).

1. **Collecte des données** :
Nous collectons uniquement les données nécessaires au fonctionnement de l'application (identité, email, préférences, etc.).

2. **Utilisation des données** :
Vos données sont utilisées exclusivement pour vous fournir les services de Plany (gestion de compte, personnalisation, sécurité, etc.). Elles ne sont jamais revendues à des tiers.

3. **Conservation** :
Les données sont conservées pendant la durée d'utilisation de votre compte et supprimées à la demande ou lors de la suppression du compte.

4. **Droits des utilisateurs** :
Vous disposez d'un droit d'accès, de rectification, de suppression, de portabilité et d'opposition concernant vos données. Pour exercer vos droits, contactez-nous à contact@plany.fr.

5. **Sécurité** :
Nous mettons en œuvre toutes les mesures nécessaires pour garantir la sécurité de vos données.

6. **Contact** :
Pour toute question relative à la protection de vos données, écrivez-nous à contact@plany.fr.

Pour plus d'informations, consultez les mentions légales et la section RGPD.
""",
    );
  }

  void _showLegalNotice() {
    widget.showInfoCard(
      'Mentions légales',
      """
Éditeur : Plany SAS\nAdresse : 123 rue de la Liberté, 75000 Paris\nSIRET : 123 456 789 00012\nDirecteur de la publication : Jean Dupont\nContact : contact@plany.fr\nHébergeur : OVH, 2 rue Kellermann, 59100 Roubaix\n""",
    );
  }

  void _showRGPDInfo() {
    widget.showInfoCard(
      'Données personnelles (RGPD)',
      """
Conformément au Règlement Général sur la Protection des Données (RGPD), vous disposez d'un droit d'accès, de rectification, de suppression et de portabilité de vos données.\n\nPour exercer vos droits, contactez-nous à contact@plany.fr.\n\nPour plus d'informations, consultez la politique de confidentialité.
""",
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFF3425B5)),
            SizedBox(width: 10),
            Text('Se déconnecter'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3425B5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => context.pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _logout();
    }
  }

  Future<void> _logout() async {
    try {
      await widget.viewModel.logout();
      if (!mounted) return;
      context.go(Routes.login);
    } catch (e) {
      widget.showErrorCard('Erreur lors de la déconnexion: $e');
    }
  }

  Future<void> _showDeleteAccountConfirmation() async {
    widget.showInfoCard('Développement en cours',
        'La suppression de compte sera disponible prochainement.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActionRow(
          title: 'Politique de confidentialité',
          icon: Icons.privacy_tip_outlined,
          onTap: _showPrivacyPolicy,
        ),
        _buildActionRow(
          title: 'Mentions légales',
          icon: Icons.gavel_outlined,
          onTap: _showLegalNotice,
        ),
        _buildActionRow(
          title: 'Données personnelles (RGPD)',
          icon: Icons.verified_user_outlined,
          onTap: _showRGPDInfo,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withAlpha(80),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _showLogoutConfirmation,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextButton(
            onPressed: _showDeleteAccountConfirmation,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer mon compte'),
          ),
        ),
      ],
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
}
