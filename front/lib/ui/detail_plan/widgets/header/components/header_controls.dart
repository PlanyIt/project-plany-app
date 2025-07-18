import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/services/calendar_service.dart';
import '../../../../../data/services/navigation_service.dart';
import '../../../view_models/detail/plan_details_viewmodel.dart';

class HeaderControls extends StatelessWidget {
  final Color categoryColor;
  final VoidCallback onCenterMap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PlanDetailsViewModel planViewModel;

  const HeaderControls({
    super.key,
    required this.categoryColor,
    required this.onCenterMap,
    this.showBackButton = false,
    this.onBackPressed,
    required this.planViewModel,
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
                onPressed: () {
                  final steps = planViewModel.plan?.steps
                      .where((s) => s.latitude != null && s.longitude != null)
                      .toList();

                  if (steps != null && steps.isNotEmpty) {
                    NavigationService.navigateToStep(context, steps.first);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Aucune étape valide pour la navigation.")),
                    );
                  }
                }),
            const SizedBox(width: 8),
            _buildGlassIconButton(
              icon: Icons.calendar_today,
              onPressed: () => CalendarService.addPlanToCalendar(
                  context, planViewModel.plan),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onPressed,
        splashColor: Colors.white.withValues(alpha: .15),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          alignment: Alignment.center,
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor ?? categoryColor,
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
