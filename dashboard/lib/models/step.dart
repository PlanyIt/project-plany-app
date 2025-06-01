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
    if (json.containsKey('latitude') && json.containsKey('longitude')) {
      position = LatLng(double.parse(json['latitude'].toString()),
          double.parse(json['longitude'].toString()));
    }

    return Step(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      order: json['order'],
      userId: json['userId'],
      duration: json['duration'],
      cost: json['cost']?.toDouble(),
      position: position,
      image: json['image'],

      // Nous conservons l'adresse localement dans l'application
      // même si elle n'existe pas dans la réponse du serveur
      address: json['address'],
    );
  }
}
