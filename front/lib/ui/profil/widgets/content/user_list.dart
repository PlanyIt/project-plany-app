import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
              errorWidget: (context, url, error) =>
                  Icon(Icons.person, color: Colors.grey[600]),
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
                    color: Colors.black.withValues(alpha: 0.1),
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
    final int followersCount = user.followersCount ??
        user.followers.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.username,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isPremium == true)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.verified, color: Colors.amber, size: 18),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.people, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '$followersCount abonné${followersCount > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
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
          colors: [categoryColor, categoryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.3),
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
