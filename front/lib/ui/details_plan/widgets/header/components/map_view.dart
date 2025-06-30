import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:front/utils/helpers.dart';
import 'package:latlong2/latlong.dart';
import 'package:front/domain/models/step/step.dart' as custom;
import 'package:front/ui/details_plan/view_models/details_plan_viewmodel.dart';

class MapView extends StatefulWidget {
  final List<String> stepIds;
  final String category;
  final Color categoryColor;
  final DetailsPlanViewModel viewModel;
  final String? planTitle;
  final String? planDescription;
  final double height;
  final Function(int)? onStepSelected;

  const MapView({
    super.key,
    required this.stepIds,
    required this.category,
    required this.categoryColor,
    required this.viewModel,
    this.planTitle,
    this.planDescription,
    this.height = 280,
    this.onStepSelected,
  });

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  List<custom.Step> _steps = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();
  bool _hasCenteredMap = false;
  final PageController _pageController = PageController();
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSteps() async {
    try {
      List<custom.Step> loadedSteps = [];

      for (String id in widget.stepIds) {
        final step = await widget.viewModel.getStepById(id);
        if (step != null) {
          if (latLngFromDoubles(step.latitude, step.longitude) != null) {
            loadedSteps.add(step);
          } else {
            print("Position nulle pour étape ${step.id}");
          }
        } else {
          print("Étape non trouvée: $id");
        }
      }

      if (mounted) {
        setState(() {
          _steps = loadedSteps;
          _isLoading = false;
        });

        if (loadedSteps.isEmpty) {
          print("Aucune étape avec position valide n'a été chargée");
        }
      }
    } catch (e) {
      print("Erreur chargement étapes: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fitBounds() {
    if (_steps.isEmpty || _hasCenteredMap) return;

    _hasCenteredMap = true;

    try {
      if (_steps.length == 1) {
        _mapController.move(
            latLngFromDoubles(_steps[0].latitude, _steps[0].longitude)!, 12.0);
        return;
      }

      final points = _steps
          .where((step) =>
              latLngFromDoubles(step.latitude, step.longitude) != null)
          .map((step) => latLngFromDoubles(step.latitude, step.longitude)!)
          .toList();

      if (points.isEmpty) return;

      final bounds = LatLngBounds.fromPoints(points);

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(80),
          maxZoom: 14.0,
        ),
      );
    } catch (e) {
      print("Erreur d'ajustement de la carte: $e");
      // Tentative de fallback
      if (_steps.isNotEmpty) {
        _mapController.move(
          LatLng(
            _steps[0].latitude ?? 0,
            _steps[0].longitude ?? 0,
          ),
          13.0,
        );
      }
    }
  }

  void _zoomToStep(int index) {
    if (index < 0 ||
        index >= _steps.length ||
        LatLng(_steps[index].latitude ?? 0, _steps[index].longitude ?? 0) ==
            LatLng(0, 0)) {
      return;
    }

    final step = _steps[index];
    _mapController.move(LatLng(step.latitude ?? 0, step.longitude ?? 0), 18.0);

    setState(() {
      _currentStepIndex = index;
    });
  }

