import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider pour l'état de pression du bouton
final buttonPressStateProvider =
    StateProvider.family<bool, String>((ref, buttonId) => false);

class GlassButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;
  final double? blur;
  final double? spread;
  final double? height;
  final double? width;
  final String? buttonId; // Identifiant unique pour le bouton

  const GlassButton({
    Key? key,
    required this.child,
    this.onTap,
    this.color,
    this.borderRadius,
    this.blur,
    this.spread,
    this.height,
    this.width,
    this.buttonId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniqueId = buttonId ?? hashCode.toString();
    final isPressed = ref.watch(buttonPressStateProvider(uniqueId));

    return GestureDetector(
      onTapDown: (_) {
        ref.read(buttonPressStateProvider(uniqueId).notifier).state = true;
      },
      onTapUp: (_) {
        ref.read(buttonPressStateProvider(uniqueId).notifier).state = false;
      },
      onTapCancel: () {
        ref.read(buttonPressStateProvider(uniqueId).notifier).state = false;
      },
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height ?? 50,
        width: width ?? 150,
        transform: Matrix4.identity()..scale(isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: (color?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1))
              .withOpacity(isPressed ? 0.8 : 1.0),
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isPressed ? 0.1 : 0.2),
              blurRadius: blur ?? 10,
              spreadRadius: spread ?? 2,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
