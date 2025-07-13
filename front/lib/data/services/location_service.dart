import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

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

  /// Initialise la géolocalisation au démarrage de l'app
  Future<void> initialize() async {
    _log.info('Initialisation du service de localisation');

    // Vérifier l'état initial du service
    await _checkLocationService();

    // Obtenir la position une seule fois
    await getCurrentLocation();
  }

  /// Demande à l'utilisateur d'activer le service de localisation
  Future<bool> requestLocationService() async {
    try {
      _log.info('Demande d\'activation du service de localisation');

      // Tenter d'ouvrir les paramètres de localisation
      final serviceEnabled = await Geolocator.openLocationSettings();

      if (serviceEnabled) {
        _serviceDisabled = false;
        _clearError();
        notifyListeners();

        // Réessayer d'obtenir la position après activation
        await Future.delayed(const Duration(milliseconds: 500));
        return await _checkLocationService();
      }

      return false;
    } catch (e) {
      _log.warning('Erreur lors de la demande d\'activation: $e');
      return false;
    }
  }

  /// Vérifie si le service de localisation est activé
  Future<bool> _checkLocationService() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _serviceDisabled = !serviceEnabled;
    notifyListeners();
    return serviceEnabled;
  }

  /// Récupère la position actuelle de l'utilisateur
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    if (_currentPosition != null && !forceRefresh) {
      return _currentPosition;
    }

    _setLoading(true);
    _clearError();

    try {
      // Vérifier si le service de localisation est activé
      final serviceEnabled = await _checkLocationService();
      if (!serviceEnabled) {
        _setError('Le service de localisation est désactivé');
        _log.warning('Service de localisation désactivé');
        return null;
      }

      // Vérifier les permissions
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

      // Obtenir la position
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
      _setError('Impossible d\'obtenir la position: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Calcule la distance entre la position actuelle et un point donné
  double? calculateDistanceToPoint(double latitude, double longitude) {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// Calcule la distance entre la position actuelle et un plan
  double? calculateDistanceToPlan(double? planLat, double? planLng) {
    if (_currentPosition == null || planLat == null || planLng == null) {
      return null;
    }

    return calculateDistanceToPoint(planLat, planLng);
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
