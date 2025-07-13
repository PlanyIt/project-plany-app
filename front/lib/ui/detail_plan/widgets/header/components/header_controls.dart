import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../view_models/plan_details_viewmodel.dart';

class HeaderControls extends StatelessWidget {
  final Color categoryColor;
  final VoidCallback onCenterMap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PlanDetailsViewModel viewModel;

  const HeaderControls({
    super.key,
    required this.categoryColor,
    required this.onCenterMap,
    this.showBackButton = false,
    this.onBackPressed,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        showBackButton
            ? _buildGlassIconButton(
                icon: Icons.arrow_back,
                onPressed: onBackPressed ?? () => context.pop(),
              )
            : const SizedBox(width: 50),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGlassIconButton(
              icon: Icons.my_location,
              onPressed: onCenterMap,
            ),
            const SizedBox(width: 8),
            _buildGlassIconButton(
              icon: Icons.directions,
              onPressed: () => viewModel.openDirections(context),
            ),
            const SizedBox(width: 8),
            _buildGlassIconButton(
              icon: Icons.calendar_today,
              onPressed: () => viewModel.addToCalendar(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onPressed,
        splashColor: Colors.white.withValues(alpha: .15),
        highlightColor: Colors.white.withValues(alpha: .1),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: .2),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: categoryColor,
            size: 24,
            shadows: const [
              Shadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
