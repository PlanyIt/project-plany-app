import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonColor { primary, secondary }

enum TextColor { light, dark }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonColor buttonColor;
  final TextColor textColor;
  final IconData? leadingIcon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonColor = ButtonColor.primary,
    this.textColor = TextColor.light,
    this.leadingIcon,
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
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          _getButtonColor(context),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Increased radius for modern look
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              color: _getTextColor(),
              size: 18,
            ),
            const SizedBox(width: 12),
          ],
          Text(
            text,
            style: GoogleFonts.leagueSpartan(
              textStyle: TextStyle(
                color: _getTextColor(),
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
