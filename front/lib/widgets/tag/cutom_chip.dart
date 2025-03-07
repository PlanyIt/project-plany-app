import 'package:flutter/material.dart';

class CustomChip<T> extends StatelessWidget {
  final T item;
  final String label;
  final Function(T) onDeleted;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? deleteIconColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final Widget? avatar;

  const CustomChip({
    super.key,
    required this.item,
    required this.label,
    required this.onDeleted,
    this.backgroundColor,
    this.borderColor,
    this.deleteIconColor,
    this.labelStyle,
    this.padding,
    this.elevation = 0,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(label),
      labelStyle: labelStyle ?? const TextStyle(fontWeight: FontWeight.w500),
      backgroundColor: backgroundColor ?? theme.primaryColor.withOpacity(0.1),
      side: BorderSide(
        color: borderColor ?? theme.primaryColor.withOpacity(0.3),
      ),
      deleteIconColor: deleteIconColor ?? theme.primaryColor,
      onDeleted: () => onDeleted(item),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      elevation: elevation,
      avatar: avatar,
    );
  }
}
