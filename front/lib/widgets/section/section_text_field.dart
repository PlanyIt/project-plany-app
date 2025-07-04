import 'package:flutter/material.dart';
import 'package:front/widgets/textfield/custom_text_field.dart';

class SectionTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String labelText;
  final int maxLines;

  const SectionTextField({
    super.key,
    required this.title,
    required this.controller,
    required this.labelText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CustomTextField(
          controller: controller,
          labelText: labelText,
          maxLines: maxLines,
        ),
      ],
    );
  }
}
