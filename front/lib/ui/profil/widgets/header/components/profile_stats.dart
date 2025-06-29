import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/domain/models/user/user.dart';

class ProfileStats extends StatelessWidget {
  final User userProfile;
  final bool isCurrentUser;
  final Function(String) onNavigationSelected;

  const ProfileStats({
    super.key,
    required this.userProfile,
    required this.isCurrentUser,
    required this.onNavigationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCurrentUser) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildEnhancedStatCard(
                  userProfile.plansCount?.toString() ?? '0',
                  'Plans créés',
                  Icons.map,
                  Colors.purple,
                  flex: 1,
                  isFirstInRow: true,
                  navigationKey: 'plans',
                ),
                _buildVerticalDivider(),
                _buildEnhancedStatCard(
                  userProfile.favoritesCount?.toString() ?? '0',
                  'Favoris',
                  Icons.favorite,
                  Colors.red[400] ?? Colors.red,
                  flex: 1,
                  isFirstInRow: false,
                  navigationKey: 'favorites',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                height: 1,
                color: Colors.grey[200],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildEnhancedStatCard(
                  userProfile.followingCount?.toString() ?? '0',
                  'Abonnements',
                  Icons.people,
                  Colors.green,
                  flex: 1,
                  isFirstInRow: true,
                  navigationKey: 'subscriptions',
                ),
                _buildVerticalDivider(),
                _buildEnhancedStatCard(
                  userProfile.followersCount?.toString() ?? '0',
                  'Abonnés',
                  Icons.person_add,
                  Colors.blue,
                  flex: 1,
                  isFirstInRow: false,
                  navigationKey: 'followers',
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildEnhancedStatCard(
                  userProfile.plansCount?.toString() ?? '0',
                  'Plans créés',
                  Icons.map,
                  Colors.purple,
                  flex: 1,
                  isFirstInRow: true,
                  navigationKey: 'plans',
                ),
                _buildVerticalDivider(),
                _buildEnhancedStatCard(
                  userProfile.followersCount?.toString() ?? '0',
                  'Abonnés',
                  Icons.person_add,
                  Colors.blue,
                  flex: 1,
                  isFirstInRow: false,
                  navigationKey: 'followers',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildEnhancedStatCard(
      String value, String label, IconData icon, Color color,
      {required int flex, required bool isFirstInRow, String? navigationKey}) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (navigationKey != null) {
            onNavigationSelected(navigationKey);
          }
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
                child: Icon(icon, color: color, size: 18),
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
}
