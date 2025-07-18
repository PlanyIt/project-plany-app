import 'package:flutter/material.dart';

class DashboardSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool autofocus;

  const DashboardSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Rechercher des plans...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: readOnly
          ? _buildReadOnlySearchBar(context)
          : _buildEditableSearchBar(context),
    );
  }

  Widget _buildReadOnlySearchBar(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              color: primaryColor,
              size: 20,
            ),
          ),
        ),
        Expanded(
          child: Text(
            hintText,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildEditableSearchBar(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Icon(
          Icons.search,
          color: Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            focusNode: focusNode,
            onTap: onTap,
            autofocus: autofocus,
            readOnly: readOnly,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (controller != null && controller!.text.isNotEmpty)
          IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.grey.shade500,
              size: 18,
            ),
            onPressed: () {
              controller!.clear();
              if (onChanged != null) {
                onChanged!('');
              }
            },
          )
        else
          const SizedBox(width: 16),
      ],
    );
  }
}
