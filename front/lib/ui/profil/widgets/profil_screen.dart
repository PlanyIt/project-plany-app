import 'package:flutter/material.dart';
import 'package:front/ui/core/ui/bottom_bar/bottom_bar.dart';
import 'package:front/ui/profil/view_models/profil_viewmodel.dart';
import 'package:front/ui/profil/widgets/content/favorites_section.dart';
import 'package:front/ui/profil/widgets/content/followers_section.dart';
import 'package:front/ui/profil/widgets/content/following_section.dart'
    show FollowingSection;
import 'package:front/ui/profil/widgets/content/my_plans_section.dart';
import 'package:front/ui/profil/widgets/content/settings_section.dart';
import 'package:front/ui/profil/widgets/header/profile_header.dart';

class ProfilScreen extends StatefulWidget {
  final String? userId;
  final bool isCurrentUser;

  const ProfilScreen({
    super.key,
    this.userId,
    this.isCurrentUser = true,
    required this.viewModel,
  });

  final ProfilViewModel viewModel;

  @override
  ProfilScreenState createState() => ProfilScreenState();
}

class ProfilScreenState extends State<ProfilScreen> {
  String _selectedSection = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedSection = 'plans';

    widget.viewModel.load.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF3425B5)),
          ),
        ),
      );
    }

    if (widget.viewModel.user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 50,
                  color: const Color(0xFF3425B5).withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Erreur de chargement du profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.viewModel.load.execute,
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

    return Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 2),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              ProfileHeader(
                userProfile: widget.viewModel.user!,
                viewModel: widget.viewModel,
                onNavigationSelected: _handleNavigation,
                isCurrentUser: widget.isCurrentUser,
                scrollController: _scrollController,
              ),
              _getSelectedSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String section) {
    setState(() {
      _selectedSection = section;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          420,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _getSelectedSection() {
    switch (_selectedSection) {
      case 'plans':
        return MyPlansSection(
          userId: widget.viewModel.user!.id,
          viewModel: widget.viewModel,
        );
      case 'favorites':
        return widget.isCurrentUser
            ? FavoritesSection(
                userId: widget.viewModel.user!.id,
                viewModel: widget.viewModel,
              )
            : const Center(child: Text('Section non disponible'));
      case 'subscriptions':
        return widget.isCurrentUser
            ? FollowingSection(
                userId: widget.viewModel.user!.id,
                viewModel: widget.viewModel,
              )
            : const Center(child: Text('Section non disponible'));
      case 'followers':
        return FollowersSection(
          userId: widget.viewModel.user!.id,
          viewModel: widget.viewModel,
        );
      case 'settings':
        return widget.viewModel.user != null
            ? SettingsSection(
                userProfile: widget.viewModel.user!,
                viewModel: widget.viewModel,
                onProfileUpdated: widget.viewModel.load.execute,
              )
            : const Center(child: Text('Section non disponible'));
      default:
        return MyPlansSection(
          userId: widget.viewModel.user!.id,
          viewModel: widget.viewModel,
        );
    }
  }
}
