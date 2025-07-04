import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const SelectButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) Icon(leadingIcon, color: Colors.black),
          if (leadingIcon != null) const SizedBox(width: 18),
          Text(
            text,
            style: GoogleFonts.leagueSpartan(
              textStyle: const TextStyle(fontSize: 19, color: Colors.black),
            ),
          ),
          if (trailingIcon != null) const SizedBox(width: 18),
          if (trailingIcon != null) Icon(trailingIcon, color: Colors.black),
        ],
      ),
    );
  }
}
