import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  // Singleton interne
  LocationService._internal();

  // Ce constructeur ne sert que pour les tests / fakes
  LocationService.test();

  final _log = Logger('LocationService');

  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  bool _permissionDenied = false;
  bool _serviceDisabled = false;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLocation => _currentPosition != null;
  bool get permissionDenied => _permissionDenied;
  bool get serviceDisabled => _serviceDisabled;

  Future<void> initialize() async {
    _log.info('Initialisation du service de localisation');
    await _checkLocationService();
    await getCurrentLocation();
  }

  Future<bool> requestLocationService() async {
    try {
      _log.info('Demande d\'activation du service de localisation');
      final serviceEnabled = await Geolocator.openLocationSettings();
      if (serviceEnabled) {
        _serviceDisabled = false;
        _clearError();
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 500));
        return await _checkLocationService();
      }
      return false;
    } catch (e) {
      _log.warning('Erreur lors de la demande d\'activation: $e');
      return false;
    }
  }

  Future<bool> _checkLocationService() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _serviceDisabled = !serviceEnabled;
    notifyListeners();
    return serviceEnabled;
  }

  Future<List<LocationResult>> searchLocationByName(String query) async {
    if (query.isEmpty) return [];
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=$encodedQuery&limit=5&countrycodes=FR&addressdetails=1',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'Plany-App/1.0.0',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        final lat = double.parse(item['lat']);
        final lon = double.parse(item['lon']);
        final displayName = item['display_name'] as String;

        final parts = displayName.split(', ');
        final name = parts.first;
        final description = parts.length > 1
            ? parts.sublist(1, parts.length.clamp(0, 3)).join(', ')
            : '';

        return LocationResult(
          name: name,
          description: description,
          location: LatLng(lat, lon),
        );
      }).toList();
    } else {
      return [];
    }
  }

  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    if (_currentPosition != null && !forceRefresh) {
      return _currentPosition;
    }
    _setLoading(true);
    _clearError();

    try {
      final serviceEnabled = await _checkLocationService();
      if (!serviceEnabled) {
        _setError('Le service de localisation est désactivé');
        _log.warning('Service de localisation désactivé');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        _log.info('Permission de localisation refusée, demande en cours...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Permission de localisation refusée');
          _permissionDenied = true;
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError('Permission de localisation refusée définitivement');
        _permissionDenied = true;
        return null;
      }

      _log.info('Obtention de la position en cours...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition = position;
      _permissionDenied = false;
      _serviceDisabled = false;
      _log.info(
          'Position obtenue: ${position.latitude}, ${position.longitude}');
      notifyListeners();
      return position;
    } on LocationServiceDisabledException {
      _log.warning('Service de localisation désactivé');
      _setError('Le service de localisation est désactivé');
      _serviceDisabled = true;
      return null;
    } on PermissionDeniedException {
      _log.warning('Permission de localisation refusée');
      _setError('Permission de localisation refusée');
      _permissionDenied = true;
      return null;
    } catch (e) {
      _log.warning('Erreur lors de l\'obtention de la position: $e');
      _setError('Impossible d\'obtenir la position');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  double? calculateDistanceToPoint(double latitude, double longitude) {
    if (_currentPosition == null) return null;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  double? calculateDistanceToPlan(double? planLat, double? planLng) {
    if (_currentPosition == null || planLat == null || planLng == null) {
      return null;
    }
    return calculateDistanceToPoint(planLat, planLng);
  }

  Future<String?> reverseGeocode(LatLng location) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Plany-App/1.0.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final nameKeys = [
            'road',
            'neighbourhood',
            'suburb',
            'city_district',
            'city',
            'town',
            'village',
          ];
          for (final key in nameKeys) {
            if (address[key] != null) {
              return address[key] as String;
            }
          }
        }
        return data['display_name'] ?? null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class LocationResult {
  final String name;
  final String description;
  final LatLng location;

  LocationResult({
    required this.name,
    required this.description,
    required this.location,
  });
}
