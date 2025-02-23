import 'package:flutter/material.dart';
import 'package:front/models/plan.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/widgets/buttons/p_primarybutton.dart';
import 'package:front/widgets/buttons/p_secondarybutton.dart';

class CreatePlansScreen extends StatefulWidget {
  const CreatePlansScreen({super.key});

  @override
  CreatePlansScreenState createState() => CreatePlansScreenState();
}

class CreatePlansScreenState extends State<CreatePlansScreen> {
  int _currentStep = 1;
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final PlanService _planService = PlanService();

  void _nextStep() async {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      final newPlan = Plan(
        id: '', // L'ID sera généré par le backend
        title: _titreController.text,
        description: _descriptionController.text,
      );

      try {
        await _planService.createPlan(newPlan);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan créé avec succès !')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la création du plan : $e')),
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget content() {
    switch (_currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Titre du plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titreController,
              decoration: InputDecoration(
                labelText: 'Titre du plan',
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description du plan',
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajout des étapes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description du plan',
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      case 4:
        return const Text('Étape 4');
      default:
        return const Text('Étape inconnue');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: _currentStep > 1
            ? IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                ),
                icon:
                    const Icon(Icons.chevron_left_rounded, color: Colors.black),
                iconSize: 30,
                onPressed: _previousStep,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Text with step count
                Text(
                  '$_currentStep/4',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _currentStep / 4),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey[300],
                          color: const Color(0xFF3425B5),
                          minHeight: 5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
                content(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
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
                      text: _currentStep != 4 ? "Suivant" : "Valider",
                      onPressed: _nextStep,
                    ),
                  ),
                  if (_currentStep > 1)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          child: SecondaryButton(
                            text: "Annuler",
                            onPressed: _previousStep,
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
