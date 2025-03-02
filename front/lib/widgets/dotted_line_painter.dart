import 'dart:ui';

import 'package:flutter/material.dart';

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashLength;
  final double dashGap;
  final double strokeWidth;

  DottedLinePainter({
    required this.color,
    this.dashLength = 3.0,
    this.dashGap = 3.0,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Utiliser un style de peinture consistent
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // La position verticale courante
    double currentY = 0;

    // Dessiner des tirets jusqu'à atteindre la hauteur totale
    while (currentY < size.height) {
      // Calculer la longueur du tiret actuel
      double dashEnd = currentY + dashLength;
      // S'assurer que nous ne dépassons pas la hauteur
      if (dashEnd > size.height) dashEnd = size.height;

      // Dessiner le tiret
      canvas.drawLine(
        Offset(size.width / 2, currentY),
        Offset(size.width / 2, dashEnd),
        paint,
      );

      // Passer à la position après l'espace
      currentY = dashEnd + dashGap;
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
