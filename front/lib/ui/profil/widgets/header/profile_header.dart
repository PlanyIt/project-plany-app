import 'package:flutter/material.dart';
import '../../view_models/profile_viewmodel.dart';
import 'components/profile_avatar.dart';
import 'components/profile_categories.dart';
import 'components/profile_stats.dart';
import 'components/profile_user_info.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;
  final Function(String) onUpdatePhoto;
  final Function onProfileUpdated;
  final Function(String) onNavigationSelected;
  final bool isFollowing;
  final bool loadingFollow;
  final VoidCallback? onToggleFollow;
  final ScrollController scrollController;

  const ProfileHeader({
    super.key,
    required this.viewModel,
    required this.onUpdatePhoto,
    required this.onProfileUpdated,
    required this.onNavigationSelected,
    required this.scrollController,
    this.isFollowing = false,
    this.loadingFollow = false,
    this.onToggleFollow,
  });

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon == Icons.arrow_back ? Icons.arrow_back_ios_rounded : icon,
          color: const Color(0xFF3425B5),
          size: 18,
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
        splashRadius: 24,
      ),
    );
  }

  void _handleNavigation(String section) {
    onNavigationSelected(section);
  }

  @override
  Widget build(BuildContext context) {
    final user = viewModel.userProfile!;
    final isCurrentUser = viewModel.isCurrentUser;
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isCurrentUser
                      ? const SizedBox()
                      : _buildGlassIconButton(
                          icon: Icons.arrow_back,
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context)
                                  .pushReplacementNamed('/dashboard');
                            }
                          },
                        ),
                  if (isCurrentUser)
                    Row(
                      children: [
                        _buildGlassIconButton(
                          icon: Icons.settings,
                          onPressed: () {
                            onNavigationSelected('settings');
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildGlassIconButton(
                          icon: Icons.notifications,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Notifications à venir prochainement'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(
                    isCurrentUser: isCurrentUser,
                    viewModel: viewModel,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ProfileUserInfo(
                      viewModel: viewModel,
                      isCurrentUser: isCurrentUser,
                      isFollowing: isFollowing,
                      loadingFollow: loadingFollow,
                      onFollowTap: onToggleFollow ?? () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.format_quote,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user.description?.isNotEmpty == true
                            ? user.description!
                            : "Bonjour ! Je suis ${user.username} et j'adore explorer de nouveaux endroits.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfileCategories(viewModel: viewModel),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfileStats(
                viewModel: viewModel,
                onNavigationSelected: _handleNavigation,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
