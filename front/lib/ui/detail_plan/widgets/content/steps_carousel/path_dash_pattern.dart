import 'package:flutter/material.dart';

class PathDashPattern {
  final double dashWidth;
  final double dashSpace;
  
  PathDashPattern(this.dashWidth, this.dashSpace);
  
  Path dashPath(Path source) {
    final Path dest = Path();
    final pathMetrics = source.computeMetrics();
    
    for (final metric in pathMetrics) {
      var distance = 0.0;
      var draw = true;
      
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + dashWidth),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    
    return dest;
  }
}