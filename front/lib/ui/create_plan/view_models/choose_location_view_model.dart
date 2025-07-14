import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../data/services/location_service.dart';

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
  bool _isLoadingLocationName = false;
  List<SearchResult> _searchResults = [];
  String? _errorMessage;

  // Getters
  LatLng? get selectedLocation => _selectedLocation;
  String get selectedLocationName => _selectedLocationName;
  bool get isSearching => _isSearching;
  bool get isLoadingCurrentLocation => _isLoadingCurrentLocation;
  bool get isLoadingLocationName => _isLoadingLocationName;
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
        final latLng = LatLng(position.latitude, position.longitude);
        _selectedLocation = latLng;
        _selectedLocationName = 'Localisation en cours...';
        _safeNotifyListeners();

        // Fetch the actual location name
        await _updateLocationName(latLng);
      } else {
        _setFallbackLocation();
      }
    } catch (e) {
      if (_isDisposed) return;
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

  void onMapTap(LatLng point) async {
    if (_isDisposed) return;
    _selectedLocation = point;
    _selectedLocationName = 'Localisation en cours...';
    _safeNotifyListeners();

    // Fetch the actual location name
    await _updateLocationName(point);
  }

  Future<void> _updateLocationName(LatLng location) async {
    if (_isDisposed) return;

    _isLoadingLocationName = true;
    _safeNotifyListeners();

    try {
      final locationName = await _reverseGeocode(location);

      if (_isDisposed) return;

      _selectedLocationName = locationName;
    } catch (e) {
      if (_isDisposed) return;
      _selectedLocationName = 'Position sélectionnée';
    } finally {
      if (!_isDisposed) {
        _isLoadingLocationName = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<String> _reverseGeocode(LatLng location) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1');

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Plany-App/1.0.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['display_name'] != null) {
          final displayName = data['display_name'] as String;
          final parts = displayName.split(', ');

          // Try to get a meaningful name from the address components
          final address = data['address'] as Map<String, dynamic>?;

          if (address != null) {
            // Priority order for location name
            final nameKeys = [
              'house_number',
              'road',
              'pedestrian',
              'amenity',
              'shop',
              'tourism',
              'leisure',
              'building',
              'suburb',
              'neighbourhood',
              'quarter',
              'city_district',
              'village',
              'town',
              'city',
            ];

            String? primaryName;
            String? secondaryName;

            for (final key in nameKeys) {
              if (address[key] != null) {
                if (primaryName == null) {
                  primaryName = address[key] as String;
                } else if (secondaryName == null && key != 'house_number') {
                  secondaryName = address[key] as String;
                  break;
                }
              }
            }

            if (primaryName != null) {
              if (address['house_number'] != null && address['road'] != null) {
                return '${address['house_number']} ${address['road']}';
              } else if (secondaryName != null &&
                  primaryName != secondaryName) {
                return '$primaryName, $secondaryName';
              } else {
                return primaryName;
              }
            }
          }

          return parts.first;
        }
      }

      return 'Position sélectionnée';
    } catch (e) {
      return 'Position sélectionnée';
    }
  }

  void onSearchChanged(String query) async {
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
