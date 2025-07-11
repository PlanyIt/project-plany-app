import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../view_models/search_view_model.dart';

class RangeInput extends StatefulWidget {
  final SearchViewModel viewModel;
  final TextEditingController minController;
  final TextEditingController maxController;
  final String minLabel;
  final String maxLabel;
  final String suffix;
  final Color color;
  final String fieldName;

  const RangeInput({
    super.key,
    required this.viewModel,
    required this.minController,
    required this.maxController,
    required this.minLabel,
    required this.maxLabel,
    required this.suffix,
    required this.color,
    this.fieldName = 'valeur',
  });

  @override
  State<RangeInput> createState() => _RangeInputState();
}

class _RangeInputState extends State<RangeInput> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final validationError = widget.viewModel.getFieldError(widget.fieldName);
        final hasError = validationError != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    context,
                    widget.minController,
                    widget.minLabel,
                    hasError,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 20,
                  height: 1,
                  color: hasError
                      ? Colors.red.withValues(alpha: 0.4)
                      : widget.color.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    context,
                    widget.maxController,
                    widget.maxLabel,
                    hasError,
                  ),
                ),
              ],
            ),
            if (hasError) ...[
              const SizedBox(height: 8),
              Text(
                validationError,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
    bool hasError,
  ) {
    final borderColor = hasError ? Colors.red : widget.color;

    return TextField(
      cursorColor: widget.color,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: widget.color),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          color: widget.color.withValues(alpha: 0.6),
        ),
        suffixText: widget.suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        fillColor: hasError
            ? Colors.red.withValues(alpha: 0.05)
            : widget.color.withValues(alpha: 0.05),
        filled: true,
        contentPadding: const EdgeInsets.all(16),
        suffixStyle: TextStyle(
          color: widget.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
       