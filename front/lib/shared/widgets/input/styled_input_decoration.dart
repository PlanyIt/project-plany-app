import 'package:flutter/material.dart';

class StyledInputDecoration {
  static InputDecoration get({
    required String label,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
    Color? borderColor,
    Color? focusedBorderColor,
    Color? fillColor,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  }) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor ?? Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor ?? Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: focusedBorderColor ?? const Color(0xFF3425B5),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: fillColor ?? Colors.grey[50],
      contentPadding: contentPadding,
    );
  }
}
