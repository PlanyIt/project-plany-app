import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final double? iconSize;
  final double? fontSize;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(themeColor),
          const SizedBox(width: 4),
          _buildLabel(themeColor),
        ],
      ),
    );
  }

  Widget _buildIcon(Color themeColor) {
    return Icon(
      icon,
      size: iconSize ?? 12,
      color: themeColor,
    );
  }

  Widget _buildLabel(Color themeColor) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize ?? 11,
        fontWeight: FontWeight.w500,
        color: themeColor,
      ),
    );
  }
}