  void recenterMap() {
    if (_steps.isEmpty) return;

    // Si on a déjà centré la carte, on ne fait rien
    if (_hasCenteredMap) return;

    _hasCenteredMap = true;

    // Si une seule étape, on centre dessus
    if (_steps.length == 1) {
      _mapController.move(
        LatLng(_steps[0].latitude ?? 0, _steps[0].longitude ?? 0),
        12.0,
      );
      return;
    }

    // Sinon, on ajuste les limites pour toutes les étapes
    final bounds = LatLngBounds.fromPoints(
      _steps.map((s) => LatLng(s.latitude ?? 0, s.longitude ?? 0)).toList(),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(80),
        maxZoom: 14.0,
      ),
    );
  }

  // méthode recenterMap pour centrer sur tous les marqueurs
  void recenterMapAll() {
    if (_steps.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(
      _steps.map((s) => LatLng(s.latitude ?? 0, s.longitude ?? 0)).toList(),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
        maxZoom: 16.0,
      ),
    );
  }

  void centerOnStep(String stepId) {
    final index = _steps.indexWhere((step) => step.id == stepId);
    if (index != -1) {
      setState(() {
        _currentStepIndex = index;
      });
      _zoomToStep(index);
    }
  }

  List<custom.Step> get steps => _steps;
  Color get categoryColor {
    // Utiliser la couleur fournie
    return widget.categoryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Carte - toujours affichée
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialZoom: 13,
                    initialCenter: _getInitialCenter(),
                    onMapReady: () {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_steps.isNotEmpty) {
                          _fitBounds();
                        } else {
                          _centerOnUserOrDefault();
                        }
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                      retinaMode: MediaQuery.devicePixelRatioOf(context) > 1.0,
                    ),

                    // Marqueurs des étapes (seulement si il y en a)
                    if (_steps.isNotEmpty)
                      MarkerLayer(
                        markers: _steps.asMap().entries.map((entry) {
                          final index = entry.key;
                          final step = entry.value;
                          final isSelected = index == _currentStepIndex;

                          return Marker(
                            width: 40,
                            height: 40,
                            point: LatLng(
                              step.latitude ?? 0,
                              step.longitude ?? 0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentStepIndex = index;
                                });
                                _zoomToStep(index);

                                if (widget.onStepSelected != null) {
                                  widget.onStepSelected!(index);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.location_on,
                                  size: isSelected ? 45 : 35,
                                  color: isSelected
                                      ? categoryColor
                                      : categoryColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    // Marqueur de l'utilisateur (si pas d'étapes avec position)
                    if (_steps.isEmpty && _hasUserLocation())
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: LatLng(
                              widget.viewModel.mapCenterPosition['latitude']!,
                              widget.viewModel.mapCenterPosition['longitude']!,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_pin_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Route (seulement si il y a plusieurs étapes)
                    if (_steps.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _steps
                                .map((s) => LatLng(
                                      s.latitude ?? 0,
                                      s.longitude ?? 0,
                                    ))
                                .toList(),
                            color: categoryColor,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                  ],
                ),

                // Bouton de recentrage
                Positioned(
                  bottom: 80,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 28,
                      shadows: [
                        Shadow(
                            color: Colors.black54,
                            blurRadius: 3,
                            offset: Offset(0, 1)),
                      ],
                    ),
                    onPressed: () {
                      _hasCenteredMap = false;
                      if (_steps.isNotEmpty) {
                        _fitBounds();
                      } else {
                        _centerOnUserOrDefault();
                      }
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                ),

                // Overlay d'information (si pas d'étapes avec position)
                if (_steps.isEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: categoryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _hasUserLocation()
                                  ? 'Votre position actuelle'
                                  : 'Aucune localisation d\'étape disponible',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
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

  // Méthode pour obtenir le centre initial de la carte
  LatLng _getInitialCenter() {
    if (_steps.isNotEmpty &&
        latLngFromDoubles(
              _steps[0].latitude,
              _steps[0].longitude,
            ) !=
            null) {
      return latLngFromDoubles(
        _steps[0].latitude,
        _steps[0].longitude,
      )!;
    }

    final centerPos = widget.viewModel.mapCenterPosition;
    return LatLng(
      centerPos['latitude']!,
      centerPos['longitude']!,
    );
  }

  // Méthode pour vérifier si on a la position de l'utilisateur
  bool _hasUserLocation() {
    final centerPos = widget.viewModel.mapCenterPosition;
    // Vérifier si ce n'est pas la position par défaut de Paris
    return !(centerPos['latitude'] == 48.8566 &&
        centerPos['longitude'] == 2.3522);
  }

  // Méthode pour centrer sur l'utilisateur ou position par défaut
  void _centerOnUserOrDefault() {
    final centerPos = widget.viewModel.mapCenterPosition;
    _mapController.move(
      LatLng(centerPos['latitude']!, centerPos['longitude']!),
      _hasUserLocation()
          ? 15.0
          : 10.0, // Zoom plus proche si c'est l'utilisateur
    );
  }
}
