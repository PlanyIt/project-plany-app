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
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // Use the provided focusNode or create a new one
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.onFocusChange != null) {
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      // If the focus node has changed, update listeners
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
    // Only dispose the focus node if we created it internally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else if (widget.onFocusChange != null) {
      // Otherwise just remove our listener
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
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Use a ConstrainedBox to limit the height and avoid overflow
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 56.0,
          maxHeight: 150.0, // Maximum height for multiline fields
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
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
          ),
          obscureText: widget.obscureText,
          // Use TextInputAction.done for the last field
          textInputAction: TextInputAction.done,
          // Enable scrolling for multiline text fields
          maxLines: widget.obscureText ? 1 : null,
        ),
      ),
    );
  }
}
