import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:front/domain/models/step/step.dart' as custom;
import 'package:front/services/step_service.dart';
import 'dart:math' as math;

class MapView extends StatefulWidget {
  final List<String> stepIds;
  final String category;
  final Color categoryColor;
  final String? planTitle;
  final String? planDescription;
  final double height;
  final Function(int)? onStepSelected;

  const MapView({
    Key? key,
    required this.stepIds,
    required this.category,
    required this.categoryColor,
    this.planTitle,
    this.planDescription,
    this.height = 280,
    this.onStepSelected,
  }) : super(key: key);

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final StepService _stepService = StepService();
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
        final step = await _stepService.getStepById(id);
        if (step != null) {
          if (step.position != null) {
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
        _mapController.move(_steps[0].position!, 12.0);
        return;
      }

      final points = _steps
          .where((step) => step.position != null)
          .map((step) => step.position!)
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
        _mapController.move(_steps[0].position!, 13.0);
      }
    }
  }

  void _zoomToStep(int index) {
    if (index < 0 || index >= _steps.length || _steps[index].position == null)
      return;

    final step = _steps[index];
    _mapController.move(
        LatLng(step.position!.latitude, step.position!.longitude), 18.0);

    setState(() {
      _currentStepIndex = index;
    });
  }

  void recenterMap() {
    if (_steps.isNotEmpty && _steps[0].position != null) {
      _mapController.move(
        LatLng(_steps[0].position!.latitude, _steps[0].position!.longitude),
        15.0,
      );
    }
  }

  // méthode recenterMap pour centrer sur tous les marqueurs
  void recenterMapAll() {
    if (_steps.isEmpty) return;

    final bounds = LatLngBounds(
      LatLng(
        _steps
            .map((m) => m.position!.latitude)
            .reduce((min, pos) => pos < min ? pos : min),
        _steps
            .map((m) => m.position!.longitude)
            .reduce((min, pos) => pos < min ? pos : min),
      ),
      LatLng(
        _steps
            .map((m) => m.position!.latitude)
            .reduce((max, pos) => pos > max ? pos : max),
        _steps
            .map((m) => m.position!.longitude)
            .reduce((max, pos) => pos > max ? pos : max),
      ),
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
    // Utiliser la couleur fournie, ou une couleur par défaut si null
    return widget.categoryColor ?? Colors.deepPurpleAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _steps.isEmpty
              ? const Center(child: Text("Aucun emplacement disponible"))
              : Stack(
                  children: [
                    // Carte
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialZoom: 13,
                        initialCenter: _steps.isNotEmpty
                            ? _steps[0].position!
                            : const LatLng(48.856614, 2.3522219),
                        onMapReady: () {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _fitBounds();
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                          subdomains: ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.app',
                        ),

                        // Marqueurs avec indicateur de sélection
                        MarkerLayer(
                          markers: _steps.asMap().entries.map((entry) {
                            final index = entry.key;
                            final step = entry.value;
                            final isSelected = index == _currentStepIndex;

                            return Marker(
                              width: 40,
                              height: 40,
                              point: step.position!,
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

                        // Route
                        if (_steps.length >= 2)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _steps.map((s) => s.position!).toList(),
                                color: categoryColor,
                                strokeWidth: 4,
                              ),
                            ],
                          ),
                      ],
                    ),
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
                          _fitBounds();
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
    );
  }
}
