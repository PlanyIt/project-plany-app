import 'package:flutter/material.dart';
import 'package:front/ui/core/ui/widgets/tag/cutom_chip.dart';

class ChipList<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) labelBuilder;
  final Function(T) onDeleted;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final double runSpacing;
  final Widget Function(T)? avatarBuilder;
  final IconData? icon;

  const ChipList({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.onDeleted,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.labelStyle,
    this.padding,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.avatarBuilder,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map<Widget>((item) {
        return CustomChip(
          label: labelBuilder(item),
          onTap: () => onDeleted(item),
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          textColor: textColor,
          padding: padding,
          icon: icon,
          item: item,
          isSelected: true,
          showCloseIcon: true,
        );
      }).toList(),
    );
  }
}
