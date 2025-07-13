import 'package:flutter/material.dart';
import '../../../../../data/services/navigation_service.dart';
import '../../../view_models/plan_details_viewmodel.dart';

class StepInfoCard extends StatelessWidget {
  final Color color;
  final PlanDetailsViewModel viewModel;

  const StepInfoCard({
    super.key,
    required this.color,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final step = viewModel.selectedStep;
    if (step == null) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth - 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        border: Border.all(color: Colors.white.withValues(alpha: .5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Indicateur
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              margin: const EdgeInsets.only(right: 8),
            ),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    children: [
                      if (step.cost != null)
                        _iconText(Icons.euro, "${step.cost}€", color),
                      if (step.duration != null)
                        _iconText(Icons.schedule, "${step.duration}", color),
                      _iconText(
                        Icons.place,
                        viewModel.isCalculatingDistance
                            ? "..."
                            : viewModel.distanceToSelectedStep != null
                                ? "${viewModel.distanceToSelectedStep!.toStringAsFixed(1)} km"
                                : "Inconnue",
                        color,
                        loading: viewModel.isCalculatingDistance,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _iconButton(
                  icon: Icons.directions,
                  color: color,
                  onTap: () => NavigationService.navigateToStep(context, step),
                ),
                const SizedBox(height: 8),
                _iconButton(
                  icon: Icons.close,
                  color: Colors.grey.shade300,
                  iconColor: Colors.grey.shade800,
                  onTap: () => viewModel.closeStepInfo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text, Color color,
      {bool loading = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: .7)),
        const SizedBox(width: 4),
        loading
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
