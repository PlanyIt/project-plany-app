import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../routing/routes.dart';
import '../../view_models/user_list_viewmodel.dart';
import '../common/section_header.dart';
import 'user_list.dart';

class FollowingSection extends StatelessWidget {
  final UserListViewModel viewModel;
  final VoidCallback? onFollowChanged;

  const FollowingSection({
    super.key,
    required this.viewModel,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel..loadFollowing(),
      child: Consumer<UserListViewModel>(
        builder: (context, vm, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SectionHeader(
                  title: "Abonnements",
                  subtitle:
                      "${vm.following.length} utilisateur${vm.following.length > 1 ? 's' : ''} suivi${vm.following.length > 1 ? 's' : ''}",
                  icon: Icons.people_rounded,
                  gradientColors: const [Colors.green, Colors.greenAccent],
                ),
              ),
              if (vm.isLoading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )),
              if (!vm.isLoading && vm.following.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.groups_outlined,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Aucun abonnement pour le moment',
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ),
              ...vm.following.map((user) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: UserListItem(
                    user: user,
                    onTap: () {
                      context.push('${Routes.profile}?userId=${user.id}');
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
              }),
            ],
          );
        },
      ),
    );
  }
}
