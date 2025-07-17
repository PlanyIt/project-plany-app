import 'dart:io';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';

import '../../domain/models/plan/plan.dart';

class CalendarService {
  static Future<void> addPlanToCalendar(
      BuildContext context, Plan? plan) async {
    if (plan == null) return;

    try {
      final start = DateTime.now().add(const Duration(days: 1));
      final end = start.add(const Duration(hours: 2));

      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.INSERT',
          data: 'content://com.android.calendar/events',
          arguments: {
            'title': 'Plany: ${plan.title}',
            'description': plan.description,
            'beginTime': start.millisecondsSinceEpoch,
            'endTime': end.millisecondsSinceEpoch,
            'eventLocation': 'Voir itinéraire dans l\'application Plany',
            'allDay': false,
          },
        );
        await intent.launch();
      } else {
        final event = Event(
          title: 'Plany: ${plan.title}',
          description: plan.description,
          location: 'Voir itinéraire dans l\'application Plany',
          startDate: start,
          endDate: end,
          allDay: false,
        );
        final success = await Add2Calendar.addEvent2Cal(event);
        if (!success) {
          throw Exception("Impossible d'ajouter l'événement");
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Événement ajouté au calendrier")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ajout au calendrier : $e")),
        );
      }
    }
  }
}
