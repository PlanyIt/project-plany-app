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
  final bool isLoading;

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
    this.isLoading = false, // Default to false
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
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        style: ElevatedButton.styleFrom(
          foregroundColor: fgColor,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: fgColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
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
