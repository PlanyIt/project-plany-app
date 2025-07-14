import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final VoidCallback? onSuffixIconPressed;
  final FocusNode? focusNode;
  final Function(bool)? onFocusChange;
  final String? errorText; // Ajouté ici

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onSuffixIconPressed,
    this.focusNode,
    this.onFocusChange,
    this.errorText, // Ajouté ici
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.onFocusChange != null) {
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.onFocusChange != null) {
        _focusNode.removeListener(_handleFocusChange);
      }
      _focusNode = widget.focusNode ?? _focusNode;
      if (widget.onFocusChange != null) {
        _focusNode.addListener(_handleFocusChange);
      }
    }
  }

  void _handleFocusChange() {
    if (widget.onFocusChange != null) {
      widget.onFocusChange!(_focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else if (widget.onFocusChange != null) {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 56.0,
          maxHeight: 150.0,
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: Theme.of(context).primaryColor)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(widget.suffixIcon, color: Colors.grey),
                    onPressed: widget.onSuffixIconPressed,
                  )
                : null,
            errorText: widget.errorText, // Ajouté ici pour l'erreur
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
          ),
          obscureText: widget.obscureText,
          textInputAction: TextInputAction.done,
          maxLines: widget.obscureText ? 1 : null,
        ),
      ),
    );
  }
}
