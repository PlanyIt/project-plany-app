import 'package:flutter/material.dart';
import 'package:front/widgets/card/step_card.dart';
import 'package:timeline_tile/timeline_tile.dart';

class StepCardTimeline extends StatelessWidget {
  final int index;
  final bool isFirst;
  final bool isLast;
  final String title;
  final String description;
  final String? imagePath;
  final String? duration;
  final String? durationUnit;
  final double? cost;
  final String? locationName;
  final VoidCallback? onDelete;
  final Color? themeColor;

  const StepCardTimeline({
    super.key,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.title,
    required this.description,
    this.imagePath,
    this.duration,
    this.durationUnit,
    this.cost,
    this.locationName,
    this.onDelete,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = themeColor ?? Theme.of(context).primaryColor;

    return TimelineTile(
      key: Key('plan_step_$index'),
      isFirst: isFirst,
      isLast: isLast,
      alignment: TimelineAlign.manual,
      lineXY: 0.1,
      indicatorStyle: IndicatorStyle(
        width: 28,
        height: 28,
        indicator: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
      beforeLineStyle: LineStyle(
        color: color.withOpacity(0.4),
        thickness: 2,
      ),
      afterLineStyle: LineStyle(
        color: color.withOpacity(0.4),
        thickness: 2,
      ),
      endChild: Container(
        padding: const EdgeInsets.only(left: 12, bottom: 16),
        child: StepCard(
          title: title,
          description: description,
          imageUrl: imagePath ?? '',
          duration: duration,
          durationUnit: durationUnit,
          cost: cost,
          locationName: locationName,
          onDelete: onDelete,
          themeColor: themeColor,
          location: null,
        ),
      ),
      startChild: null,
    );
  }
}
