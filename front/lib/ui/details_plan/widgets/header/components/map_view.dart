import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:front/domain/models/step/step.dart' as custom;
import 'package:front/providers/providers.dart';
import 'package:front/utils/result.dart';

// Providers pour l'état de la carte
final mapStepsProvider =
    StateProvider.family<List<custom.Step>, List<String>>((ref, stepIds) => []);
final mapIsLoadingProvider =
    StateProvider.family<bool, String>((ref, mapId) => true);
final mapCurrentStepIndexProvider =
    StateProvider.family<int, String>((ref, mapId) => 0);
final mapHasCenteredProvider =
    StateProvider.family<bool, String>((ref, mapId) => false);

class MapView extends ConsumerStatefulWidget {
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
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final MapController _mapController = MapController();
  final PageController _pageController = PageController();
  late String _mapId;

  @override
  void initState() {
    super.initState();
    _mapId = widget.stepIds.join('-');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSteps();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSteps() async {
    ref.read(mapIsLoadingProvider(_mapId).notifier).state = true;

    try {
      List<custom.Step> loadedSteps = [];
      final stepRepository = ref.read(stepRepositoryProvider);

      for (String id in widget.stepIds) {
        final stepResult = await stepRepository.getStepById(id);
        if (stepResult is Ok<custom.Step>) {
          final step = stepResult.value;
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
        ref.read(mapStepsProvider(widget.stepIds).notifier).state = loadedSteps;
        ref.read(mapIsLoadingProvider(_mapId).notifier).state = false;

        if (loadedSteps.isEmpty) {
          print("Aucune étape avec position valide n'a été chargée");
        }
      }
    } catch (e) {
      print("Erreur chargement étapes: $e");
      if (mounted) {
        ref.read(mapIsLoadingProvider(_mapId).notifier).state = false;
      }
    }
  }

  void _fitBounds() {
    final steps = ref.read(mapStepsProvider(widget.stepIds));
    final hasCentered = ref.read(mapHasCenteredProvider(_mapId));

    if (steps.isEmpty || hasCentered) return;

    ref.read(mapHasCenteredProvider(_mapId).notifier).state = true;

    try {
      if (steps.length == 1) {
        _mapController.move(steps[0].position!, 12.0);
        return;
      }

      final points = steps
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
      if (steps.isNotEmpty) {
        _mapController.move(steps[0].position!, 13.0);
      }
    }
  }

  void _zoomToStep(int index) {
    final steps = ref.read(mapStepsProvider(widget.stepIds));
    if (index < 0 || index >= steps.length || steps[index].position == null)
      return;

    final step = steps[index];
    _mapController.move(
        LatLng(step.position!.latitude, step.position!.longitude), 18.0);

    ref.read(mapCurrentStepIndexProvider(_mapId).notifier).state = index;
  }

  void recenterMap() {
    final steps = ref.read(mapStepsProvider(widget.stepIds));
    if (steps.isNotEmpty && steps[0].position != null) {
      _mapController.move(
        LatLng(steps[0].position!.latitude, steps[0].position!.longitude),
        15.0,
      );
    }
  }

  // méthode recenterMap pour centrer sur tous les marqueurs
  void recenterMapAll() {
    final steps = ref.read(mapStepsProvider(widget.stepIds));
    if (steps.isEmpty) return;

    final bounds = LatLngBounds(
      LatLng(
        steps
            .map((m) => m.position!.latitude)
            .reduce((min, pos) => pos < min ? pos : min),
        steps
            .map((m) => m.position!.longitude)
            .reduce((min, pos) => pos < min ? pos : min),
      ),
      LatLng(
        steps
            .map((m) => m.position!.latitude)
            .reduce((max, pos) => pos > max ? pos : max),
        steps
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
    final steps = ref.read(mapStepsProvider(widget.stepIds));
    final index = steps.indexWhere((step) => step.id == stepId);
    if (index != -1) {
      ref.read(mapCurrentStepIndexProvider(_mapId).notifier).state = index;
      _zoomToStep(index);
    }
  }

  List<custom.Step> get steps => ref.read(mapStepsProvider(widget.stepIds));
  Color get categoryColor {
    // Utiliser la couleur fournie
    return widget.categoryColor;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(mapIsLoadingProvider(_mapId));
    final steps = ref.watch(mapStepsProvider(widget.stepIds));
    final currentStepIndex = ref.watch(mapCurrentStepIndexProvider(_mapId));

    return Container(
      height: widget.height,
      child: isLoading
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
                        if (steps.isNotEmpty) {
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
                    if (steps.isNotEmpty)
                      MarkerLayer(
                        markers: steps.asMap().entries.map((entry) {
                          final index = entry.key;
                          final step = entry.value;
                          final isSelected = index == currentStepIndex;

                          return Marker(
                            width: 40,
                            height: 40,
                            point: step.position!,
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(mapCurrentStepIndexProvider(_mapId)
                                        .notifier)
                                    .state = index;
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
                                      ? widget.categoryColor
                                      : widget.categoryColor
                                          .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ), // Marqueur de l'utilisateur (si pas d'étapes avec position)
                    if (steps.isEmpty && _hasUserLocation())
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: LatLng(
                              _getDefaultPosition()['latitude']!,
                              _getDefaultPosition()['longitude']!,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: widget.categoryColor,
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
                    if (steps.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: steps.map((s) => s.position!).toList(),
                            color: widget.categoryColor,
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
                      ref.read(mapHasCenteredProvider(_mapId).notifier).state =
                          false;
                      if (steps.isNotEmpty) {
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
                if (steps.isEmpty)
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
                            color: widget.categoryColor,
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
    final steps = ref.read(mapStepsProvider(widget.stepIds));
    if (steps.isNotEmpty && steps[0].position != null) {
      return steps[0].position!;
    }

    // Position par défaut (Paris)
    return const LatLng(48.8566, 2.3522);
  }

  // Méthode pour obtenir la position par défaut
  Map<String, double> _getDefaultPosition() {
    return {
      'latitude': 48.8566,
      'longitude': 2.3522,
    };
  }

  // Méthode pour vérifier si on a la position de l'utilisateur
  bool _hasUserLocation() {
    // Pour l'instant, on considère qu'on n'a pas la position utilisateur
    // Cette méthode peut être améliorée avec un provider de géolocalisation
    return false;
  }

  // Méthode pour centrer sur l'utilisateur ou position par défaut
  void _centerOnUserOrDefault() {
    final defaultPos = _getDefaultPosition();
    _mapController.move(
      LatLng(defaultPos['latitude']!, defaultPos['longitude']!),
      10.0, // Zoom par défaut
    );
  }
}
