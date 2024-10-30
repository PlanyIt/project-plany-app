import 'package:flutter/material.dart';
import 'package:front/widgets/buttons/p_primarybutton.dart';
import 'package:front/widgets/buttons/p_secondarybutton.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  PlansScreenState createState() => PlansScreenState();
}

class PlansScreenState extends State<PlansScreen> {
  int _currentStep = 1; // Étape actuelle, de 1 à 4
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
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
        return const Text('Étape 3');
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
                icon: const Icon(Icons.chevron_left_rounded),
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
                // Continuous progress bar with animation
                Center(
                  child: SizedBox(
                    width: 200,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                          begin: 0, end: _currentStep / 4), // update end value
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
                      text: "Suivant",
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
}
