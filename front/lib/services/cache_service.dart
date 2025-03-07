import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const String _keyUploadedImages = "uploaded_images";

  /// Sauvegarde une URL d'image avec la date d'ajout
  Future<void> saveImageUrl(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedImages = prefs.getStringList(_keyUploadedImages) ?? [];

    // Ajouter l'image avec la date actuelle (timestamp en millisecondes)
    Map<String, dynamic> imageData = {
      "url": imageUrl,
      "timestamp": DateTime.now().millisecondsSinceEpoch
    };

    storedImages.add(jsonEncode(imageData));
    await prefs.setStringList(_keyUploadedImages, storedImages);
  }

  /// Récupère la liste des images valides (moins de 7 jours)
  Future<List<String>> getSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedImages = prefs.getStringList(_keyUploadedImages) ?? [];
    List<String> validImages = [];

    int now = DateTime.now().millisecondsSinceEpoch;
    int sevenDaysInMillis = 7 * 24 * 60 * 60 * 1000;

    for (String imageData in storedImages) {
      Map<String, dynamic> image = jsonDecode(imageData);
      int timestamp = image["timestamp"];

      // Garder les images récentes (moins de 7 jours)
      if (now - timestamp < sevenDaysInMillis) {
        validImages.add(imageData);
      }
    }

    // Mettre à jour le cache avec seulement les images valides
    await prefs.setStringList(_keyUploadedImages, validImages);

    // Retourner uniquement les URLs des images valides
    return validImages.map((e) => jsonDecode(e)["url"] as String).toList();
  }

  /// Supprime toutes les images du cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUploadedImages);
  }
}
