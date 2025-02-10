import 'package:flutter/material.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  CreatePlanScreenState createState() => CreatePlanScreenState();
}

class CreatePlanScreenState extends State<CreatePlanScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Pour stocker temporairement les données du formulaire
  final Map<String, dynamic> _formData = {
    'title': '',
    'description': '',
    'date': '',
    'isPublic': false,
  };

  // Méthodes pour passer à l’étape suivante ou précédente
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // Soumettre les données
  void _submitForm() {
    // Ici, vous pouvez envoyer _formData à votre backend ou Firebase
    print('Plan créé: $_formData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un plan'),
      ),
      body: Column(
        children: [
          Stepper(
            currentStep: _currentStep,
            onStepContinue: _nextStep,
            onStepCancel: _previousStep,
            steps: const [
              Step(
                  title: Text('Détails'),
                  content: Text('Remplissez les détails de votre plan')),
              Step(
                  title: Text('Date'),
                  content: Text('Sélectionnez une date pour votre plan')),
              Step(
                  title: Text('Visibilité'),
                  content: Text('Choisissez la visibilité')),
              Step(
                  title: Text('Résumé'),
                  content: Text('Confirmez vos informations')),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _step1Details(),
                _step2Date(),
                _step3Visibility(),
                _step4Summary(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                ElevatedButton(
                    onPressed: _previousStep, child: const Text('Précédent')),
              ElevatedButton(
                onPressed: _currentStep == 3 ? _submitForm : _nextStep,
                child: Text(_currentStep == 3 ? 'Soumettre' : 'Suivant'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Etape 1 : Détails
  Widget _step1Details() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Titre'),
          onChanged: (value) => _formData['title'] = value,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Description'),
          onChanged: (value) => _formData['description'] = value,
        ),
      ],
    );
  }

  // Etape 2 : Date
  Widget _step2Date() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Date'),
          onChanged: (value) => _formData['date'] = value,
        ),
      ],
    );
  }

  // Etape 3 : Visibilité
  Widget _step3Visibility() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Public'),
          value: _formData['isPublic'],
          onChanged: (value) => setState(() {
            _formData['isPublic'] = value;
          }),
        ),
      ],
    );
  }

  // Etape 4 : Résumé
  Widget _step4Summary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Titre: ${_formData['title']}'),
        Text('Description: ${_formData['description']}'),
        Text('Date: ${_formData['date']}'),
        Text('Public: ${_formData['isPublic'] ? 'Oui' : 'Non'}'),
      ],
    );
  }
}
