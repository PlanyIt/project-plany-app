import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ui/profil/widgets/content/favorites_section.dart';
import '../../../ui/profil/widgets/content/followers_section.dart';
import '../../../ui/profil/widgets/content/following_section.dart';
import '../../../ui/profil/widgets/content/my_plans_section.dart';
import '../../../ui/profil/widgets/content/settings_section.dart';
import '../core/ui/bottom_bar/bottom_bar.dart';
import 'view_models/my_plan_viewmodel.dart';
import 'view_models/profile_viewmodel.dart';
import 'widgets/header/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final ProfileViewModel viewModel;

  const ProfileScreen({
    super.key,
    this.userId,
    required this.viewModel,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadUserData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3425B5)),
                ),
              ),
            );
          }

          if (vm.userProfile == null) {
            return _buildErrorView(context);
          }

          final body = SafeArea(
            child: SingleChildScrollView(
              controller: vm.scrollController,
              child: Column(
                children: [
                  ProfileHeader(
                    viewModel: vm,
                    onProfileUpdated: vm.refreshProfile,
                    onNavigationSelected: vm.selectSection,
                    isFollowing: vm.isFollowing,
                    loadingFollow: vm.loadingFollow,
                    onToggleFollow: vm.toggleFollow,
                    scrollController: vm.scrollController,
                  ),
                  _buildSection(vm),
                ],
              ),
            ),
          );

          return Scaffold(
            backgroundColor: Colors.white,
            body: body,
            bottomNavigationBar:
                vm.isCurrentUser ? const BottomBar(currentIndex: 2) : null,
          );
        },
      ),
    );
  }

  Widget _buildSection(ProfileViewModel vm) {
    final user = vm.userProfile!;

    switch (vm.selectedSection) {
      case 'plans':
        return ChangeNotifierProvider<MyPlansViewModel>.value(
          value: vm.myPlansViewModel,
          child: Consumer<MyPlansViewModel>(
            builder: (context, myPlansVm, _) {
              return MyPlansSection(viewModel: myPlansVm, profileViewModel: vm);
            },
          ),
        );
      case 'favorites':
        return FavoritesSection(viewModel: vm.favoritesViewModel);
      case 'subscriptions':
        return FollowingSection(
          viewModel: vm.userListViewModel!,
          onFollowChanged: vm.refreshProfile,
        );
      case 'followers':
        return FollowersSection(
          onFollowChanged: vm.refreshProfile,
          viewModel: vm.userListViewModel!,
        );
      case 'settings':
        return SettingsSection(
          viewModel: vm,
          onProfileUpdated: () => vm.loadUserData(user.id),
        );
      default:
        return ChangeNotifierProvider<MyPlansViewModel>.value(
          value: vm.myPlansViewModel,
          child: Consumer<MyPlansViewModel>(
            builder: (context, myPlansVm, _) {
              return MyPlansSection(viewModel: myPlansVm, profileViewModel: vm);
            },
          ),
        );
    }
  }

  Widget _buildErrorView(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFF0EEFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: const Color(0xFF3425B5).withValues(alpha: .7),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Erreur de chargement du profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.viewModel.loadUserData(widget.userId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3425B5),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
