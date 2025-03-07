import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChooseLocation extends StatefulWidget {
  final Function(GeoPoint, String) onLocationSelected;

  const ChooseLocation({super.key, required this.onLocationSelected});

  @override
  ChooseLocationState createState() => ChooseLocationState();
}

class ChooseLocationState extends State<ChooseLocation> {
  loc.Location location = loc.Location();
  GeoPoint? currentLocation;
  MapController? mapController;
  final List<GeoPoint> _markers = [];
  final TextEditingController _addressController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _isSearchExpanded = false;
  String _currentAddress = '';
  Timer? _debounce;

  void _getCurrentLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Vérifier les permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    try {
      // Obtenir la position actuelle
      final locData = await location.getLocation();
      final GeoPoint position = GeoPoint(
        latitude: locData.latitude!,
        longitude: locData.longitude!,
      );

      setState(() {
        currentLocation = position;
      });

      // Initialiser le mapController après avoir défini la position
      mapController = MapController(
        initMapWithUserPosition: UserTrackingOption(
          enableTracking: true,
        ),
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'obtention de la position: $e');
      // Gérer l'erreur
    }
  }

  Future<void> _getAddressFromLatLng(GeoPoint point) async {
    setState(() {
      _currentAddress = 'Recherche de l\'adresse...';
      _addressController.text = _currentAddress;
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json&addressdetails=1'),
        headers: {
          'User-Agent':
              'Plany App', // Ajoutez un User-Agent pour éviter d'être bloqué
          'Accept-Language': 'fr', // Demander des résultats en français
        },
      ).timeout(const Duration(seconds: 5)); // Ajouter un timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extraire les informations d'adresse
        final address = data['address'] ?? {};
        final city =
            address['city'] ?? address['town'] ?? address['village'] ?? '';
        final district =
            address['suburb'] ?? address['district'] ?? address['county'] ?? '';
        final road = address['road'] ?? '';
        final houseNumber = address['house_number'] ?? '';
        final state = address['state'] ?? '';

        // Construire l'adresse de manière plus complète et plus lisible
        String formattedAddress = '';

        // Commencer par le numéro et la rue
        if (road.isNotEmpty) {
          formattedAddress =
              houseNumber.isNotEmpty ? "$houseNumber $road" : road;
        }

        // Ajouter le district/quartier si présent et différent de la ville
        if (district.isNotEmpty && district != city) {
          formattedAddress = formattedAddress.isNotEmpty
              ? "$formattedAddress, $district"
              : district;
        }

        // Ajouter la ville
        if (city.isNotEmpty) {
          formattedAddress =
              formattedAddress.isNotEmpty ? "$formattedAddress, $city" : city;
        }

        // Ajouter l'état/région si présent et différent de la ville
        if (state.isNotEmpty && state != city && state != district) {
          formattedAddress = "$formattedAddress, $state";
        }

        // Si formattedAddress est encore vide, utiliser display_name
        if (formattedAddress.isEmpty) {
          formattedAddress =
              data['display_name']?.toString().split(',').take(3).join(', ') ??
                  'Adresse trouvée';
        }

        setState(() {
          _currentAddress = formattedAddress;
          _addressController.text = formattedAddress;
        });

        debugPrint('Adresse récupérée: $formattedAddress');
      } else {
        throw Exception('Échec de la requête: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'adresse: $e');
      setState(() {
        _currentAddress =
            'Lat: ${point.latitude.toStringAsFixed(6)}, Lng: ${point.longitude.toStringAsFixed(6)}';
        _addressController.text = _currentAddress;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Search address using the API
  void _searchAddress(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearchExpanded = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isLoading = true;
        _isSearchExpanded = true;
      });

      try {
        final response = await http.get(
            Uri.parse(
                'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5'),
            headers: {
              'User-Agent':
                  'Plany App', // Respecter les conditions d'utilisation de Nominatim
              'Accept-Language': 'fr', // Résultats en français
            });

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          if (mounted) {
            setState(() {
              _searchResults = data;
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        debugPrint('Failed to search address: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  void _selectSearchResult(dynamic location) {
    final newLocation = GeoPoint(
      latitude: double.parse(location['lat']),
      longitude: double.parse(location['lon']),
    );
    mapController!.moveTo(newLocation);
    setState(() {
      _markers.clear();
      _markers.add(newLocation);
      _searchResults = [];
      _isSearchExpanded = false;
      _addressController.text =
          location['display_name'].toString().split(',').take(2).join(',');
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn1',
            backgroundColor: Colors.white,
            tooltip: "Ma position",
            child: Icon(
              Icons.my_location,
              color: theme.primaryColor,
            ),
            onPressed: () async {
              if (currentLocation != null && mapController != null) {
                mapController!.moveTo(currentLocation!);

                setState(() {
                  _markers.clear();
                  _markers.add(currentLocation!);
                  _isSearchExpanded = false;
                });

                // Attendre que l'adresse soit récupérée avant de continuer
                await _getAddressFromLatLng(currentLocation!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Localisation en cours...')));
                _getCurrentLocation();
              }
            },
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'btn2',
            backgroundColor: Colors.white,
            child: const Icon(Icons.add),
            onPressed: () {
              if (mapController != null) {
                mapController!.zoomIn();
              }
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'btn3',
            backgroundColor: Colors.white,
            child: const Icon(Icons.remove),
            onPressed: () {
              if (mapController != null) {
                mapController!.zoomOut();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Displaying map
          if (mapController != null)
            OSMFlutter(
              controller: mapController!,
              osmOption: OSMOption(
                zoomOption: ZoomOption(
                  initZoom: 15,
                  minZoomLevel: 4,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                staticPoints: [
                  StaticPositionGeoPoint(
                    'markers',
                    MarkerIcon(
                      icon: Icon(
                        Icons.location_on,
                        color: theme.primaryColor,
                        size: 48,
                      ),
                    ),
                    _markers,
                  ),
                ],
                userLocationMarker: UserLocationMaker(
                  personMarker: MarkerIcon(
                    icon: Icon(
                      Icons.person_pin_circle,
                      color: theme.primaryColor.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
                  directionArrowMarker: MarkerIcon(
                    icon: Icon(
                      Icons.navigation,
                      color: theme.primaryColor,
                      size: 32,
                    ),
                  ),
                ),
                roadConfiguration: RoadOption(
                  roadColor: theme.primaryColor.withOpacity(0.7),
                  roadWidth: 8,
                ),
                showDefaultInfoWindow: false,
              ),
              onMapIsReady: (isReady) {
                if (isReady && currentLocation != null) {
                  mapController!.moveTo(currentLocation!);
                }
              },
              onGeoPointClicked: (geoPoint) async {
                setState(() {
                  _markers.clear();
                  _markers.add(geoPoint);
                  _isSearchExpanded = false;
                });
                // Récupérer l'adresse pour la position sélectionnée
                await _getAddressFromLatLng(geoPoint);

                // Feedback visuel de sélection
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Position sélectionnée'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: theme.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),

          // Address search input
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _addressController,
                      onChanged: _searchAddress,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une adresse',
                        hintStyle: const TextStyle(color: Colors.black45),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.black45),
                        suffixIcon: _addressController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.black45),
                                onPressed: () {
                                  _addressController.clear();
                                  setState(() {
                                    _searchResults = [];
                                    _isSearchExpanded = false;
                                    _markers.clear();
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                  if (_isSearchExpanded)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final location = _searchResults[index];
                                final displayName = location['display_name'];
                                final mainName =
                                    displayName.toString().split(',')[0];
                                final secondaryName = displayName
                                    .toString()
                                    .split(',')
                                    .skip(1)
                                    .take(2)
                                    .join(',');

                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.place,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    mainName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    secondaryName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => _selectSearchResult(location),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                );
                              },
                            ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom info panel when a location is selected
          if (_markers.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Emplacement sélectionné',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _addressController.text.isNotEmpty
                                ? _addressController.text
                                : 'Position actuelle',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Lat: ${_markers.last.latitude.toStringAsFixed(6)}\nLng: ${_markers.last.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            widget.onLocationSelected(
                                _markers.last, _addressController.text);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Sélectionner',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
