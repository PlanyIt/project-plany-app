import 'package:flutter/material.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/ui/profil/view_models/profil_viewmodel.dart';
import 'package:front/ui/profil/widgets/common/section_header.dart';
import 'package:front/ui/profil/widgets/settings/account_settings.dart';
import 'package:front/ui/profil/widgets/settings/components/settings_card.dart';
import 'package:front/ui/profil/widgets/settings/general_settings.dart';
import 'package:front/ui/profil/widgets/settings/profile_settings.dart';

class SettingsSection extends StatefulWidget {
  final User userProfile;
  final ProfilViewModel viewModel;
  final Function onProfileUpdated;

  const SettingsSection({
    super.key,
    required this.userProfile,
    required this.viewModel,
    required this.onProfileUpdated,
  });

  @override
  SettingsSectionState createState() => SettingsSectionState();
}

class SettingsSectionState extends State<SettingsSection> {
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _showInfoCard(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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

  void _showErrorCard(String message) {
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
    return Stack(
      children: [
        SingleChildScrollView(
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

              // Section Profil
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SettingsCard(
                  title: 'Profil',
                  icon: Icons.person,
                  children: [
                    ProfileSettings(
                      initialUserProfile: widget.userProfile,
                      viewModel: widget.viewModel,
                      onProfileUpdated: widget.onProfileUpdated,
                      showInfoCard: _showInfoCard,
                      showErrorCard: _showErrorCard,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section Compte
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SettingsCard(
                  title: 'Compte',
                  icon: Icons.account_circle,
                  children: [
                    AccountSettings(
                      userProfile: widget.userProfile,
                      viewModel: widget.viewModel,
                      onProfileUpdated: widget.onProfileUpdated,
                      showInfoCard: _showInfoCard,
                      showErrorCard: _showErrorCard,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section Général
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SettingsCard(
                  title: 'Général',
                  icon: Icons.settings,
                  children: [
                    GeneralSettings(
                      userProfile: widget.userProfile,
                      viewModel: widget.viewModel,
                      showInfoCard: _showInfoCard,
                      showErrorCard: _showErrorCard,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),

        // Indicateur de chargement
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3425B5)),
              ),
            ),
          ),
      ],
    );
  }
}
