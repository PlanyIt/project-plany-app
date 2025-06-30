import 'package:flutter/material.dart';
import 'package:front/domain/models/step/step.dart' as custom;
import 'package:front/data/services/navigation_service.dart';
import 'package:front/utils/helpers.dart';
import 'package:geolocator/geolocator.dart';

class StepInfoCard extends StatefulWidget {
  final custom.Step step;
  final Color color;
  final VoidCallback onClose;

  const StepInfoCard({
    super.key,
    required this.step,
    this.color = Colors.deepPurpleAccent,
    required this.onClose,
    String? category,
    double? distance,
  });

  @override
  StepInfoCardState createState() => StepInfoCardState();
}

class StepInfoCardState extends State<StepInfoCard> {
  double? _distance;
  bool _isCalculatingDistance = false;

  @override
  void initState() {
    super.initState();
    _calculateDistanceToStep();
  }

  @override
  void didUpdateWidget(StepInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _calculateDistanceToStep();
    }
  }

  Future<void> _calculateDistanceToStep() async {
    if (latLngFromDoubles(widget.step.latitude, widget.step.longitude) ==
        null) {
      return;
    }

    setState(() {
      _isCalculatingDistance = true;
    });

    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition();

      // Calculer la distance en mètres
      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.step.latitude!,
        widget.step.longitude!,
      );

      // Convertir en km
      final distanceInKm = distanceInMeters / 1000;

      if (mounted) {
        setState(() {
          _distance = distanceInKm;
          _isCalculatingDistance = false;
        });
      }
    } catch (e) {
      print("Erreur lors du calcul de la distance: $e");
      if (mounted) {
        setState(() {
          _isCalculatingDistance = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth - 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Indicateur coloré
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(4),
              ),
              margin: const EdgeInsets.only(right: 8),
            ),

            // Informations principales (titre et détails)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.step.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Informations avec coût, durée et distance
                  Wrap(
                    spacing: 12,
                    children: [
                      // Coût
                      if (widget.step.cost != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.euro,
                                size: 14,
                                color: widget.color.withValues(alpha: 0.7)),
                            const SizedBox(width: 2),
                            Text(
                              "${widget.step.cost}€",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ),

                      // Durée
                      if (_getDuration() != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule,
                                size: 14,
                                color: widget.color.withValues(alpha: 0.7)),
                            const SizedBox(width: 2),
                            Text(
                              _getDuration()!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ),

                      // Distance
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place,
                              size: 14,
                              color: widget.color.withValues(alpha: 0.7)),
                          const SizedBox(width: 2),
                          _isCalculatingDistance
                              ? SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: widget.color,
                                  ),
                                )
                              : Text(
                                  _distance != null
                                      ? "${_distance!.toStringAsFixed(1)} km"
                                      : "Distance inconnue",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[700]),
                                ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Colonne de boutons alignés verticalement
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouton itinéraire
                InkWell(
                  onTap: () =>
                      NavigationService.navigateToStep(context, widget.step),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Bouton fermer
                InkWell(
                  onTap: widget.onClose,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[800],
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour extraire la durée du step ou utiliser une valeur par défaut
  String? _getDuration() {
    if (widget.step.duration != null) {
      return "${widget.step.duration}";
    }
    try {
      if ((widget.step as dynamic).timeEstimate != null) {
        return "${(widget.step as dynamic).timeEstimate}";
      }
    } catch (e) {
      print("Error: $e");
    }

    return "~30 min";
  }
}
