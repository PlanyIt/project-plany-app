import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final double paddingBottom;
  final double paddingLeft;
  final double fontSize;
  final FontWeight fontWeight;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.paddingBottom = 10.0,
    this.paddingLeft = 8.0,
    this.fontSize = 18.0,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom, left: paddingLeft),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
