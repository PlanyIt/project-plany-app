import 'package:flutter/material.dart';
import 'package:front/models/user_profile.dart';

class ProfileUserInfo extends StatelessWidget {
  final UserProfile userProfile;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool loadingFollow;
  final VoidCallback onPremiumTap;
  final VoidCallback onFollowTap;

  const ProfileUserInfo({
    Key? key,
    required this.userProfile,
    required this.isCurrentUser,
    required this.isFollowing,
    required this.loadingFollow,
    required this.onPremiumTap,
    required this.onFollowTap,
  }) : super(key: key);

//TODO: A Gérer par le backend
  String _getUserLevelEmoji() {
    final plansCount = userProfile.plansCount ?? 0;
    if (plansCount >= 50) return "🏆";
    if (plansCount >= 20) return "⭐";
    if (plansCount >= 10) return "🎯";
    return "🌱";
  }

  Color _getUserLevelColor() {
    final plansCount = userProfile.plansCount ?? 0;
    if (plansCount >= 50) return Colors.amber;
    if (plansCount >= 20) return Colors.lightBlue;
    if (plansCount >= 10) return Colors.orange;
    return Colors.green;
  }

  String _getUserLevelName() {
    final plansCount = userProfile.plansCount ?? 0;
    if (plansCount >= 50) return "Expert";
    if (plansCount >= 20) return "Avancé";
    if (plansCount >= 10) return "Intermédiaire";
    return "Débutant";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                userProfile.username,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),

        Text(
          userProfile.email,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _getUserLevelColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getUserLevelEmoji(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _getUserLevelName(),
                    style: TextStyle(
                      color: _getUserLevelColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            isCurrentUser
                ? Expanded(
                    child: GestureDetector(
                      onTap: onPremiumTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          gradient: (userProfile.isPremium)
                              ? const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (userProfile.isPremium)
                                  ? Colors.amber.withOpacity(0.4)
                                  : Colors.grey.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                (userProfile.isPremium)
                                    ? Icons.workspace_premium
                                    : Icons.diamond_outlined,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                (userProfile.isPremium)
                                    ? 'Premium Actif'
                                    : 'Devenir Premium',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : userProfile.isPremium == true
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
          ],
        ),
        
        if (!isCurrentUser)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isFollowing) BoxShadow(
                    color: const Color(0xFF3425B5).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: loadingFollow ? null : onFollowTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: isFollowing 
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF3425B5), Color(0xFF5B4CDA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                      border: isFollowing 
                        ? Border.all(color: Colors.grey[400]!, width: 1)
                        : null,
                      color: isFollowing ? Colors.white : null,
                    ),
                    child: loadingFollow
                      ? Container(
                          width: 120,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFollowing ? const Color(0xFF3425B5) : Colors.white),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isFollowing 
                                  ? Icons.check
                                  : Icons.add,
                                size: 16,
                                color: isFollowing 
                                  ? Colors.grey[700]
                                  : Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isFollowing 
                                  ? 'Abonné'
                                  : 'S\'abonner',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: isFollowing 
                                    ? Colors.grey[700]
                                    : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}