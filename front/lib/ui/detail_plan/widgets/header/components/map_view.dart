import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../domain/models/step/step.dart' as custom;
import '../../../view_models/plan_details_viewmodel.dart';

class MapView extends StatefulWidget {
  final PlanDetailsViewModel viewModel;
  final double height;
  final Function(int)? onStepSelected;

  const MapView({
    super.key,
    required this.viewModel,
    this.height = 280,
    this.onStepSelected,
  });

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  bool _hasCenteredMap = false;
  int _currentStepIndex = 0;

  List<custom.Step> get _steps => widget.viewModel.steps;
  Color get _categoryColor => widget.viewModel.planCategoryColor ?? Colors.grey;

  void _fitBounds() {
    if (_steps.isEmpty || _hasCenteredMap) return;

    _hasCenteredMap = true;

    final points = _steps
        .where((s) => s.latitude != null && s.longitude != null)
        .map((s) => LatLng(s.latitude!, s.longitude!))
        .toList();

    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);

    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(80),
          maxZoom: 14.0,
        ),
      );
    } catch (e) {
      debugPrint("Erreur lors du centrage de la carte: $e");
      final fallback = _steps.first;
      _mapController.move(
        LatLng(fallback.latitude ?? 0.0, fallback.longitude ?? 0.0),
        14.0,
      );
    }
  }

  void _zoomToStep(int index) {
    final step = _steps[index];
    final lat = step.latitude ?? 0.0;
    final lng = step.longitude ?? 0.0;

    _mapController.move(LatLng(lat, lng), 15.0);

    setState(() => _currentStepIndex = index);
  }

  void updateSelectedStep(int index) {
    _zoomToStep(index);
    widget.onStepSelected?.call(index);
  }

  void centerOnStep(String stepId) {
    final index = _steps.indexWhere((s) => s.id == stepId);
    if (index != -1) {
      _zoomToStep(index);
      // Don't call widget.onStepSelected here to avoid circular calls
    }
  }

  void recenterMapAll() {
    _hasCenteredMap = false;
    _fitBounds();
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text("Aucun emplacement disponible")),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialZoom: 13,
              initialCenter: LatLng(
                _steps.first.latitude ?? 0.0,
                _steps.first.longitude ?? 0.0,
              ),
              onMapReady: () => Future.delayed(
                const Duration(milliseconds: 500),
                _fitBounds,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              MarkerLayer(
                markers: _steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isSelected = index == _currentStepIndex;

                  return Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(step.latitude ?? 0.0, step.longitude ?? 0.0),
                    child: GestureDetector(
                      onTap: () => updateSelectedStep(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.location_on,
                          size: isSelected ? 45 : 35,
                          color: isSelected
                              ? _categoryColor
                              : _categoryColor.withValues(alpha: .7),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_steps.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _steps
                          .map((s) =>
                              LatLng(s.latitude ?? 0.0, s.longitude ?? 0.0))
                          .toList(),
                      color: _categoryColor,
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
              onPressed: recenterMapAll,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
