import 'package:flutter/material.dart';

class DistanceSlider extends StatelessWidget {
  final RangeValues? values;
  final Function(RangeValues) onChanged;

  const DistanceSlider({
    super.key,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentValues = values ?? const RangeValues(0, 10000);

    return Column(
      children: [
        RangeSlider(
          values: currentValues,
          min: 0,
          max: 50000,
          divisions: 50,
          activeColor: Colors.blue,
          labels: RangeLabels(
            '${currentValues.start.toInt()}m',
            '${currentValues.end.toInt()}m',
          ),
          onChanged: onChanged,
        ),
        Row(
          children: [
            Text(
              '${currentValues.start.toInt()}m',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${currentValues.end.toInt()}m',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
