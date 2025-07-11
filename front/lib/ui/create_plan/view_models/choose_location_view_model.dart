import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../services/location_service.dart';

class SearchResult {
  final String name;
  final String description;
  final LatLng location;

  SearchResult({
    required this.name,
    required this.description,
    required this.location,
  });
}

class ChooseLocationViewModel extends ChangeNotifier {
  ChooseLocationViewModel({required LocationService locationService})
      : _locationService = locationService;

  final LocationService _locationService;
  bool _isDisposed = false;

  LatLng? _selectedLocation;
  String _selectedLocationName = '';
  bool _isSearching = false;
  bool _isLoadingCurrentLocation = false;
  List<SearchResult> _searchResults = [];
  String? _errorMessage;

  // Getters
  LatLng? get selectedLocation => _selectedLocation;
  String get selectedLocationName => _selectedLocationName;
  bool get isSearching => _isSearching;
  bool get isLoadingCurrentLocation => _isLoadingCurrentLocation;
  List<SearchResult> get searchResults => _searchResults;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void initializeLocation(LatLng? initialLocation) {
    if (initialLocation != null) {
      _selectedLocation = initialLocation;
      _selectedLocationName = 'Position sélectionnée';
      _safeNotifyListeners();
    } else {
      getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    if (_isDisposed) return;

    _isLoadingCurrentLocation = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();

      if (_isDisposed) return;

      if (position != null) {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _selectedLocationName = 'Ma position actuelle';
        _errorMessage = null;
      } else {
        _setFallbackLocation();
      }
    } catch (e) {
      if (_isDisposed) return;
      print('Erreur lors de l\'obtention de la position: $e');
      _setFallbackLocation();
    } finally {
      if (!_isDisposed) {
        _isLoadingCurrentLocation = false;
        _safeNotifyListeners();
      }
    }
  }

  void _setFallbackLocation() {
    if (_isDisposed) return;
    const fallbackLocation = LatLng(48.856614, 2.3522219);
    _selectedLocation = fallbackLocation;
    _selectedLocationName = 'Position par défaut';
    _errorMessage = 'Impossible d\'obtenir votre position';
  }

  void onMapTap(LatLng point) {
    if (_isDisposed) return;
    _selectedLocation = point;
    _selectedLocationName = 'Position sélectionnée';
    _safeNotifyListeners();
  }

  Future<void> onSearchChanged(String query) async {
    if (_isDisposed) return;

    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      _safeNotifyListeners();
      return;
    }

    _isSearching = true;
    _safeNotifyListeners();

    try {
      final results = await _searchPlaces(query);

      if (_isDisposed) return;

      _searchResults = results;
    } catch (e) {
      if (_isDisposed) return;
      print('Erreur lors de la recherche: $e');
      _searchResults = [];
    } finally {
      if (!_isDisposed) {
        _isSearching = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<List<SearchResult>> _searchPlaces(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$encodedQuery&limit=5&countrycodes=FR&addressdetails=1');

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

          return SearchResult(
            name: name,
            description: description,
            location: LatLng(lat, lon),
          );
        }).toList();
      } else {
        throw Exception('Erreur lors de la recherche: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur geocoding: $e');
      return [];
    }
  }

  void selectSearchResult(SearchResult result) {
    if (_isDisposed) return;
    _selectedLocation = result.location;
    _selectedLocationName = result.name;
    _searchResults = [];
    _safeNotifyListeners();
  }

  void clearSearchResults() {
    if (_isDisposed) return;
    _searchResults = [];
    _safeNotifyListeners();
  }

  bool get canConfirmSelection => _selectedLocation != null;
}
