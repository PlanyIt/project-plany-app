import 'package:flutter/material.dart';
import 'package:front/ui/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanyLogo extends StatelessWidget {
  final double fontSize;
  final bool bounceDot;
  final double dotOffset; // hauteur du rebond du point

  const PlanyLogo({
    super.key,
    this.fontSize = 50,
    this.bounceDot = false,
    this.dotOffset = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (!bounceDot) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plany',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.leagueSpartan().fontFamily,
            ),
          ),
          Text(
            '.',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.leagueSpartan().fontFamily,
            ),
          ),
        ],
      );
    } else {
      // Pour la version animée, à utiliser dans un StatefulWidget avec AnimationController
      return _AnimatedPlanyLogo(fontSize: fontSize, dotOffset: dotOffset);
    }
  }
}

class _AnimatedPlanyLogo extends StatefulWidget {
  final double fontSize;
  final double dotOffset;

  const _AnimatedPlanyLogo({required this.fontSize, required this.dotOffset});

  @override
  State<_AnimatedPlanyLogo> createState() => _AnimatedPlanyLogoState();
}

class _AnimatedPlanyLogoState extends State<_AnimatedPlanyLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _dotAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.bounceOut))
        .animate(_dotController);

    _dotController.forward();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plany',
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.leagueSpartan().fontFamily,
          ),
        ),
        AnimatedBuilder(
          animation: _dotAnimation,
          builder: (context, child) {
            final double translateY =
                -widget.dotOffset * (1 - _dotAnimation.value);
            return Transform.translate(
              offset: Offset(0, translateY),
              child: child,
            );
          },
          child: Text(
            '.',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.leagueSpartan().fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
