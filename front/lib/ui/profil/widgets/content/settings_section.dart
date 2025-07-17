import 'package:flutter/material.dart';
import '../../view_models/profile_viewmodel.dart';
import '../common/section_header.dart';
import '../settings/account_settings.dart';
import '../settings/components/settings_card.dart';
import '../settings/general_settings.dart';
import '../settings/profile_settings.dart';

class SettingsSection extends StatelessWidget {
  final ProfileViewModel viewModel;
  final VoidCallback onProfileUpdated;

  const SettingsSection({
    super.key,
    required this.viewModel,
    required this.onProfileUpdated,
  });

  void _showInfoCard(BuildContext context, String title, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF3425B5),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showErrorCard(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = viewModel.userProfile;
    if (userProfile == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SectionHeader(
              title: "Réglages",
              subtitle: "Gérez votre profil et vos préférences",
              icon: Icons.settings,
              gradientColors: const [Color(0xFF3425B5), Color(0xFF5C49D6)],
            ),
          ),

          const SizedBox(height: 16),

          /// --- Section Profil
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SettingsCard(
              title: 'Profil',
              icon: Icons.person,
              children: [
                ProfileSettings(
                  viewModel: viewModel,
                  showInfoCard: (title, message) =>
                      _showInfoCard(context, title, message),
                  showErrorCard: (message) => _showErrorCard(context, message),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// --- Section Compte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SettingsCard(
              title: 'Compte',
              icon: Icons.account_circle,
              children: [
                AccountSettings(
                  viewModel: viewModel,
                  onProfileUpdated: onProfileUpdated,
                  showInfoCard: (title, message) =>
                      _showInfoCard(context, title, message),
                  showErrorCard: (message) => _showErrorCard(context, message),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// --- Section Général
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SettingsCard(
              title: 'Général',
              icon: Icons.settings,
              children: [
                GeneralSettings(
                  viewModel: viewModel,
                  userProfile: userProfile,
                  showInfoCard: (title, message) =>
                      _showInfoCard(context, title, message),
                  showErrorCard: (message) => _showErrorCard(context, message),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
