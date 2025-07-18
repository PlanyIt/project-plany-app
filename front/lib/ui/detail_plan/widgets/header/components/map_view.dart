import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../domain/models/step/step.dart' as custom;
import '../../../view_models/detail/plan_details_viewmodel.dart';

class MapView extends StatefulWidget {
  final PlanDetailsViewModel viewModel;
  final double height;
  final Future<void> Function(int)? onStepSelected;

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

  List<custom.Step> get _steps => widget.viewModel.steps;
  Color get _categoryColor => widget.viewModel.planCategoryColor ?? Colors.grey;

  LatLng _latLngOf(custom.Step step) =>
      LatLng(step.latitude ?? 0.0, step.longitude ?? 0.0);

  void _fitBounds() {
    if (_steps.isEmpty || _hasCenteredMap) return;

    _hasCenteredMap = true;

    final points = _steps
        .where((s) => s.latitude != null && s.longitude != null)
        .map(_latLngOf)
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
      final fallback = points.isNotEmpty ? points.first : LatLng(0.0, 0.0);
      _mapController.move(fallback, 14.0);
    }
  }

  void _zoomToStep(int index) {
    final step = _steps[index];
    _mapController.move(_latLngOf(step), 15.0);
  }

  Future<void> onMarkerTap(int index) async {
    _zoomToStep(index);
    if (widget.onStepSelected != null) {
      await widget.onStepSelected!(index);
    }
  }

  void centerOnStep(String stepId) {
    final index = _steps.indexWhere((s) => s.id == stepId);
    if (index != -1) {
      _zoomToStep(index);
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
              initialCenter: _latLngOf(_steps.first),
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
                  final isSelected = index == widget.viewModel.currentStepIndex;

                  return Marker(
                    width: 40,
                    height: 40,
                    point: _latLngOf(step),
                    child: GestureDetector(
                      onTap: () => onMarkerTap(index),
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
                      points: _steps.map(_latLngOf).toList(),
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
