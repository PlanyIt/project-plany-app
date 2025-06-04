import 'package:flutter/material.dart';
import 'package:front/domain/models/user.dart';
import 'package:front/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralSettings extends StatefulWidget {
  final User userProfile;
  final Function(String, String) showInfoCard;
  final Function(String) showErrorCard;

  const GeneralSettings({
    super.key,
    required this.userProfile,
    required this.showInfoCard,
    required this.showErrorCard,
  });

  @override
  GeneralSettingsState createState() => GeneralSettingsState();
}

class GeneralSettingsState extends State<GeneralSettings> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _darkMode = prefs.getBool('darkMode') ?? false;
        _notifications = prefs.getBool('notifications') ?? true;
      });
    } catch (e) {
      widget.showErrorCard('Erreur lors du chargement des préférences: $e');
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      widget.showErrorCard('Erreur lors de la sauvegarde des préférences: $e');
    }
  }

  void _toggleDarkMode(bool value) async {
    // TODO: Implémenter le mode sombre
    widget.showInfoCard('Développement en cours',
        'Le mode sombre sera disponible prochainement.');

    await _savePreference('darkMode', value);
    setState(() {
      _darkMode = value;
    });
  }

  void _toggleNotifications(bool value) async {
    // TODO: Implémenter les notifications
    widget.showInfoCard('Développement en cours',
        'La gestion des notifications sera disponible prochainement.');

    await _savePreference('notifications', value);
    setState(() {
      _notifications = value;
    });
  }

  void _showAboutInfo() {
    widget.showInfoCard('Plany', 'Version 1.0.0\nTous droits réservés');
  }

  void _showPrivacyPolicy() {
    widget.showInfoCard('Développement en cours',
        'La politique de confidentialité sera disponible prochainement.');
  }

  Future<void> _showLogoutConfirmation() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFF3425B5)),
            SizedBox(width: 10),
            Text('Se déconnecter'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3425B5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _logout();
    }
  }

  Future<void> _logout() async {
    try {
      final AuthService authService = AuthService();
      await authService.logout();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      widget.showErrorCard('Erreur lors de la déconnexion: $e');
    }
  }

  Future<void> _showDeleteAccountConfirmation() async {
    widget.showInfoCard('Développement en cours',
        'La suppression de compte sera disponible prochainement.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSwitchRow(
          title: 'Mode sombre',
          value: _darkMode,
          icon: Icons.dark_mode_outlined,
          onChanged: _toggleDarkMode,
        ),
        _buildSwitchRow(
          title: 'Notifications',
          value: _notifications,
          icon: Icons.notifications_outlined,
          onChanged: _toggleNotifications,
        ),
        _buildActionRow(
          title: 'À propos de Plany',
          icon: Icons.info_outline,
          onTap: _showAboutInfo,
        ),
        _buildActionRow(
          title: 'Politique de confidentialité',
          icon: Icons.privacy_tip_outlined,
          onTap: _showPrivacyPolicy,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _showLogoutConfirmation,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextButton(
            onPressed: _showDeleteAccountConfirmation,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer mon compte'),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3425B5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
