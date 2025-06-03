import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front/domain/models/user_profile.dart';
import 'package:front/screens/profile/widgets/content/favorites_section.dart';
import 'package:front/screens/profile/widgets/content/followers_section.dart';
import 'package:front/screens/profile/widgets/content/following_section.dart' show FollowingSection;
import 'package:front/screens/profile/widgets/content/my_plans_section.dart';
import 'package:front/screens/profile/widgets/content/settings_section.dart';
import 'package:front/screens/profile/widgets/header/profile_header.dart';
import 'package:front/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final bool isCurrentUser;
  
  const ProfileScreen({
    super.key,
    this.userId,
    this.isCurrentUser = true,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  UserProfile? _userProfile;
  String _selectedSection = '';
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedSection = 'plans';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      
      final userProfile = await _userService.getUserProfile(widget.userId ?? FirebaseAuth.instance.currentUser!.uid, forceRefresh: true);
      
      final stats = await _userService.getUserStats(widget.userId ?? FirebaseAuth.instance.currentUser!.uid);
      
      userProfile.followersCount = stats['followersCount'];
      userProfile.followingCount = stats['followingCount']; 
      userProfile.plansCount = stats['plansCount'];
      userProfile.favoritesCount = stats['favoritesCount'];
      
      setState(() {
        _userProfile = userProfile;
        _isLoading = false;
      });
          } catch (e) {
      print('Erreur lors du chargement du profil: $e');
      setState(() => _isLoading = false);
    }
  }

  void _updateUserPhoto(String newPhotoUrl) {
    setState(() {
      _userProfile = UserProfile(
        id: _userProfile!.id,
        username: _userProfile!.username,
        email: _userProfile!.email,
        photoUrl: newPhotoUrl,
      );
    });
  }

  Future<void> _refreshProfileStats() async {
    try {
      final stats = await _userService.getUserStats(_userProfile!.id);
      
      setState(() {
        if (_userProfile != null) {
          _userProfile!.followingCount = stats['followingCount'];
          _userProfile!.followersCount = stats['followersCount'];
          _userProfile!.plansCount = stats['plansCount'];
          _userProfile!.favoritesCount = stats['favoritesCount'];
        }
      });
    } catch (e) {
      print('Erreur lors du rafraîchissement des statistiques: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF3425B5)),
          ),
        ),
      );
    }

    if (_userProfile == null) {
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
                  color: const Color(0xFF3425B5).withOpacity(0.7),
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
                onPressed: _loadUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3425B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              ProfileHeader(
                userProfile: _userProfile!,
                onUpdatePhoto: _updateUserPhoto,
                onProfileUpdated: _loadUserData,
                onNavigationSelected: _handleNavigation,
                isCurrentUser: widget.isCurrentUser,
                onFollowChanged: () {
                  _refreshProfileStats();
                },
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
          userId: widget.userId ?? FirebaseAuth.instance.currentUser!.uid,
          onPlansUpdated: () {
            _refreshProfileStats();
          },
        );
      case 'favorites':
        return widget.isCurrentUser 
            ? FavoritesSection(userId: _userProfile!.id)
            : const Center(child: Text('Section non disponible'));
      case 'subscriptions':
        return widget.isCurrentUser
            ? FollowingSection(userId: _userProfile!.id, onFollowChanged: _refreshProfileStats)
            : const Center(child: Text('Section non disponible'));
      case 'followers':
        return FollowersSection(userId: _userProfile!.id, onFollowChanged: _refreshProfileStats);
      case 'settings':
        return widget.isCurrentUser
            ? SettingsSection(onProfileUpdated: _loadUserData, userProfile:  _userProfile!,)
            : const Center(child: Text('Section non disponible'));
      default:
        return MyPlansSection(userId: _userProfile!.id);
    }
  }
}