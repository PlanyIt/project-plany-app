import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile_screen.dart';
import '../../view_models/followers_viewmodel.dart';
import '../common/section_header.dart';
import 'user_list.dart';

class FollowersSection extends StatelessWidget {
  final FollowersViewModel viewModel;
  final VoidCallback? onFollowChanged;

  const FollowersSection({
    super.key,
    required this.viewModel,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel..loadFollowers(),
      child: Consumer<FollowersViewModel>(
        builder: (context, vm, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SectionHeader(
                  title: "Abonnés",
                  subtitle:
                      "${vm.followers.length} personne${vm.followers.length > 1 ? 's' : ''} vous sui${vm.followers.length > 1 ? 'vent' : 't'}",
                  icon: Icons.people_outline_rounded,
                  gradientColors: const [Colors.blue, Colors.blueAccent],
                ),
              ),
              if (vm.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!vm.isLoading && vm.followers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.person_off,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Aucun abonné pour le moment',
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ),
              ...vm.followers.map((user) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: UserListItem(
                    user: user,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            userId: user.id,
                            isCurrentUser: false,
                            viewModel: Provider.of(context, listen: false),
                          ),
                        ),
                      );
                    },
                    showFollowButton: true,
                    isFollowing: vm.followingStatus[user.id] ?? false,
                    isLoading: vm.loadingIds.contains(user.id),
                    onFollowChanged: (isFollowing) {
                      vm.toggleFollow(user);
                      onFollowChanged?.call();
                    },
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
