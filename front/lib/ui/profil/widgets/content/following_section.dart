import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/navigation/routes.dart';
import 'package:front/ui/profil/widgets/common/section_header.dart';
import 'package:front/ui/profil/widgets/content/user_list.dart';
import 'package:front/providers/providers.dart';
import 'package:front/core/utils/result.dart';

// Providers pour l'état des following
final followingProvider =
    StateProvider.family<List<User>, String>((ref, userId) => []);
final followingLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final followingStatusProvider = StateProvider<Map<String, bool>>((ref) => {});
final followingLoadingUserIdsProvider = StateProvider<Set<String>>((ref) => {});

class FollowingSection extends ConsumerStatefulWidget {
  final String userId;
  final Function()? onFollowChanged;

  const FollowingSection({
    super.key,
    required this.userId,
    this.onFollowChanged,
  });
  @override
  ConsumerState<FollowingSection> createState() => FollowingSectionState();
}

class FollowingSectionState extends ConsumerState<FollowingSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFollowing();
    });
  }

  Future<void> _loadFollowing() async {
    ref.read(followingLoadingProvider(widget.userId).notifier).state = true;

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final followingResult =
          await userRepository.getUserFollowing(widget.userId);

      if (followingResult is Ok<List<User>>) {
        final following = followingResult.value;
        ref.read(followingProvider(widget.userId).notifier).state = following;

        // Marquer tous les utilisateurs suivis comme "following"
        Map<String, bool> status = {};
        for (var user in following) {
          status[user.id] = true;
        }

        if (mounted) {
          ref.read(followingStatusProvider.notifier).state = {
            ...ref.read(followingStatusProvider),
            ...status,
          };
        }
      } else {
        print(
            'Erreur lors du chargement des abonnements: ${followingResult.toString()}');
      }
    } catch (e) {
      print('Erreur lors du chargement des abonnements: $e');
    } finally {
      if (mounted) {
        ref.read(followingLoadingProvider(widget.userId).notifier).state =
            false;
      }
    }
  }

  Future<void> _unfollowUser(User user) async {
    try {
      final loadingUsers = ref.read(followingLoadingUserIdsProvider);
      ref.read(followingLoadingUserIdsProvider.notifier).state = {
        ...loadingUsers,
        user.id
      };

      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.unfollowUser(user.id);

      if (result is Ok && mounted) {
        // Retirer l'utilisateur de la liste des suivis
        final currentFollowing = ref.read(followingProvider(widget.userId));
        ref.read(followingProvider(widget.userId).notifier).state =
            currentFollowing.where((u) => u.id != user.id).toList();

        // Mettre à jour le statut
        final currentStatus = ref.read(followingStatusProvider);
        ref.read(followingStatusProvider.notifier).state = {
          ...currentStatus,
          user.id: false,
        };

        // Notifier le parent pour mettre à jour les compteurs
        widget.onFollowChanged?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vous ne suivez plus ${user.username}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors du désabonnement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        final loadingUsers = ref.read(followingLoadingUserIdsProvider);
        ref.read(followingLoadingUserIdsProvider.notifier).state =
            loadingUsers.where((id) => id != user.id).toSet();
      }
    }
  }

  Widget _buildHeader(List<User> following) {
    return SectionHeader(
      title: "Abonnements",
      subtitle:
          "${following.length} utilisateur${following.length > 1 ? 's' : ''} suivi${following.length > 1 ? 's' : ''}",
      icon: Icons.people_rounded,
      gradientColors: const [Colors.green, Colors.greenAccent],
    );
  }

  @override
  Widget build(BuildContext context) {
    final following = ref.watch(followingProvider(widget.userId));
    final isLoading = ref.watch(followingLoadingProvider(widget.userId));
    final followingStatus = ref.watch(followingStatusProvider);
    final loadingUserIds = ref.watch(followingLoadingUserIdsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildHeader(following),
        ),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (following.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.groups_outlined,
                      size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun abonnement pour le moment',
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
              children: following.map((user) {
                return UserListItem(
                  user: user,
                  onTap: () {
                    // Navigation vers le profil de l'utilisateur
                    Navigator.of(context)
                        .pushNamed(Routes.profil, arguments: user.id);
                  },
                  showFollowButton: true,
                  isFollowing: followingStatus[user.id] ?? false,
                  isLoading: loadingUserIds.contains(user.id),
                  onFollowChanged: (isFollowing) {
                    if (!isFollowing) {
                      _unfollowUser(user);
                    }
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
