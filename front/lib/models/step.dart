import 'package:latlong2/latlong.dart';

class Step {
  final String? id;
  final String title;
  final String description;
  final int order;
  final String userId;
  final String? duration;
  final double? cost;
  final LatLng? position; // Ne sera pas envoyé directement au serveur
  final String? image;
  final String? address; // Ne sera pas envoyé directement au serveur

  Step({
    this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.userId,
    this.duration,
    this.cost,
    this.position,
    this.image,
    this.address,
  });

  Map<String, dynamic> toJson() {
    // On supprime les propriétés qui causent des erreurs 400
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'order': order,
      'userId': userId,
      'image': image,
    };

    if (duration != null) data['duration'] = duration;
    if (cost != null) data['cost'] = cost;

    // Ajouter les coordonnées séparément plutôt que l'objet position
    // Seulement si nous avons une position valide
    if (position != null) {
      data['latitude'] = position!.latitude;
      data['longitude'] = position!.longitude;
    }

    // Nous n'envoyons pas la propriété 'address' au serveur
    // car elle n'est pas acceptée par le backend

    if (id != null) data['_id'] = id;

    return data;
  }

  factory Step.fromJson(Map<String, dynamic> json) {
    // Reconstruction de l'objet LatLng à partir de lat/lng
    LatLng? position;

    if (json['latitude'] != null && json['longitude'] != null) {
      try {
        final double latitude = (json['latitude'] is int)
            ? (json['latitude'] as int).toDouble()
            : json['latitude'];

        final double longitude = (json['longitude'] is int)
            ? (json['longitude'] as int).toDouble()
            : json['longitude'];


        position = LatLng(latitude, longitude);
      } catch (e) {
        print("Erreur position: $e");
      }
    } else {
      print("Coordonnées non trouvées dans le JSON");
    }

    double? cost;
    if (json['cost'] != null) {
      cost =
          json['cost'] is int ? (json['cost'] as int).toDouble() : json['cost'];
    }

    return Step(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      order: json['order'],
      userId: json['userId'],
      duration: json['duration'],
      cost: cost,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'order': order,
      'image': image,
      'duration': duration,
      'cost': cost,
      'userId': userId,
    };

    // Envoyer latitude et longitude directement au niveau racine
    if (position != null) {
      data['latitude'] = position!.latitude;
      data['longitude'] = position!.longitude;
    }

    return data;
  }
}
