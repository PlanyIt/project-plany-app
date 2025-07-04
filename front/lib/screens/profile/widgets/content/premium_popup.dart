import 'package:flutter/material.dart';
import 'package:front/domain/models/user.dart';
import 'package:front/services/user_service.dart';

class PremiumPopup {
  static Future<void> show({
    required BuildContext context,
    required User userProfile,
    required Function onProfileUpdated,
    required Function(String, String) showInfoCard,
    required Function(String) showErrorCard,
    Function(bool)? onLoadingChanged,
  }) async {
    final bool isPremium = userProfile.isPremium;
    final _userService = UserService();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.workspace_premium,
              color: isPremium ? Colors.amber : const Color(0xFF3425B5),
            ),
            const SizedBox(width: 10),
            Text(isPremium ? 'Désactiver Premium' : 'Devenir Premium'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: isPremium
                ? [
                    const Text(
                        'Vous êtes actuellement un utilisateur Premium.'),
                    const SizedBox(height: 10),
                    const Text('Avantages dont vous bénéficiez :'),
                    const SizedBox(height: 8),
                    _buildPremiumFeature('Photos illimitées pour vos plans'),
                    _buildPremiumFeature('Accès aux cartes hors ligne'),
                    _buildPremiumFeature('Pas de publicités'),
                    _buildPremiumFeature('Support prioritaire'),
                    const SizedBox(height: 10),
                    const Text(
                      'Si vous désactivez Premium, vous perdrez ces avantages.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [
                    const Text('Passez à Premium pour débloquer :'),
                    const SizedBox(height: 8),
                    _buildPremiumFeature('Photos illimitées pour vos plans'),
                    _buildPremiumFeature('Accès aux cartes hors ligne'),
                    _buildPremiumFeature('Pas de publicités'),
                    _buildPremiumFeature('Support prioritaire'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Offre spéciale',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Seulement 4.99€/mois'),
                          SizedBox(height: 2),
                          Text(
                            'ou 49.99€/an (soit 2 mois gratuits)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isPremium ? Colors.grey : const Color(0xFF3425B5),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);

              if (onLoadingChanged != null) {
                onLoadingChanged(true);
              }

              try {
                final success = isPremium
                    ? await _userService.updatePremiumStatus(
                        userProfile.id, false)
                    : await _userService.updatePremiumStatus(
                        userProfile.id, true);

                if (success) {
                  userProfile.isPremium = !isPremium;

                  if (onLoadingChanged != null) {
                    onLoadingChanged(false);
                  }
                  onProfileUpdated();

                  showInfoCard(
                    isPremium ? 'Premium désactivé' : 'Félicitations !',
                    isPremium
                        ? 'Votre abonnement Premium a été désactivé.'
                        : 'Vous êtes maintenant un utilisateur Premium!',
                  );
                } else {
                  throw Exception("Échec de la mise à jour du statut premium");
                }
              } catch (e) {
                if (onLoadingChanged != null) {
                  onLoadingChanged(false);
                }
                showErrorCard('Erreur: $e');
              }
            },
            child: Text(isPremium ? 'Désactiver' : 'Activer Premium'),
          ),
        ],
      ),
    );
  }

  static Widget _buildPremiumFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
