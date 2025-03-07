import 'package:flutter/material.dart';
import 'package:front/widgets/tag/cutom_chip.dart';

class ChipList<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) labelBuilder;
  final Function(T) onDeleted;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? deleteIconColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final double runSpacing;
  final Widget Function(T)? avatarBuilder;

  const ChipList({
    Key? key,
    required this.items,
    required this.labelBuilder,
    required this.onDeleted,
    this.backgroundColor,
    this.borderColor,
    this.deleteIconColor,
    this.labelStyle,
    this.padding,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.avatarBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map((item) {
        return CustomChip<T>(
          item: item,
          label: labelBuilder(item),
          onDeleted: onDeleted,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          deleteIconColor: deleteIconColor,
          labelStyle: labelStyle,
          padding: padding,
          avatar: avatarBuilder != null ? avatarBuilder!(item) : null,
        );
      }).toList(),
    );
  }
}
