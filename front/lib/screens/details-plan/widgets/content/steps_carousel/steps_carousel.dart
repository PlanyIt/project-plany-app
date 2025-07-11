import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/step/step.dart' as plan_steps;
import '../../../../../utils/helpers.dart';
import 'step_detail_card.dart';
import 'vertical_flight_path_painter.dart';

class StepsCarousel extends StatefulWidget {
  final List<plan_steps.Step>? steps;
  final Color categoryColor;

  const StepsCarousel({
    super.key,
    required this.steps,
    this.categoryColor = const Color(0xFF3425B5),
  });

  @override
  StepsCarouselState createState() => StepsCarouselState();
}

class StepsCarouselState extends State<StepsCarousel>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  int _currentStepIndex = 0;
  List<plan_steps.Step>? _loadedSteps;
  Color? _effectiveColor;

  // Animation de l'avion
  AnimationController? _flightController;
  double _flightPosition = 0.0;

  final Map<int, double> _distancesBetweenSteps = {};

  @override
  void initState() {
    super.initState();

    // Stockage de la couleur dans une variable d'état
    _effectiveColor = widget.categoryColor;

    _scrollController.addListener(_onScroll);

    // Initialiser le controller d'animation
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _flightController!.addListener(() {
      setState(() {
        _flightPosition = _flightController!.value;
      });
    });

    if (widget.steps != null && widget.steps!.isNotEmpty) {
      _calculateDistances();
    }
  }

  @override
  void didUpdateWidget(StepsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryColor != oldWidget.categoryColor) {
      setState(() {
        _effectiveColor = widget.categoryColor;
      });
    }

    // Recalculer les distances si les étapes changent
    if (widget.steps != oldWidget.steps) {
      _calculateDistances();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _flightController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final stepHeight = 250.0;
      final offset = _scrollController.offset;
      final index = (offset / stepHeight).floor();
      final progress = (offset - (index * stepHeight)) / stepHeight;
      final safeIndex = index.clamp(
          0, (widget.steps?.length ?? _loadedSteps?.length ?? 1) - 1);

      if (safeIndex != _currentStepIndex || progress != _flightPosition) {
        setState(() {
          _currentStepIndex = safeIndex;
          _flightPosition = progress.clamp(0.0, 1.0);
        });
      }
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      height: 120,
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildStepCard(plan_steps.Step step, int index) {
    final isActive = index == _currentStepIndex;
    final actualColor = _effectiveColor ?? widget.categoryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: 36,
                height: 250,
                child: index <
                        (widget.steps?.length ?? _loadedSteps?.length ?? 0) - 1
                    ? CustomPaint(
                        painter: VerticalFlightPathPainter(
                          progress: _flightPosition,
                          isActive: isActive,
                          color: actualColor,
                        ),
                      )
                    : null,
              ),

              // Colonne avec cercle numéroté et badge de distance
              Column(
                children: [
                  // Cercle avec numéro
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive ? actualColor : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${step.order}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  if (index <
                          (widget.steps?.length ?? _loadedSteps?.length ?? 0) -
                              1 &&
                      _distancesBetweenSteps.containsKey(index) &&
                      _distancesBetweenSteps[index]! > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: actualColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                            color: actualColor.withValues(alpha: 0.3),
                            width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 12,
                            color: actualColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${_distancesBetweenSteps[index]!.toStringAsFixed(1)} km",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: actualColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (index ==
                      (widget.steps?.length ?? _loadedSteps?.length ?? 0) - 1)
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: actualColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                            color: actualColor.withValues(alpha: 0.3),
                            width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 12,
                            color: actualColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "Point final",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: actualColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 28),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image de l'étape
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: step.image.isNotEmpty
                      ? Image.network(
                          step.image,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
                const SizedBox(height: 12),

                // Titre et description
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Badges d'info (durée, coût)
                Row(
                  children: [
                    if (step.duration != null)
                      _buildInfoBadge(
                          Icons.access_time_rounded,
                          formatDurationToString(step.duration ?? 0),
                          actualColor),
                    if (step.duration != null && step.cost != null)
                      const SizedBox(width: 10),
                    if (step.cost != null)
                      _buildInfoBadge(
                          Icons.euro_rounded, "${step.cost} €", actualColor),
                  ],
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: actualColor.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                          color: actualColor.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            _showStepDetails(context, step, actualColor),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Voir plus",
                                style: TextStyle(
                                  color: actualColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  color: actualColor, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: badgeColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Vérifier si les coordonnées sont valides
    if (lat1.isNaN ||
        lon1.isNaN ||
        lat2.isNaN ||
        lon2.isNaN ||
        lat1.isInfinite ||
        lon1.isInfinite ||
        lat2.isInfinite ||
        lon2.isInfinite) {
      return 0.0; // Retourner une valeur par défaut
    }

    const double earthRadius = 6371; // Rayon de la Terre en kilomètres

    try {
      // Conversion des degrés en radians
      final latRad1 = lat1 * math.pi / 180;
      final lonRad1 = lon1 * math.pi / 180;
      final latRad2 = lat2 * math.pi / 180;
      final lonRad2 = lon2 * math.pi / 180;

      // Formule de Haversine
      final dLat = latRad2 - latRad1;
      final dLon = lonRad2 - lonRad1;
      final a = math.pow(math.sin(dLat / 2), 2) +
          math.cos(latRad1) *
              math.cos(latRad2) *
              math.pow(math.sin(dLon / 2), 2);

      // Éviter les divisions par zéro ou racines négatives
      if (a.isNaN || a < 0) return 0.0;

      final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      final distance = earthRadius * c;

      return distance.isFinite ? distance : 0.0;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur dans le calcul de distance: $e');
      }
      return 0.0;
    }
  }

  void _calculateDistances() {
    final steps = widget.steps ?? _loadedSteps;
    if (steps == null || steps.length < 2) return;

    for (var i = 0; i < steps.length - 1; i++) {
      final currentStep = steps[i];
      final nextStep = steps[i + 1];

      try {
        // Vérifier si les positions existent
        if (currentStep.latitude != null &&
            currentStep.longitude != null &&
            nextStep.latitude != null &&
            nextStep.longitude != null) {
          final distance = _calculateDistance(
            currentStep.latitude!,
            currentStep.longitude!,
            nextStep.latitude!,
            nextStep.longitude!,
          );

          // Ne stocker que les distances valides
          if (distance > 0) {
            _distancesBetweenSteps[i] = distance;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors du calcul de distance entre étapes: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps ?? _loadedSteps;

    if (steps == null || steps.isEmpty) {
      return Container(
        height: 400,
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            "Aucune étape disponible",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 20),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return _buildStepCard(steps[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStepDetails(
      BuildContext context, plan_steps.Step step, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StepDetailCard(step: step, color: color),
    );
  }
}
