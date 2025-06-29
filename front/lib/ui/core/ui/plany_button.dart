import 'package:flutter/material.dart';
import 'package:front/theme/app_theme.dart';

class PlanyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool isLoading;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const PlanyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.isLoading = false,
    this.textColor,
    this.borderRadius = 12.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppTheme.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        disabledBackgroundColor:
            (color ?? AppTheme.primaryColor).withValues(alpha: 0.7),
      ),
      child: isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(textColor ?? Colors.white),
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textColor ?? Colors.white,
              ),
            ),
    );
  }
}
