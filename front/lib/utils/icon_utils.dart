import 'package:flutter/material.dart';

IconData getIconData(String? iconName) {
  // Si l'icône est null ou vide, retourner une icône par défaut
  if (iconName == null || iconName.isEmpty) {
    return Icons.category;
  }

  // Map des noms d'icônes vers les IconData
  final iconMap = <String, IconData>{
    // Icônes de base
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

    // Transport
    'directions_car': Icons.directions_car,
    'directions_bus': Icons.directions_bus,
    'directions_train': Icons.directions_train,
    'directions_boat': Icons.directions_boat,
    'directions_bike': Icons.directions_bike,
    'directions_walk': Icons.directions_walk,
    'local_airport': Icons.local_airport,
    'flight_takeoff': Icons.flight_takeoff,
    'flight_land': Icons.flight_land,

    // Divertissement
    'movie': Icons.movie,
    'theaters': Icons.theaters,
    'headphones': Icons.headphones,
    'sports': Icons.sports,
    'beach_access': Icons.beach_access,
    'pool': Icons.pool,
    'park': Icons.park,
    'casino': Icons.casino,

    // Gastronomie
    'restaurant_menu': Icons.restaurant_menu,
    'fastfood': Icons.fastfood,
    'local_cafe': Icons.local_cafe,
    'local_drink': Icons.local_drink,
    'bakery_dining': Icons.bakery_dining,
    'icecream': Icons.icecream,

    // Culture
    'museum': Icons.museum,
    'local_library': Icons.local_library,
    'account_balance': Icons.account_balance,
    'location_city': Icons.location_city,
    'church': Icons.church,

    // Icônes spécifiques
    'favorite': Icons.favorite,
    'nightlife': Icons.nightlife,
    'nature': Icons.landscape,
    'celebration': Icons.celebration,
    'shopping_bag': Icons.shopping_bag,
    'museum': Icons.museum,
    'sports': Icons.sports_soccer,
    'home_filled': Icons.home,
    'home_rounded': Icons.home_rounded,
    'house': Icons.house,
    'house_outlined': Icons.house_outlined,
    // ...

    // Mappages de secours pour les icônes non trouvées
    'place_outlined': Icons.place_outlined,
    'access_time_outlined': Icons.access_time_outlined,
    'euro_outlined': Icons.euro_outlined,
  };

  // Retourne l'IconData correspondant ou une icône par défaut
  return iconMap[iconName] ?? Icons.help_outline;
}
