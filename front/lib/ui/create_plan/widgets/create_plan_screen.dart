import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/ui/core/ui/bottom_bar/bottom_bar.dart';
import 'package:front/ui/core/ui/plany_button.dart';
import 'package:front/ui/create_plan/widgets/step_three_content.dart';
import 'package:front/ui/create_plan/widgets/step_one_content.dart';
import 'package:front/ui/create_plan/widgets/step_two_content.dart';
import 'package:front/theme/app_theme.dart';

// Providers pour l'état
final createPlanCurrentStepProvider = StateProvider<int>((ref) => 1);
final createPlanIsPublishingProvider = StateProvider<bool>((ref) => false);

class CreatePlanScreen extends ConsumerWidget {
  const CreatePlanScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(createPlanCurrentStepProvider);
    final isPublishing = ref.watch(createPlanIsPublishingProvider);

    return Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 1),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildProgressIndicator(context, ref, currentStep),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                ref.read(createPlanCurrentStepProvider.notifier).state =
                    index + 1;
              },
              children: [
                StepOneContent(),
                StepTwoContent(),
                StepThreeContent(),
              ],
            ),
          ),
          _buildBottomNavigation(context, ref, currentStep, isPublishing),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
      BuildContext context, WidgetRef ref, int currentStep) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          _buildProgressHeader(currentStep),
          const SizedBox(height: 12),
          _buildProgressCircles(currentStep, ref),
          const SizedBox(height: 12),
          _buildStepTitles(currentStep),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Étape $currentStep/3',
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        Text(
          '${(currentStep / 3 * 100).toInt()}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCircles(int currentStep, WidgetRef ref) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;

        return Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: isActive ? () => _navigateToStep(index + 1, ref) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isCurrent ? 30 : 24,
                  width: isCurrent ? 30 : 24,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryColor
                        : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      _getStepIcon(index + 1),
                      color: isActive ? Colors.white : Colors.grey,
                      size: isCurrent ? 18 : 14,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isActive
                              ? AppTheme.primaryColor
                              : Colors.grey.withOpacity(0.2),
                          index + 1 < currentStep
                              ? AppTheme.primaryColor
                              : Colors.grey.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepTitles(int currentStep) {
    final steps = ['Informations', 'Étapes', 'Finalisation'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        final isCurrent = currentStep == index + 1;
        return Expanded(
          child: Text(
            steps[index],
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? AppTheme.primaryColor : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }

  void _navigateToStep(int stepNumber, WidgetRef ref) {
    final currentStep = ref.read(createPlanCurrentStepProvider);
    if (stepNumber <= currentStep) {
      ref.read(createPlanCurrentStepProvider.notifier).state = stepNumber;
    }
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 1:
        return Icons.info_outline;
      case 2:
        return Icons.list_alt;
      case 3:
        return Icons.check_circle_outline;
      default:
        return Icons.circle;
    }
  }

  Widget _buildBottomNavigation(
      BuildContext context, WidgetRef ref, int currentStep, bool isPublishing) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          if (currentStep > 1)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  _handlePreviousStep(ref);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  currentStep == 3 ? 'Précédent' : 'Retour',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ),
          if (currentStep > 1) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: PlanyButton(
              color: currentStep == 3
                  ? AppTheme.accentColor
                  : AppTheme.primaryColor,
              text: currentStep == 3 ? 'Publier mon plan' : 'Continuer',
              isLoading: currentStep == 3 && isPublishing,
              onPressed: () async {
                await _handleNextStep(context, ref, currentStep);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handlePreviousStep(WidgetRef ref) {
    final currentStep = ref.read(createPlanCurrentStepProvider);
    if (currentStep > 1) {
      ref.read(createPlanCurrentStepProvider.notifier).state = currentStep - 1;
    }
  }

  Future<void> _handleNextStep(
      BuildContext context, WidgetRef ref, int currentStep) async {
    if (currentStep == 3) {
      ref.read(createPlanIsPublishingProvider.notifier).state = true;

      try {
        // Simuler la publication
        await Future.delayed(const Duration(seconds: 2));

        if (context.mounted) {
          _showSuccessDialog(context);
        }
      } finally {
        ref.read(createPlanIsPublishingProvider.notifier).state = false;
      }
    } else {
      ref.read(createPlanCurrentStepProvider.notifier).state = currentStep + 1;
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Votre plan a été publié avec succès !'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
