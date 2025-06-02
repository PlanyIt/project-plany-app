import 'package:flutter/material.dart';
import 'package:front/theme/app_theme.dart';

class PlanyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool filled;
  final Color? color;
  final Color? textColor;
  final double fontSize;
  final double height;
  final double borderRadius;

  const PlanyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.filled = true,
    this.color,
    this.textColor,
    this.fontSize = 16,
    this.height = 56,
    this.borderRadius = AppTheme.radiusXL,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        color ?? (filled ? Theme.of(context).primaryColor : Colors.white);
    final Color fgColor =
        textColor ?? (filled ? Colors.white : Theme.of(context).primaryColor);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: fgColor,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: fgColor,
          ),
        ),
      ),
    );
  }
}
