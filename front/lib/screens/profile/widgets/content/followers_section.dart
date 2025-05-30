import 'package:flutter/material.dart';
import 'package:front/models/user_profile.dart';
import 'package:front/screens/profile/profile_screen.dart';
import 'package:front/screens/profile/widgets/common/section_header.dart';
import 'package:front/screens/profile/widgets/content/user_list.dart';
import 'package:front/services/user_service.dart';

class FollowersSection extends StatefulWidget {
  final String userId;
  final Function()? onFollowChanged;

  const FollowersSection({
    super.key,
    required this.userId,
    this.onFollowChanged,
  });

  @override
  _FollowersSectionState createState() => _FollowersSectionState();
}

class _FollowersSectionState extends State<FollowersSection> {
  final UserService _userService = UserService();
  late Future<List<UserProfile>> _followersFuture;
  Map<String, bool> followingStatus = {};
  bool _isLoading = false;
  Set<String> loadingUserIds = {};
  List<UserProfile> _followersList = [];

  @override
  void initState() {
    super.initState();
    _followersFuture = _loadFollowers();
  }

  Future<List<UserProfile>> _loadFollowers() async {
    setState(() => _isLoading = true);
    try {
      final followers = await _userService.getUserFollowers(widget.userId);

      setState(() {
        _followersList = followers;
      });

      for (var follower in followers) {
        final isFollowing = await _userService.isFollowing(follower.id);
        if (mounted) {
          setState(() {
            followingStatus[follower.id] = isFollowing;
          });
        }
      }

      return followers;
    } catch (e) {
      print('Erreur lors du chargement des abonnés: $e');
      return [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildHeader(List<UserProfile> followers) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildHeader(_followersList),
        ),
        FutureBuilder<List<UserProfile>>(
          future: _followersFuture,
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur lors du chargement des abonnés',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _followersFuture = _loadFollowers();
                          });
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final followers = snapshot.data ?? [];
            if (followers.isEmpty) {
              return Center(
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
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: followers.map((follower) {
                  return Column(
                    children: [
                      UserListItem(
                        user: follower,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                userId: follower.id,
                                isCurrentUser: false,
                              ),
                            ),
                          );
                        },
                        showFollowButton: true,
                        isFollowing: followingStatus[follower.id] ?? false,
                        isLoading: loadingUserIds.contains(follower.id),
                        onFollowChanged: (isFollowing) async {
                          try {
                            setState(() {
                              loadingUserIds.add(follower.id);
                            });

                            bool success;
                            if (isFollowing) {
                              success =
                                  await _userService.followUser(follower.id);
                            } else {
                              success =
                                  await _userService.unfollowUser(follower.id);
                            }

                            if (success && mounted) {
                              setState(() {
                                followingStatus[follower.id] = isFollowing;
                              });
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
                            print(
                                'Erreur lors de la mise à jour de l\'abonnement: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                loadingUserIds.remove(follower.id);
                              });
                            }
                          }
                        },
                      ),
                    ],
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
