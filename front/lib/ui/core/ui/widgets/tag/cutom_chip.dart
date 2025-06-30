import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Function? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final IconData? icon;
  final bool isSelected;
  final bool showCloseIcon;
  final dynamic item;

  const CustomChip({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.padding,
    this.elevation = 0,
    this.icon,
    this.isSelected = false,
    this.showCloseIcon = false,
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = isSelected
        ? theme.primaryColor
        : theme.primaryColor.withValues(alpha: 0.1);
    final textColorValue = isSelected ? Colors.white : theme.primaryColor;

    return InkWell(
      onTap: onTap as void Function()?,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? chipColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor ??
                (isSelected
                    ? theme.primaryColor
                    : theme.primaryColor.withValues(alpha: 0.3)),
          ),
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: elevation * 2,
                    spreadRadius: elevation / 2,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: textColorValue,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor ?? textColorValue,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (showCloseIcon) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 16,
                color: textColorValue,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
