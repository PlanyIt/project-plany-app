import 'package:flutter/material.dart';
import 'package:front/domain/models/user.dart';
import 'package:front/ui/profil/widgets/header/components/profile_user_info.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/services/user_service.dart';
import 'package:front/ui/profil/widgets/content/premium_popup.dart';
import 'components/profile_avatar.dart';
import 'components/profile_stats.dart';
import 'components/profile_categories.dart';

class ProfileHeader extends StatefulWidget {
  final User userProfile;
  final Function onProfileUpdated;
  final Function(String) onUpdatePhoto;
  final Function(String) onNavigationSelected;
  final bool isCurrentUser;
  final Function()? onFollowChanged;
  final ScrollController scrollController;

  const ProfileHeader({
    super.key,
    required this.userProfile,
    required this.onUpdatePhoto,
    required this.onProfileUpdated,
    required this.onNavigationSelected,
    required this.isCurrentUser,
    this.onFollowChanged,
    required this.scrollController,
  });

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  bool _isFollowing = false;
  bool _loadingFollow = false;

  @override
  void initState() {
    super.initState();

    if (!widget.isCurrentUser) {
      _checkFollowStatus();
    }
  }

  Future<void> _checkFollowStatus() async {
    if (!widget.isCurrentUser) {
      try {
        _isFollowing = await _userService.isFollowing(widget.userProfile.id);
        setState(() {});
      } catch (e) {
        print('Erreur lors de la vérification du statut de suivi: $e');
      }
    }
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

  void _showPremiumPopup() {
    PremiumPopup.show(
      context: context,
      userProfile: widget.userProfile,
      onProfileUpdated: widget.onProfileUpdated,
      showInfoCard: _showInfoCard,
      showErrorCard: _showErrorCard,
    );
  }

  Future<void> _toggleFollow() async {
    if (_loadingFollow) return;

    setState(() {
      _loadingFollow = true;
    });

    try {
      bool success;
      if (_isFollowing) {
        success = await _userService.unfollowUser(widget.userProfile.id);
        if (success) {
          _showInfoCard('Désabonnement',
              'Vous ne suivez plus ${widget.userProfile.username}');
        }
      } else {
        success = await _userService.followUser(widget.userProfile.id);
        if (success) {
          _showInfoCard('Abonnement',
              'Vous suivez maintenant ${widget.userProfile.username}');
        }
      }

      if (success) {
        await _checkFollowStatus();
        widget.onProfileUpdated();
        widget.onFollowChanged?.call();
      }
    } catch (e) {
      _showErrorCard('Erreur: $e');
    } finally {
      setState(() {
        _loadingFollow = false;
      });
    }
  }

  void _handleNavigation(String section) {
    setState(() {});
    widget.onNavigationSelected(section);
  }

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
            color: Colors.black.withValues(alpha: 0.1),
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

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassIconButton(
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
                  if (widget.isCurrentUser)
                    Row(
                      children: [
                        _buildGlassIconButton(
                          icon: Icons.settings,
                          onPressed: () {
                            widget.onNavigationSelected('settings');
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

            // Section de profil
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(
                    userProfile: widget.userProfile,
                    onUpdatePhoto: widget.onUpdatePhoto,
                    onProfileUpdated: widget.onProfileUpdated,
                    isCurrentUser: widget.isCurrentUser,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ProfileUserInfo(
                      userProfile: widget.userProfile,
                      isCurrentUser: widget.isCurrentUser,
                      isFollowing: _isFollowing,
                      loadingFollow: _loadingFollow,
                      onPremiumTap: _showPremiumPopup,
                      onFollowTap: _toggleFollow,
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
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userProfile.description?.isNotEmpty == true
                                ? widget.userProfile.description!
                                : "Bonjour ! Je suis ${widget.userProfile.username} et j'adore explorer de nouveaux endroits.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfileCategories(userId: widget.userProfile.id),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfileStats(
                userProfile: widget.userProfile,
                isCurrentUser: widget.isCurrentUser,
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
