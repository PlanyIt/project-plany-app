import 'package:flutter/material.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:front/screens/create-plan/steps/step_three_content.dart';
import 'package:front/screens/create-plan/steps/step_one_content.dart';
import 'package:front/screens/create-plan/steps/step_two_content.dart';
import 'package:front/widgets/button/primary_button.dart';
import 'package:front/widgets/button/secondary_button.dart';
import 'package:provider/provider.dart';

class CreatePlansScreen extends StatelessWidget {
  const CreatePlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreatePlanProvider(),
      child: _CreatePlansScreenContent(),
    );
  }
}

class _CreatePlansScreenContent extends StatefulWidget {
  @override
  _CreatePlansScreenContentState createState() =>
      _CreatePlansScreenContentState();
}

class _CreatePlansScreenContentState extends State<_CreatePlansScreenContent> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreatePlanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leadingWidth: 80,
        leading: provider.currentStep > 1
            ? IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                ),
                icon:
                    const Icon(Icons.chevron_left_rounded, color: Colors.black),
                iconSize: 30,
                onPressed: provider.previousStep,
              )
            : const SizedBox(),
        centerTitle: true,
        title: const Text(
          "Créer un plan",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Stepper fixe en haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${provider.currentStep}/3',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                            begin: 0, end: provider.currentStep / 3),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor:
                                const Color.fromARGB(59, 51, 37, 181),
                            color: const Color(0xFF3425B5),
                            minHeight: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Contenu défilant avec padding pour laisser place au stepper
          Padding(
            padding: const EdgeInsets.only(
                top: 80.0), // Ajuster selon la hauteur du stepper
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(),
              ),
            ),
          ),

          // 3. Boutons de navigation en bas
          _buildBottomNavigationButtons(),
        ],
      ),
    );
  }

  void _createPlan(CreatePlanProvider provider) {
    provider.createPlan().then((success) {
      if (success) {
        // Afficher toast de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Afficher toast d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création du plan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Widget _buildBottomNavigationButtons() {
    final provider = Provider.of<CreatePlanProvider>(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: PrimaryButton(
                text: provider.currentStep != 3 ? "Suivant" : "Valider",
                onPressed: provider.currentStep != 3
                    ? provider.nextStep
                    : () => _createPlan(provider),
              ),
            ),
            if (provider.currentStep > 1)
              Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: SecondaryButton(
                      text: "Annuler",
                      onPressed: provider.previousStep,
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final provider = Provider.of<CreatePlanProvider>(context);

    switch (provider.currentStep) {
      case 1:
        return StepOneContent();
      case 2:
        return StepTwoContent();
      case 3:
        return StepThreeContent();
      default:
        return const Text('Étape inconnue');
    }
  }
}
