import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/ui/core/ui/bottom_bar/bottom_bar.dart';
import 'package:front/ui/profil/widgets/content/favorites_section.dart';
import 'package:front/ui/profil/widgets/content/followers_section.dart';
import 'package:front/ui/profil/widgets/content/following_section.dart'
    show FollowingSection;
import 'package:front/ui/profil/widgets/content/my_plans_section.dart';
import 'package:front/ui/profil/widgets/content/settings_section.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/providers/providers.dart';
import 'package:front/ui/profil/widgets/header/profil_header.dart';
import 'package:front/utils/result.dart';

// Providers pour l'état du profil
final profilUserProvider =
    StateProvider.family<User?, String>((ref, userId) => null);
final profilLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final profilSelectedSectionProvider = StateProvider<String>((ref) => 'plans');

class ProfilScreen extends ConsumerStatefulWidget {
  final String? userId;
  final bool isCurrentUser;

  const ProfilScreen({
    super.key,
    this.userId,
    this.isCurrentUser = true,
  });
  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  final ScrollController _scrollController = ScrollController();
  late String _targetUserId;

  @override
  void initState() {
    super.initState();
    _targetUserId = widget.userId ?? 'current_user';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    ref.read(profilLoadingProvider(_targetUserId).notifier).state = true;

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final userResult = widget.isCurrentUser
          ? await userRepository.getCurrentUser()
          : await userRepository.getUserProfile(_targetUserId);

      if (userResult is Ok<User>) {
        ref.read(profilUserProvider(_targetUserId).notifier).state =
            userResult.value;
      } else {
        print('Erreur lors du chargement du profil utilisateur');
      }
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
    } finally {
      ref.read(profilLoadingProvider(_targetUserId).notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profilUserProvider(_targetUserId));
    final isLoading = ref.watch(profilLoadingProvider(_targetUserId));
    final selectedSection = ref.watch(profilSelectedSectionProvider);

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF3425B5)),
          ),
        ),
      );
    }

    if (user == null) {
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
                onPressed: _loadUserProfile,
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
      bottomNavigationBar:
          widget.isCurrentUser ? const BottomBar(currentIndex: 2) : null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              ProfilHeader(
                userProfile: user,
                onNavigationSelected: _handleNavigation,
                isCurrentUser: widget.isCurrentUser,
                scrollController: _scrollController,
              ),
              _getSelectedSection(user, selectedSection),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String section) {
    ref.read(profilSelectedSectionProvider.notifier).state = section;

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

  Widget _getSelectedSection(User user, String selectedSection) {
    switch (selectedSection) {
      case 'plans':
        return MyPlansSection(
          userId: user.id,
        );
      case 'favorites':
        return widget.isCurrentUser
            ? FavoritesSection(
                userId: user.id,
              )
            : const Center(child: Text('Section non disponible'));
      case 'subscriptions':
        return widget.isCurrentUser
            ? FollowingSection(
                userId: user.id,
              )
            : const Center(child: Text('Section non disponible'));
      case 'followers':
        return FollowersSection(
          userId: user.id,
        );
      case 'settings':
        return widget.isCurrentUser
            ? SettingsSection(
                userProfile: user,
                onProfileUpdated: _loadUserProfile,
              )
            : const Center(child: Text('Section non disponible'));
      default:
        return MyPlansSection(
          userId: user.id,
        );
    }
  }
}
