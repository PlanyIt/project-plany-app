import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final int maxLines;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final Function(bool)? onFocusChange;
  final VoidCallback? onTextFieldTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.onFocusChange,
    this.onTextFieldTap,
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
    return GestureDetector(
      onTap: widget.onTextFieldTap,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          labelText: widget.labelText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
