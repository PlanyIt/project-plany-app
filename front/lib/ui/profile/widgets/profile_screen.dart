import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../screens/profil/widgets/header/profile_header.dart';
import '../../../ui/core/ui/bottom_bar/bottom_bar.dart';
import '../../../ui/profile/widgets/profile_content.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    this.userId,
    this.isCurrentUser = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(
        userRepository: context.read(),
        authRepository: context.read(),
        planRepository: context.read(),
        userId: userId,
      ),
      child: const _ProfileScreenContent(),
    );
  }
}

class _ProfileScreenContent extends StatefulWidget {
  const _ProfileScreenContent();

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomBar(currentIndex: 2),
      body: SafeArea(
        child: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.load.running && !viewModel.hasLoadedData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.load.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur lors du chargement du profil',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.load.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.load.execute(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.userProfile == null) {
              return const Center(
                child: Text('Aucun profil trouvé'),
              );
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.refreshData.execute(),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    ProfileHeader(
                      viewModel: viewModel,
                      onNavigationSelected: _handleNavigation,
                      scrollController: _scrollController,
                    ),
                    ProfileContent(
                      viewModel: viewModel,
                      selectedSection: viewModel.selectedSection,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleNavigation(String section) {
    final viewModel = context.read<ProfileViewModel>();
    viewModel.setSelectedSection(section);

    // Scroll to content section with animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          420, // Adjust based on your header height
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}
