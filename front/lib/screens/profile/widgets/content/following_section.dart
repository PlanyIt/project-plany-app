import 'package:flutter/material.dart';
import 'package:front/domain/models/user_profile.dart';
import 'package:front/screens/profile/profile_screen.dart';
import 'package:front/screens/profile/widgets/common/section_header.dart';
import 'package:front/screens/profile/widgets/content/user_list.dart';
import 'package:front/services/user_service.dart';

class FollowingSection extends StatefulWidget {
  final String userId;
  final Function()? onFollowChanged;

  const FollowingSection(
      {super.key, required this.userId, this.onFollowChanged});

  @override
  _FollowingSectionState createState() => _FollowingSectionState();
}

class _FollowingSectionState extends State<FollowingSection> {
  final UserService _userService = UserService();
  late Future<List<UserProfile>> _followingFuture;
  Map<String, bool> followingStatus = {};
  bool _isLoading = false;
  List<UserProfile> _followingList = [];
  Set<String> loadingUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadFollowingData();
  }

  Future<void> _loadFollowingData() async {
    setState(() {
      _followingFuture = _loadFollowing();
    });
  }

  Future<List<UserProfile>> _loadFollowing() async {
    setState(() => _isLoading = true);
    try {
      final following = await _userService.getUserFollowing(widget.userId);
      setState(() {
        _followingList = following;
        for (var user in following) {
          followingStatus[user.id] = true;
        }
      });
      return following;
    } catch (e) {
      print('Erreur lors du chargement des abonnements: $e');
      return [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _unfollowUser(UserProfile user) async {
    try {
      setState(() {
        loadingUserIds.add(user.id);
      });

      final success = await _userService.unfollowUser(user.id);
      if (success && mounted) {
        setState(() {
          _followingList.removeWhere((u) => u.id == user.id);
          followingStatus[user.id] = false;
        });

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
    } finally {
      if (mounted) {
        setState(() {
          loadingUserIds.remove(user.id);
        });
      }
    }
  }

  Widget _buildHeader(List<UserProfile> following) {
    return SectionHeader(
      title: "Abonnements",
      subtitle: "${following.length} utilisateur${following.length > 1 ? 's' : ''} suivi${following.length > 1 ? 's' : ''}",
      icon: Icons.people_rounded,
      gradientColors: const [Colors.green, Colors.greenAccent],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildHeader(_followingList),
        ),
        FutureBuilder<List<UserProfile>>(
          future: _followingFuture,
          builder: (context, snapshot) {
            if (_isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }
            if (_followingList.isEmpty) {
              return Center(
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
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _followingList.map((user) {
                  return UserListItem(
                    user: user,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            userId: user.id,
                            isCurrentUser: false,
                          ),
                        ),
                      );
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
            );
          },
        ),
      ],
    );
  }
}
