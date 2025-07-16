import 'package:flutter/material.dart';

import '../core/themes/app_theme.dart';
import '../core/ui/bottom_bar/bottom_bar.dart';
import '../core/ui/button/plany_button.dart';
import 'view_models/create_plan_view_model.dart';
import 'widgets/step_one_content.dart';
import 'widgets/step_three_content.dart';
import 'widgets/step_two_content.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({
    super.key,
    required this.viewModel,
  });

  final CreatePlanViewModel viewModel;

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  bool isPublishing = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initAnimationController(this);

    widget.viewModel.addListener(() {
      final error = widget.viewModel.error;
      if (error != null && error != _lastError && mounted) {
        _lastError = error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (error == null && _lastError != null) {
        _lastError = null;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 1),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          ValueListenableBuilder<int>(
            valueListenable: widget.viewModel.currentStep,
            builder: (context, step, _) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  children: [
                    _buildProgressHeader(step),
                    const SizedBox(height: 12),
                    _buildProgressCircles(step),
                    const SizedBox(height: 12),
                    _buildStepTitles(step),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                widget.viewModel.currentStep.value = index + 1;
              },
              children: [
                StepOneContent(viewModel: widget.viewModel),
                StepTwoContent(viewModel: widget.viewModel),
                StepThreeContent(viewModel: widget.viewModel),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(int step) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Étape $step/3',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        Text(
          '${(step / 3 * 100).toInt()}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCircles(int currentStep) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;

        return Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: isActive ? () => _navigateToStep(index + 1) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isCurrent ? 30 : 24,
                  width: isCurrent ? 30 : 24,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryColor
                        : Colors.grey.withValues(alpha: .2),
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: .4),
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
                              : Colors.grey.withValues(alpha: .2),
                          index + 1 < currentStep
                              ? AppTheme.primaryColor
                              : Colors.grey.withValues(alpha: .2),
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

  void _navigateToStep(int stepNumber) {
    if (stepNumber <= widget.viewModel.currentStep.value) {
      _pageController.animateToPage(
        stepNumber - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      widget.viewModel.currentStep.value = stepNumber;
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

  Widget _buildBottomNavigation() {
    return ValueListenableBuilder<int>(
      valueListenable: widget.viewModel.currentStep,
      builder: (context, currentStep, _) {
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
                color: Colors.black.withValues(alpha: .05),
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
                      widget.viewModel.currentStep.value--;
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: AppTheme.primaryColor.withValues(alpha: .5),
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
                    if (currentStep == 3) {
                      setState(() => isPublishing = true);
                    }

                    final success =
                        await widget.viewModel.handleNextStep(_pageController);

                    if (!mounted) return;
                    setState(() => isPublishing = false);

                    if (success && context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Plan créé avec succès'),
                          content: const Text(
                            'Votre plan est maintenant disponible sur votre tableau de bord.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  widget.viewModel.goToDashboard(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
