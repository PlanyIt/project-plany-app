import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData getIconData(String iconName) {
  // Log pour debugger le nom de l'icône reçue

  // Map des noms d'icônes vers les IconData
  final Map<String, IconData> iconMap = {
    'flight': Icons.flight,
    'sports_soccer': Icons.sports_soccer,
    'restaurant': Icons.restaurant,
    'menu_book': Icons.menu_book,
    'music_note': Icons.music_note,
    'spa': Icons.spa,
    'build': Icons.build,
    'devices': Icons.devices,
    'local_bar': Icons.local_bar,
    'category': Icons.category,
    'list': Icons.list,

    // Ajouter d'autres mappages d'icônes selon vos besoins
    // ...

    // Mappages de secours pour les icônes non trouvées
    'place_outlined': Icons.place_outlined,
    'access_time_outlined': Icons.access_time_outlined,
    'euro_outlined': Icons.euro_outlined,
  };

  // Retourne l'IconData correspondant ou une icône par défaut
  return iconMap[iconName] ?? Icons.help_outline;
}
