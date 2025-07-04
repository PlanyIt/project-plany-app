import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/textfield/custom_text_field.dart';

class RangeInput extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final String minLabel;
  final String maxLabel;
  final String suffix;
  final Color color;
  final Function(String) onMinChanged;
  final Function(String) onMaxChanged;

  const RangeInput({
    super.key,
    required this.minController,
    required this.maxController,
    required this.minLabel,
    required this.maxLabel,
    required this.suffix,
    required this.color,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: minController,
            labelText: minLabel,
            keyboardType: TextInputType.number,
            onTextFieldTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 20,
          height: 1,
          color: Colors.grey[400],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextField(
            controller: maxController,
            labelText: maxLabel,
            keyboardType: TextInputType.number,
            onTextFieldTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ),
      ],
    );
  }
}
