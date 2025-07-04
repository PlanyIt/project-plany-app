import 'package:flutter/material.dart';

import '../../../screens/profil/widgets/content/followers_section.dart';
import '../../../screens/profil/widgets/content/following_section.dart';
import '../../../screens/profil/widgets/content/settings_section.dart';
import '../view_models/profile_view_model.dart';
import 'content/my_plans_section.dart';

class ProfileContent extends StatelessWidget {
  final ProfileViewModel viewModel;
  final String selectedSection;

  const ProfileContent({
    super.key,
    required this.viewModel,
    required this.selectedSection,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildSelectedSection(),
    );
  }

  Widget _buildSelectedSection() {
    switch (selectedSection) {
      case 'plans':
        return MyPlansSection(
          key: const ValueKey('plans'),
          viewModel: viewModel,
        );
      case 'followers':
        return FollowersSection(
          key: const ValueKey('followers'),
          viewModel: viewModel,
        );
      case 'subscriptions':
        return FollowingSection(
          key: const ValueKey('following'),
          viewModel: viewModel,
        );
      case 'settings':
        if (viewModel.isCurrentUser) {
          return SettingsSection(
            key: const ValueKey('settings'),
            viewModel: viewModel,
          );
        } else {
          return const _NotAvailableSection();
        }
      default:
        return MyPlansSection(
          key: const ValueKey('plans'),
          viewModel: viewModel,
        );
    }
  }
}

class _NotAvailableSection extends StatelessWidget {
  const _NotAvailableSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Section non disponible',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette section n\'est accessible que pour votre propre profil.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
