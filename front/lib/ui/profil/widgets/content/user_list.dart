import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../domain/models/user/user.dart';
import '../../../../domain/models/user/user_stats.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final UserStats? userStats;
  final VoidCallback onTap;
  final bool showFollowButton;
  final bool isFollowing;
  final bool isLoading;
  final Function(bool)? onFollowChanged;

  const UserListItem({
    super.key,
    required this.user,
    this.userStats,
    required this.onTap,
    this.showFollowButton = false,
    this.isFollowing = false,
    this.isLoading = false,
    this.onFollowChanged,
  });

  String _getUserLevelEmoji() {
    final plansCount = userStats?.plansCount ?? 0;
    if (plansCount >= 50) return "🏆";
    if (plansCount >= 20) return "⭐";
    if (plansCount >= 10) return "🎯";
    return "🌱";
  }

  Color _getUserLevelColor() {
    final plansCount = userStats?.plansCount ?? 0;
    if (plansCount >= 50) return Colors.amber;
    if (plansCount >= 20) return Colors.lightBlue;
    if (plansCount >= 10) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final avatar = user.photoUrl != null && user.photoUrl!.isNotEmpty
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.photoUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.person, color: Colors.grey[600]),
            ),
          )
        : Icon(Icons.person, size: 30, color: Colors.grey[600]);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: avatar,
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildUserInfo()),
            if (showFollowButton) _buildFollowButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final followersCount = userStats?.followersCount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.username,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isPremium == true)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.workspace_premium,
                    size: 12, color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getUserLevelColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getUserLevelEmoji(), style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                "$followersCount abonnés",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    final categoryColor = const Color(0xFF3425B5);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [categoryColor, categoryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onFollowChanged?.call(!isFollowing),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    isFollowing
                        ? Icons.person_remove
                        : Icons.person_add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
          ),
        ),
      ),
    );
  }
}
