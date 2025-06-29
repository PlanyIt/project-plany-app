import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/providers/ui/ui_providers.dart';

class CustomTextField extends ConsumerStatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool isPassword;
  final bool isReadOnly;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.isPassword = false,
    this.isReadOnly = false,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  ConsumerState<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends ConsumerState<CustomTextField>
    with StateManagementMixin {
  @override
  String get widgetKey => '${widget.hashCode}_password_field';

  void _togglePasswordVisibility() {
    togglePasswordVisibility(ref, widgetKey);
  }

  @override
  Widget build(BuildContext context) {
    final obscureText =
        widget.isPassword ? getPasswordVisibility(ref, widgetKey) : false;

    return TextFormField(
      controller: widget.controller,
      readOnly: widget.isReadOnly,
      obscureText: obscureText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.placeholder,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
    );
  }
}
