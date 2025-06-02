import 'package:flutter/material.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:front/screens/create-plan/steps/step_three_content.dart';
import 'package:front/screens/create-plan/steps/step_one_content.dart';
import 'package:front/screens/create-plan/steps/step_two_content.dart';
import 'package:front/theme/app_theme.dart';
import 'package:provider/provider.dart';

class CreatePlansScreen extends StatelessWidget {
  const CreatePlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreatePlanProvider(),
      child: const _CreatePlansScreenContent(),
    );
  }
}

class _CreatePlansScreenContent extends StatefulWidget {
  const _CreatePlansScreenContent();

  @override
  _CreatePlansScreenContentState createState() =>
      _CreatePlansScreenContentState();
}

class _CreatePlansScreenContentState extends State<_CreatePlansScreenContent>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreatePlanProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc pour tout l'écran
      body: Column(
        children: [
          // Barre d'état transparente
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.transparent,
          ),
          _buildProgressIndicator(provider),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                provider.setStepWithoutNotify(index + 1);
              },
              children: [
                StepOneContent(),
                StepTwoContent(),
                StepThreeContent(),
              ],
            ),
          ),
          _buildBottomNavigation(provider),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(CreatePlanProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Étape ${provider.currentStep}/3',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${(provider.currentStep / 3 * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Indicateur de progression interactive
          Row(
            children: List.generate(3, (index) {
              final isActive = index < provider.currentStep;
              final isCurrent = index == provider.currentStep - 1;

              return Expanded(
                child: Row(
                  children: [
                    // Cercle indicateur
                    GestureDetector(
                      onTap: index < provider.currentStep
                          ? () => _navigateToStep(index + 1, provider)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: isCurrent ? 30 : 24,
                        width: isCurrent ? 30 : 24,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primaryColor
                              : Colors.grey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.4),
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
                                    : Colors.grey.withValues(alpha: 0.2),
                                index + 1 < provider.currentStep
                                    ? AppTheme.primaryColor
                                    : Colors.grey.withValues(alpha: 0.2),
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
          ),
          const SizedBox(height: 12),
          // Titres des étapes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Informations',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: provider.currentStep == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: provider.currentStep == 1
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Étapes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: provider.currentStep == 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: provider.currentStep == 2
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Finalisation',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: provider.currentStep == 3
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: provider.currentStep == 3
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToStep(int stepNumber, CreatePlanProvider provider) {
    if (stepNumber <= provider.currentStep) {
      // Navigation seulement vers des étapes déjà visitées ou l'étape actuelle
      if (stepNumber < provider.currentStep) {
        _animationController.reverse();
        _pageController.animateToPage(
          stepNumber - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        // Correction ici: utiliser la méthode existante au lieu de setCurrentStep
        provider.setStepWithoutNotify(stepNumber);
      }
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

  Widget _buildBottomNavigation(CreatePlanProvider provider) {
    return Container(
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          if (provider.currentStep > 1)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  _animationController.reverse();
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  provider.previousStep();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  provider.currentStep == 3 ? 'Précédent' : 'Retour',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ),
          if (provider.currentStep > 1) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (provider.currentStep < 3) {
                  if (!provider.validateCurrentStep()) {
                    _showErrorSnackBar(
                        context,
                        provider.error ??
                            "Veuillez compléter tous les champs requis.");
                    return;
                  }
                  _animationController.forward();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  provider.nextStep();
                } else {
                  _createPlan(provider);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.currentStep == 3
                    ? AppTheme.accentColor
                    : AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.currentStep == 3
                        ? 'Publier mon plan'
                        : 'Continuer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (provider.currentStep == 3)
                    const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createPlan(CreatePlanProvider provider) async {
    if (provider.isLoading) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Création de votre plan en cours...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    final success = await provider.createPlan();

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    if (success) {
      _showSuccessDialog();
    } else {
      if (mounted) {
        _showErrorSnackBar(
          context,
          provider.error ??
              'Une erreur est survenue lors de la création du plan.',
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Plan créé avec succès',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre plan a été créé et publié avec succès. Vous pouvez maintenant le retrouver dans la liste de vos plans.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Retour à la page d'accueil
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Voir mes plans',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
