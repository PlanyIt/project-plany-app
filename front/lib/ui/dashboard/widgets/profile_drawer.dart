import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../domain/models/user/user.dart';
import '../../../routing/routes.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/button/logout_button.dart';
import '../view_models/dashboard_viewmodel.dart';

class ProfileDrawer extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onLogout;

  const ProfileDrawer({
    super.key,
    required this.onClose,
    required this.onLogout,
    required this.viewModel,
  });

  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final drawerWidth = size.width * 0.85;

    return Container(
      width: drawerWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildDivider(),
            Expanded(
              child: _buildMenuItems(context),
            ),
            _buildDivider(),
            LogoutButton(onPressed: viewModel.logout.execute),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          viewModel.user != null &&
                  viewModel.user?.photoUrl != null &&
                  viewModel.user!.photoUrl!.isNotEmpty
              ? CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(viewModel.user!.photoUrl!),
                  backgroundColor: Colors.transparent,
                  onBackgroundImageError: (error, stackTrace) {
                    if (kDebugMode) {
                      print('Image loading error: $error');
                    }
                  },
                )
              : Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      viewModel.user?.email != null &&
                              viewModel.user!.email.isNotEmpty
                          ? viewModel.user!.email.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.user?.username ?? 'Utilisateur',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.user?.email ?? 'Pas d\'email',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.black54,
                size: 20,
              ),
            ),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[200],
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildMenuItem(
          context,
          'Mon profil',
          Icons.person_outline,
          AppTheme.primaryColor,
          () {
            onClose();
            if (viewModel.user != null && viewModel.user!.id!.isNotEmpty) {
              GoRouter.of(context).go(
                Routes.profile,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Utilisateur non connecté')),
              );
            }
          },
        ),
        _buildMenuItem(
          context,
          'Mes plans & favoris',
          Icons.map_outlined,
          Colors.green,
          () {
            onClose();
            Navigator.pushNamed(context, '/my-plans');
          },
        ),
        _buildMenuItem(
          context,
          'Paramètres',
          Icons.settings_outlined,
          Colors.orange,
          () {
            onClose();
            // Navigation vers paramètres
          },
        ),
        _buildMenuItem(
          context,
          'Aide & Support',
          Icons.help_outline,
          Colors.blue,
          () {
            onClose();
            // Navigation vers aide
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: 16,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
