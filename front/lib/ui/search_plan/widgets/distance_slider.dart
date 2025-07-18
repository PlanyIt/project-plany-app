import 'package:flutter/material.dart';

import '../../../utils/helpers.dart';

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
    final currentValues = values != null
        ? RangeValues(values!.start / 1000, values!.end / 1000)
        : const RangeValues(0, 10);

    return Column(
      children: [
        RangeSlider(
          values: currentValues,
          min: 0,
          max: 50,
          divisions: 200,
          activeColor: Colors.blue,
          labels: RangeLabels(
            formatDistance(currentValues.start * 1000),
            formatDistance(currentValues.end * 1000),
          ),
          onChanged: (values) {
            onChanged(RangeValues(values.start * 1000, values.end * 1000));
          },
        ),
        Row(
          children: [
            Text(
              formatDistance(currentValues.start * 1000),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              formatDistance(currentValues.end * 1000),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
