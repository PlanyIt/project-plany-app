import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../view_models/profile_view_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;
  final Function(String) onNavigationSelected;
  final ScrollController scrollController;

  const ProfileHeader({
    super.key,
    required this.viewModel,
    required this.onNavigationSelected,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final user = viewModel.userProfile!;
    final primaryColor = const Color(0xFF3425B5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (viewModel.isCurrentUser)
                    Row(
                      children: [
                        _buildGlassIconButton(
                          icon: Icons.settings,
                          onPressed: () => onNavigationSelected('settings'),
                        ),
                        const SizedBox(width: 8),
                        _buildGlassIconButton(
                          icon: Icons.notifications_outlined,
                          onPressed: () {
                            // Navigate to notifications
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and basic info
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundImage: user.profilePicture != null
                              ? NetworkImage(user.profilePicture!)
                              : null,
                          child: user.profilePicture == null
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey[400],
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Follow button (only for other users)
                            if (!viewModel.isCurrentUser)
                              SizedBox(
                                height: 36,
                                child: ElevatedButton.icon(
                                  onPressed: viewModel.followUser.running ||
                                          viewModel.unfollowUser.running
                                      ? null
                                      : () {
                                          if (viewModel.isFollowing) {
                                            viewModel.unfollowUser.execute();
                                          } else {
                                            viewModel.followUser.execute();
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: viewModel.isFollowing
                                        ? Colors.grey[300]
                                        : primaryColor,
                                    foregroundColor: viewModel.isFollowing
                                        ? Colors.grey[700]
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  icon: Icon(
                                    viewModel.isFollowing
                                        ? Icons.person_remove
                                        : Icons.person_add,
                                    size: 18,
                                  ),
                                  label: Text(
                                    viewModel.isFollowing
                                        ? 'Ne plus suivre'
                                        : 'Suivre',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _buildStat(
                        value: viewModel.plansCount.toString(),
                        label: 'Plans',
                        color: primaryColor,
                        onTap: () => onNavigationSelected('plans'),
                      ),
                      _buildStat(
                        value: viewModel.followersCount.toString(),
                        label: 'Abonnés',
                        color: Colors.orange,
                        onTap: () => onNavigationSelected('followers'),
                        flex: 2,
                      ),
                      _buildStat(
                        value: viewModel.followingCount.toString(),
                        label: 'Abonnements',
                        color: Colors.green,
                        onTap: () => onNavigationSelected('subscriptions'),
                        flex: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3425B5),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForLabel(label),
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[850],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: color.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'plans':
        return Icons.map_outlined;
      case 'abonnés':
        return Icons.people_outline;
      case 'abonnements':
        return Icons.person_add_outlined;
      default:
        return Icons.star_outline;
    }
  }
}
