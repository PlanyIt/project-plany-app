import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonColor { primary, secondary }

enum TextColor { light, dark }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonColor buttonColor;
  final TextColor textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonColor = ButtonColor.primary,
    this.textColor = TextColor.light,
  });

  Color _getButtonColor(BuildContext context) {
    switch (buttonColor) {
      case ButtonColor.primary:
        return Theme.of(context).primaryColor;
      case ButtonColor.secondary:
        return const Color.fromARGB(255, 225, 225, 225);
    }
  }

  Color _getTextColor() {
    switch (textColor) {
      case TextColor.light:
        return Colors.white;
      case TextColor.dark:
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
          _getButtonColor(context),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.leagueSpartan(
          textStyle: TextStyle(
            color: _getTextColor(),
            fontSize: 19,
          ),
        ),
      ),
    );
  }
}
