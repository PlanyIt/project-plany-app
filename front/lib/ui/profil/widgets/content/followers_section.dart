import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/navigation/routes.dart';
import 'package:front/ui/profil/widgets/common/section_header.dart';
import 'package:front/ui/profil/widgets/content/user_list.dart';
import 'package:front/providers/providers.dart';
import 'package:front/core/utils/result.dart';

// Providers pour l'état des followers
final followersProvider =
    StateProvider.family<List<User>, String>((ref, userId) => []);
final followersLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final followingStatusProvider = StateProvider<Map<String, bool>>((ref) => {});
final loadingUserIdsProvider = StateProvider<Set<String>>((ref) => {});

class FollowersSection extends ConsumerStatefulWidget {
  final String userId;
  final Function()? onFollowChanged;

  const FollowersSection({
    super.key,
    required this.userId,
    this.onFollowChanged,
  });
  @override
  ConsumerState<FollowersSection> createState() => FollowersSectionState();
}

class FollowersSectionState extends ConsumerState<FollowersSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFollowers();
    });
  }

  Future<void> _loadFollowers() async {
    ref.read(followersLoadingProvider(widget.userId).notifier).state = true;

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final followersResult =
          await userRepository.getUserFollowers(widget.userId);

      if (followersResult is Ok<List<User>>) {
        final followers = followersResult.value;
        ref.read(followersProvider(widget.userId).notifier).state =
            followers; // Charger le statut de suivi pour chaque follower
        Map<String, bool> status = {};
        for (var follower in followers) {
          try {
            // Obtenir l'ID de l'utilisateur actuel
            final currentUserResult = await userRepository.getCurrentUser();
            if (currentUserResult is Ok<User>) {
              final currentUserId = currentUserResult.value.id;
              final checkResult = await userRepository.checkFollowing(
                  currentUserId, follower.id);
              if (checkResult is Ok<Map<String, dynamic>>) {
                status[follower.id] = checkResult.value['isFollowing'] ?? false;
              }
            }
          } catch (e) {
            print(
                'Erreur lors de la vérification du suivi pour ${follower.id}: $e');
            status[follower.id] = false;
          }
        }

        if (mounted) {
          ref.read(followingStatusProvider.notifier).state = {
            ...ref.read(followingStatusProvider),
            ...status,
          };
        }
      } else {
        print(
            'Erreur lors du chargement des followers: ${followersResult.toString()}');
      }
    } catch (e) {
      print('Erreur lors du chargement des abonnés: $e');
    } finally {
      if (mounted) {
        ref.read(followersLoadingProvider(widget.userId).notifier).state =
            false;
      }
    }
  }

  Widget _buildHeader(List<User> followers) {
    return SectionHeader(
      title: "Abonnés",
      subtitle:
          "${followers.length} personne${followers.length > 1 ? 's' : ''} vous sui${followers.length > 1 ? 'vent' : 't'}",
      icon: Icons.people_outline_rounded,
      gradientColors: const [Colors.blue, Colors.blueAccent],
    );
  }

  @override
  Widget build(BuildContext context) {
    final followers = ref.watch(followersProvider(widget.userId));
    final isLoading = ref.watch(followersLoadingProvider(widget.userId));
    final followingStatus = ref.watch(followingStatusProvider);
    final loadingUserIds = ref.watch(loadingUserIdsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildHeader(followers),
        ),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (followers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun abonné pour le moment',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: followers.map((follower) {
                return UserListItem(
                  user: follower,
                  onTap: () {
                    // Navigation vers le profil de l'utilisateur
                    Navigator.of(context)
                        .pushNamed(Routes.profil, arguments: follower.id);
                  },
                  showFollowButton: true,
                  isFollowing: followingStatus[follower.id] ?? false,
                  isLoading: loadingUserIds.contains(follower.id),
                  onFollowChanged: (isFollowing) =>
                      _handleFollowChanged(follower, isFollowing),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _handleFollowChanged(User follower, bool isFollowing) async {
    try {
      final loadingUsers = ref.read(loadingUserIdsProvider);
      ref.read(loadingUserIdsProvider.notifier).state = {
        ...loadingUsers,
        follower.id
      };

      final userRepository = ref.read(userRepositoryProvider);
      final result = isFollowing
          ? await userRepository.followUser(follower.id)
          : await userRepository.unfollowUser(follower.id);

      if (result is Ok && mounted) {
        final currentStatus = ref.read(followingStatusProvider);
        ref.read(followingStatusProvider.notifier).state = {
          ...currentStatus,
          follower.id: isFollowing,
        };

        if (widget.onFollowChanged != null) {
          widget.onFollowChanged!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFollowing
                ? 'Vous suivez maintenant ${follower.username}'
                : 'Vous ne suivez plus ${follower.username}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'abonnement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        final loadingUsers = ref.read(loadingUserIdsProvider);
        ref.read(loadingUserIdsProvider.notifier).state =
            loadingUsers.where((id) => id != follower.id).toSet();
      }
    }
  }
}
