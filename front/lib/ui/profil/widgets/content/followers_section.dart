import 'package:flutter/material.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/routing/routes.dart';
import 'package:front/ui/profil/view_models/profil_viewmodel.dart';
import 'package:front/ui/profil/widgets/common/section_header.dart';
import 'package:front/ui/profil/widgets/content/user_list.dart';

class FollowersSection extends StatefulWidget {
  final String userId;
  final ProfilViewModel viewModel;
  final Function()? onFollowChanged;

  const FollowersSection({
    super.key,
    required this.userId,
    required this.viewModel,
    this.onFollowChanged,
  });

  @override
  FollowersSectionState createState() => FollowersSectionState();
}

class FollowersSectionState extends State<FollowersSection> {
  late Future<List<User>> _followersFuture;
  Map<String, bool> followingStatus = {};
  bool _isLoading = false;
  Set<String> loadingUserIds = {};
  List<User> _followersList = [];

  @override
  void initState() {
    super.initState();
    _followersFuture = _loadFollowers();
  }

  Future<List<User>> _loadFollowers() async {
    setState(() => _isLoading = true);
    try {
      final followers = await widget.viewModel.getUserFollowers(widget.userId);

      setState(() {
        _followersList = followers;
      });

      for (var follower in followers) {
        final isFollowing = await widget.viewModel.isFollowing(follower.id);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildHeader(_followersList),
        ),
        FutureBuilder<List<User>>(
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
                          // Navigation vers le profil de l'utilisateur
                          Navigator.of(context)
                              .pushNamed(Routes.profil, arguments: follower.id);
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
                              success = await widget.viewModel
                                  .followUser(follower.id);
                            } else {
                              success = await widget.viewModel
                                  .unfollowUser(follower.id);
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
