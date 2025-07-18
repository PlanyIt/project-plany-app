import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../view_models/profile_viewmodel.dart';

class ProfileStats extends StatelessWidget {
  final ProfileViewModel viewModel;
  final Function(String) onNavigationSelected;

  const ProfileStats({
    super.key,
    required this.viewModel,
    required this.onNavigationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final user = viewModel.userProfile;
    final isCurrentUser = user?.id == viewModel.authRepository.currentUser?.id;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
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
                  (viewModel.userStats?.plansCount ?? 0).toString(),
                  'Plans créés',
                  Icons.map,
                  Colors.purple,
                  'plans',
                ),
                _buildVerticalDivider(),
                _buildEnhancedStatCard(
                  (viewModel.userStats?.favoritesCount ?? 0).toString(),
                  'Favoris',
                  Icons.favorite,
                  Colors.red[400] ?? Colors.red,
                  'favorites',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(height: 1, color: Colors.grey[200]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildEnhancedStatCard(
                  (viewModel.userStats?.followingCount ?? 0).toString(),
                  'Abonnements',
                  Icons.people,
                  Colors.green,
                  'subscriptions',
                ),
                _buildVerticalDivider(),
                _buildEnhancedStatCard(
                  (viewModel.userStats?.followersCount ?? 0).toString(),
                  'Abonnés',
                  Icons.person_add,
                  Colors.blue,
                  'followers',
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildEnhancedStatCard(
                  (viewModel.userStats?.plansCount ?? 0).toString(),
                  'Plans créés',
                  Icons.map,
                  Colors.purple,
                  'plans',
                ),
                _buildVerticalDivider(),
                _buildEnhancedStatCard(
                  (viewModel.userStats?.followersCount ?? 0).toString(),
                  'Abonnés',
                  Icons.person_add,
                  Colors.blue,
                  'followers',
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
      color: Colors.grey.withValues(alpha: .2),
    );
  }

  Widget _buildEnhancedStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    String navigationKey,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onNavigationSelected(navigationKey);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
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
                          color: color.withValues(alpha: .7),
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
