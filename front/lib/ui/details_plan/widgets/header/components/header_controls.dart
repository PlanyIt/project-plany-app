import 'dart:io';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:front/domain/models/step/step.dart' as custom;
import 'package:front/data/services/navigation_service.dart';

class HeaderControls extends StatelessWidget {
  final Color categoryColor;
  final VoidCallback onCenterMap;
  final List<custom.Step> steps;
  final String? planTitle;
  final String? planDescription;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const HeaderControls({
    super.key,
    required this.categoryColor,
    required this.onCenterMap,
    required this.steps,
    this.planTitle,
    this.planDescription,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        showBackButton
            ? _buildGlassIconButton(
                icon: Icons.arrow_back,
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : const SizedBox(width: 50),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGlassIconButton(
              icon: Icons.my_location,
              onPressed: onCenterMap,
            ),
            const SizedBox(width: 8),
            _buildGlassIconButton(
              icon: Icons.directions,
              onPressed: () => _openDirections(context),
            ),
            const SizedBox(width: 8),
            _buildGlassIconButton(
              icon: Icons.calendar_today,
              onPressed: () => _addToCalendar(context),
            ),
          ],
        ),
      ],
    );
  }

  void _openDirections(BuildContext context) {
    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Aucune étape disponible pour la navigation")));
      return;
    }

    final validSteps = steps.where((step) => step.position != null).toList();

    if (validSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Aucune étape avec des coordonnées valides")));
      return;
    }

    NavigationService.navigateToStep(context, validSteps.first);
  }

  Future<void> _addToCalendar(BuildContext context) async {
    try {
      final eventTitle = planTitle ?? "Événement Plany";
      final eventDescription = planDescription ?? "Description non fournie";

      final startTimeMillis =
          DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;
      final endTimeMillis = DateTime.now()
          .add(const Duration(days: 1, hours: 2))
          .millisecondsSinceEpoch;

      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.INSERT',
          data: 'content://com.android.calendar/events',
          arguments: <String, dynamic>{
            'title': 'Plany: $eventTitle',
            'description': eventDescription,
            'beginTime': startTimeMillis,
            'endTime': endTimeMillis,
            'eventLocation': 'Voir itinéraire dans l\'application Plany',
            'allDay': false
          },
        );
        await intent.launch();
      } else {
        //TODO tester
        // Implémentation iOS avec add_2_calendar
        final Event event = Event(
          title: 'Plany: $eventTitle',
          description: eventDescription,
          location: 'Voir itinéraire dans l\'application Plany',
          startDate: DateTime.now().add(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
          allDay: false,
        );

        final result = await Add2Calendar.addEvent2Cal(event);

        if (!result) {
          throw Exception("Impossible d'ajouter l'événement au calendrier");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Événement ajouté au calendrier")));
        }
      }
    } catch (e) {
      print("Erreur détaillée pour le calendrier: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout au calendrier: $e')));
    }
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onPressed,
        splashColor: Colors.white.withValues(alpha: 0.15),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: categoryColor,
            size: 24,
            shadows: const [
              Shadow(
                  color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
            ],
          ),
        ),
      ),
    );
  }
}
