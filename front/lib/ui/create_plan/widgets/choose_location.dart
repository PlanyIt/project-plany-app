import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front/theme/app_theme.dart';
import 'package:flutter/services.dart';

class ChooseLocation extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;
  final LatLng? initialLocation;

  const ChooseLocation({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<ChooseLocation> createState() => ChooseLocationState();
}

class ChooseLocationState extends State<ChooseLocation>
    with TickerProviderStateMixin {
  LatLng? currentLocation;
  final MapController mapController = MapController();
  final List<Marker> _markers = [];
  String addressName = "";
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isPinDragging = false;
  bool _isCollapsed = false;
  double _mapZoom = 15.0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> _searchResults = [];
  late AnimationController _animationController;

  // Utilisation d'une source de carte plus fiable avec POIs
  final String _mapUrlTemplate =
      'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png';
  // Alternative plus fiable: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
  // Ou: 'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=your_api_key'

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.initialLocation != null) {
      currentLocation = widget.initialLocation;
      _animationController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getAddressFromLatLng(currentLocation!);
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _isLoading = false;
            currentLocation = LatLng(48.8566, 2.3522); // Default to Paris
          });
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            _isLoading = false;
            currentLocation = LatLng(48.8566, 2.3522); // Default to Paris
          });
          return;
        }
      }

      final lastLocation = await location.getLocation();
      final lastPosition =
          LatLng(lastLocation.latitude!, lastLocation.longitude!);

      setState(() {
        currentLocation = lastPosition;
        _isLoading = false;
        _markers.clear();
        _markers.add(_buildMarker(lastPosition));
      });

      // Centrer la carte sur la position actuelle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mapController.move(lastPosition, _mapZoom);
          _animationController.forward();
        }
      });

      // Obtenir l'adresse de la position actuelle
      await _getAddressFromLatLng(lastPosition);
    } catch (e) {
      if (kDebugMode) {
        print("Erreur: $e");
      }
      setState(() {
        _isLoading = false;
        currentLocation = LatLng(48.8566, 2.3522); // Default to Paris
        _markers.clear();
        _markers.add(_buildMarker(currentLocation!));
      });
    }
  }

  double calculateDistance(LatLng pos1, LatLng pos2) {
    // Calcul simple de distance euclidienne (approximatif mais suffisant pour la comparaison)
    return ((pos1.latitude - pos2.latitude) * (pos1.latitude - pos2.latitude) +
            (pos1.longitude - pos2.longitude) *
                (pos1.longitude - pos2.longitude))
        .abs();
  }

  Future<void> _getAddressFromLatLng(LatLng point) async {
    try {
      setState(() {
        addressName = "Recherche de l'adresse...";
        _isPinDragging =
            true; // Mettre à true pendant la recherche pour désactiver le bouton
      });

      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1&accept-language=fr'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            addressName = data['display_name'] ?? "Lieu inconnu";
            _isPinDragging = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          addressName = "Impossible d'obtenir l'adresse";
          _isPinDragging = false;
        });
      }
    }
  }

  Marker _buildMarker(LatLng position) {
    return Marker(
      point: position,
      width: 60,
      height: 60,
      // Remplacer "builder" par un widget enfant direct
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: _isPinDragging ? 0.9 + (value * 0.1) : value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: _isPinDragging ? 4 : 8,
              width: _isPinDragging ? 4 : 8,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isPinDragging ? 42 : 50,
              child: Icon(
                Icons.location_on,
                color: AppTheme.primaryColor,
                size: _isPinDragging ? 42 : 50,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
        headers: {'Accept-Language': 'fr'},
      );

      if (response.statusCode == 200 && mounted) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _searchResults = data;
          _isSearching = false;
        });
      } else if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la recherche: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _selectSearchResult(dynamic result) {
    final newLocation = LatLng(
      double.parse(result['lat']),
      double.parse(result['lon']),
    );

    setState(() {
      currentLocation = newLocation;
      addressName = result['display_name'];
      _markers.clear();
      _markers.add(_buildMarker(newLocation));
      _searchResults = [];
      _searchController.clear();
      _searchFocusNode.unfocus();
    });

    // Animation lors du déplacement vers le nouveau lieu
    _smoothAnimateToPosition(newLocation, 15);
    HapticFeedback.mediumImpact();
  }

  void _smoothAnimateToPosition(LatLng destLocation, double destZoom) {
    // Vérifier si le contrôleur est initialisé
    if (!mounted) {
      // Simplement déplacer sans animation si le contrôleur n'est pas prêt
      try {
        mapController.move(destLocation, destZoom);
      } catch (e) {
        if (kDebugMode) {
          print("Erreur lors du déplacement de la carte: $e");
        }
      }
      return;
    }

    try {
      // Obtenir la position actuelle visible de la carte
      final currentPosition = mapController.camera.center;
      final initialLatitude = currentPosition.latitude;
      final initialLongitude = currentPosition.longitude;

      final latDiff = destLocation.latitude - initialLatitude;
      final lngDiff = destLocation.longitude - initialLongitude;
      const stepDuration = 50; // millisecondes
      const totalDuration = 300; // millisecondes
      const steps = totalDuration ~/ stepDuration;
      const curve = Curves.easeInOut;

      for (int i = 1; i <= steps; i++) {
        final progress = curve.transform(i / steps);
        Future.delayed(Duration(milliseconds: i * stepDuration), () {
          if (mounted) {
            try {
              final currentLat = initialLatitude + latDiff * progress;
              final currentLng = initialLongitude + lngDiff * progress;
              mapController.move(LatLng(currentLat, currentLng), destZoom);
            } catch (e) {
              if (kDebugMode) {
                print("Erreur pendant l'animation: $e");
              }
            }
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de l'animation: $e");
      }
      // Fallback si l'accès à la position actuelle échoue
      try {
        mapController.move(destLocation, destZoom);
      } catch (e) {
        if (kDebugMode) {
          print("Erreur lors du fallback: $e");
        }
      }
    }
  }

  void _toggleInfoPanel() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppTheme.primaryColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Localisation en cours...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recherche de votre position',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Carte en fond avec style unique
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? LatLng(48.8566, 2.3522),
              initialZoom: _mapZoom,
              onTap: (_, point) {
                setState(() {
                  currentLocation = point;
                  _markers.clear();
                  _markers.add(_buildMarker(point));
                  _isPinDragging = true;
                });
                _getAddressFromLatLng(point);
                HapticFeedback.selectionClick();
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _mapZoom = position.zoom ?? _mapZoom;
                  });
                }
              },
              interactionOptions: const InteractionOptions(
                enableMultiFingerGestureRace: true,
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _mapUrlTemplate,
                userAgentPackageName: 'com.plany.app',
                subdomains: const ['a', 'b', 'c'],
                maxZoom: 19,
                minZoom: 3,
                retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(
                markers: currentLocation != null
                    ? [
                        Marker(
                          point: currentLocation!,
                          width: 100,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                          ),
                        )
                      ]
                    : [],
              ),
              MarkerLayer(markers: _markers),
              if (currentLocation != null && !_isPinDragging)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 24,
                      height: 24,
                      point: currentLocation!,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Barre de navigation avec flou
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 10,
                  ),
                  color: Colors.white.withValues(alpha: 0.7),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: AppTheme.primaryColor, size: 18),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Sélectionner un lieu',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (currentLocation != null && !_isPinDragging)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  addressName.isNotEmpty
                                      ? _formatShortAddress(addressName)
                                      : 'Appuyez sur la carte pour choisir un lieu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isCollapsed
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        onPressed: _toggleInfoPanel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Barre de recherche
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _isCollapsed ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: _isCollapsed,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                      Matrix4.translationValues(0, _isCollapsed ? -50 : 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _searchLocation,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un lieu',
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.primaryColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Résultats de recherche
          if (_searchResults.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: 16,
              right: 16,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 60,
                    endIndent: 16,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getLocationTypeIcon(result['type'] ?? ''),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(
                        result['display_name']?.split(',')[0] ?? 'Lieu inconnu',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _formatAddress(result['display_name'] ?? ''),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _selectSearchResult(result),
                    );
                  },
                ),
              ),
            ),

          // Indicateur de chargement de recherche
          if (_isSearching)
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Recherche en cours...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Boutons de navigation sur la carte
          Positioned(
            bottom: 220,
            right: 16,
            child: Column(
              children: [
                _buildMapControlButton(
                  icon: Icons.add,
                  onPressed: () {
                    if (_mapZoom < 19) {
                      setState(() => _mapZoom += 1);
                      mapController.move(currentLocation!, _mapZoom);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.remove,
                  onPressed: () {
                    if (_mapZoom > 3) {
                      setState(() => _mapZoom -= 1);
                      mapController.move(currentLocation!, _mapZoom);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onPressed: _getCurrentLocation,
                  color: Colors.blue,
                ),
              ],
            ),
          ),

          // Panneau inférieur avec l'adresse et le bouton de confirmation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.place,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lieu sélectionné',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isPinDragging
                                  ? "Recherche de l'adresse..."
                                  : (addressName.isNotEmpty
                                      ? addressName
                                      : 'Appuyez sur la carte pour choisir un lieu'),
                              style: TextStyle(
                                fontSize: 14,
                                color: _isPinDragging
                                    ? Colors.grey
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: currentLocation != null &&
                              addressName.isNotEmpty &&
                              !_isPinDragging &&
                              !_isLoadingAddress()
                          ? () {
                              HapticFeedback.heavyImpact();
                              widget.onLocationSelected(
                                currentLocation!,
                                addressName,
                              );
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isPinDragging || _isLoadingAddress()
                                ? "Traitement en cours..."
                                : 'Confirmer ce lieu',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isPinDragging && !_isLoadingAddress()) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_outline, size: 18),
                          ] else
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Nouvelle méthode pour vérifier si l'adresse est en cours de chargement
  bool _isLoadingAddress() {
    return addressName == "Recherche de l'adresse...";
  }

  Widget _buildMapControlButton(
      {required IconData icon, required VoidCallback onPressed, Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
          icon: Icon(icon, size: 18, color: color ?? Colors.black87),
          onPressed: () {
            onPressed();
            HapticFeedback.selectionClick();
          }),
    );
  }

  String _formatAddress(String fullAddress) {
    if (fullAddress.isEmpty) return '';

    // Simplifier l'adresse en prenant seulement la partie après la virgule si elle existe
    List<String> parts = fullAddress.split(', ');
    if (parts.length > 2) {
      return parts.sublist(1, parts.length > 4 ? 4 : parts.length).join(', ');
    }
    return fullAddress;
  }

  // Ajouter cette méthode pour formater l'adresse en version courte
  String _formatShortAddress(String address) {
    List<String> parts = address.split(', ');

    if (parts.length > 2) {
      // Sélectionner les parties les plus pertinentes (généralement le nom de rue et la ville)
      String shortAddress = parts.isNotEmpty
          ? parts[0] // Première partie (généralement le nom du lieu ou la rue)
          : '';

      // Ajouter la ville ou le quartier si disponible
      if (parts.length > 1) {
        shortAddress += ', ${parts[1]}';
      }

      return shortAddress;
    }

    // Si l'adresse est déjà courte, la renvoyer telle quelle
    return address;
  }

  IconData _getLocationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'city':
      case 'town':
      case 'village':
        return Icons.location_city;
      case 'road':
      case 'highway':
      case 'street':
        return Icons.add_road;
      case 'house':
      case 'building':
        return Icons.home;
      case 'restaurant':
      case 'cafe':
      case 'bar':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'park':
      case 'forest':
      case 'garden':
        return Icons.park;
      case 'bus_stop':
      case 'station':
      case 'railway':
        return Icons.directions_bus;
      case 'shop':
      case 'mall':
      case 'store':
        return Icons.shopping_bag;
      default:
        return Icons.place;
    }
  }
}
