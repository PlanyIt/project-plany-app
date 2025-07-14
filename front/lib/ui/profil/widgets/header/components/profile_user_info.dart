import 'package:flutter/material.dart';
import '../../../view_models/profile_viewmodel.dart';
import '../../content/premium_popup.dart';

class ProfileUserInfo extends StatelessWidget {
  final ProfileViewModel viewModel;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool loadingFollow;
  final VoidCallback onFollowTap;

  const ProfileUserInfo({
    super.key,
    required this.viewModel,
    required this.isCurrentUser,
    required this.isFollowing,
    required this.loadingFollow,
    required this.onFollowTap,
  });

  String _getUserLevelEmoji() {
    final plansCount = viewModel.userStats?.plansCount ?? 0;
    if (plansCount >= 50) return "🏆";
    if (plansCount >= 20) return "⭐";
    if (plansCount >= 10) return "🎯";
    return "🌱";
  }

  Color _getUserLevelColor() {
    final plansCount = viewModel.userStats?.plansCount ?? 0;
    if (plansCount >= 50) return Colors.amber;
    if (plansCount >= 20) return Colors.lightBlue;
    if (plansCount >= 10) return Colors.orange;
    return Colors.green;
  }

  String _getUserLevelName() {
    final plansCount = viewModel.userStats?.plansCount ?? 0;
    if (plansCount >= 50) return "Expert";
    if (plansCount >= 20) return "Avancé";
    if (plansCount >= 10) return "Intermédiaire";
    return "Débutant";
  }

  Future<void> _showCancelPremiumDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver Premium'),
        content: const Text(
            'Êtes-vous sûr de vouloir désactiver votre abonnement Premium ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await viewModel.updateProfile(
        username: viewModel.userProfile!.username,
        description: viewModel.userProfile!.description,
        birthDate: viewModel.userProfile!.birthDate,
        gender: viewModel.userProfile!.gender,
        isPremium: false,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre abonnement Premium a été désactivé.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showPremiumPopup(BuildContext context) async {
    await PremiumPopup.show(
      context: context,
      viewModel: viewModel,
      showInfoCard: (title, message) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
            backgroundColor: const Color(0xFF3425B5),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      },
      showErrorCard: (message) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = viewModel.userProfile!;
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
                    color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        Text(
          userProfile.email,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                  Text(_getUserLevelEmoji(),
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(
                    _getUserLevelName(),
                    style: TextStyle(
                        color: _getUserLevelColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isCurrentUser)
              Expanded(
                child: InkWell(
                  onTap: () async {
                    if (userProfile.isPremium) {
                      await _showCancelPremiumDialog(context);
                    } else {
                      await _showPremiumPopup(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: userProfile.isPremium
                          ? const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.grey, Colors.grey.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          userProfile.isPremium
                              ? Icons.workspace_premium
                              : Icons.diamond_outlined,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            userProfile.isPremium
                                ? 'Premium Actif'
                                : 'Devenir Premium',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (!isCurrentUser)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                            child: const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isFollowing ? Icons.check : Icons.add,
                                  size: 16,
                                  color: isFollowing
                                      ? Colors.grey[700]
                                      : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isFollowing ? 'Abonné' : 'S\'abonner',
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
