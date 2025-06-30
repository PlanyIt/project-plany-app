import 'package:flutter/material.dart';

class AnimatedPageTransition extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const AnimatedPageTransition({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Animation plus élaborée avec plusieurs transformations combinées
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0.05),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
            reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeInCubic),
          ),
        );

        final fadeAnimation = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
          ),
        );

        // Ajout d'une animation de scale pour un effet plus dynamique
        final scaleAnimation = Tween<double>(
          begin: 1.0,
          end: 0.98,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: this.child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
