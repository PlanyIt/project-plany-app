import 'package:flutter/material.dart';
import 'path_dash_pattern.dart';

class VerticalFlightPathPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final Color color;
  final bool showDistance;
  final double distance;
  
  VerticalFlightPathPainter({
    required this.progress,
    this.isActive = false,
    this.color = const Color(0xFF3425B5),
    this.showDistance = false,
    this.distance = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Points de référence
    final startX = 18.0;
    final startY = 36.0;
    
    final targetY = 270.0; // Utiliser la hauteur totale du SizedBox
    
    final dashPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    // Tracer le chemin de la ligne pointillée qui va plus loin
    final path = Path();
    path.moveTo(startX, startY);
    path.lineTo(startX, startY + (targetY * progress * 1.1));
    
    // Position exacte de l'avion - également ajustée
    final planeY = startY + (targetY * progress * 1.1);
    
    try {
      // Dessiner la ligne pointillée
      final pathMetrics = path.computeMetrics().first;
      final pathLength = pathMetrics.length;
      final extractPath = pathMetrics.extractPath(0, pathLength);
      
      final dashWidth = 5.0;
      final dashSpace = 5.0;
      final dash = PathDashPattern(dashWidth, dashSpace);
      final dashPath = dash.dashPath(extractPath);
      
      canvas.drawPath(dashPath, dashPaint);
      
      // Dessiner l'avion à la position calculée
      final avionPaint = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      final avionPath = Path();
      final avionSize = 9.0;
      
      avionPath.moveTo(startX, planeY + avionSize);
      avionPath.lineTo(startX - avionSize/1.5, planeY);
      avionPath.lineTo(startX, planeY + avionSize/3);
      avionPath.lineTo(startX + avionSize/1.5, planeY);
      avionPath.close();
      
      canvas.drawPath(avionPath, avionPaint);
      
      // Contour blanc de l'avion
      final contourPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawPath(avionPath, contourPaint);
    } catch (e) {
      // Fallback simple en cas d'erreur
      canvas.drawLine(
        Offset(startX, startY), 
        Offset(startX, planeY),
        dashPaint
      );
    }
    
    // Dessiner la distance si nécessaire
    if (showDistance && distance > 0) {
      // Contenu du texte de distance
      final distanceText = "${distance.toStringAsFixed(1)} km";
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(text: distanceText, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      
      // Dimensions du badge
      final textWidth = textPainter.width;
      final textHeight = textPainter.height;
      final badgePadding = 8.0;
      final badgeHeight = textHeight + badgePadding;
      final badgeWidth = textWidth + badgePadding * 2 + 16;
      
      // Position du badge - légèrement décalé vers la droite pour éviter la coupure
      final badgeX = startX + 2; 
      final badgeY = planeY - badgeHeight - 15;
      
      // Fond avec dégradé
      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(badgeX, badgeY, badgeWidth, badgeHeight),
        Radius.circular(badgeHeight / 2), // Coins parfaitement arrondis
      );
      
      // Créer un dégradé
      final gradient = LinearGradient(
        colors: [
          color,
          color.withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      
      // Dessiner l'ombre du badge
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(badgeX + 1, badgeY + 1, badgeWidth, badgeHeight),
          Radius.circular(badgeHeight / 2),
        ),
        shadowPaint,
      );
      
      // Dessiner le badge avec dégradé
      final badgePaint = Paint()
        ..shader = gradient.createShader(badgeRect.outerRect);
      canvas.drawRRect(badgeRect, badgePaint);
      
      // Bordure légère
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawRRect(badgeRect, borderPaint);
      
      // Position de l'icône
      final iconX = badgeX + badgePadding + 4;
      final iconY = badgeY + badgeHeight / 2;
      
      // Dessiner une simple icône de marcheur
      final walkIcon = Path();
      // Tête
      walkIcon.addOval(Rect.fromCircle(center: Offset(iconX, iconY - 3), radius: 1.5));
      // Corps et jambes
      walkIcon.moveTo(iconX, iconY - 1.5);
      walkIcon.lineTo(iconX, iconY + 1);
      walkIcon.lineTo(iconX + 3, iconY + 3);
      walkIcon.moveTo(iconX, iconY + 1);
      walkIcon.lineTo(iconX - 3, iconY + 3);
      // Bras
      walkIcon.moveTo(iconX, iconY - 0.5);
      walkIcon.lineTo(iconX + 2.5, iconY - 2);
      final walkIconStrokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(walkIcon, walkIconStrokePaint);
      
      // Dessiner le texte
      textPainter.paint(canvas, Offset(iconX + 8, badgeY + badgePadding / 2));
    }
  }
  
  @override
  bool shouldRepaint(VerticalFlightPathPainter oldDelegate) => 
      oldDelegate.progress != progress || 
      oldDelegate.isActive != isActive ||
      oldDelegate.color != color;
}