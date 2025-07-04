import 'dart:io';

import 'package:flutter/material.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:front/services/auth_service.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/services/imgur_service.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/ui/core/ui/card/step_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class CreatePlanProvider extends ChangeNotifier {
  // Services
  final PlanService _planService = PlanService();
  final StepService _stepService = StepService();
  final ImgurService _imgurService = ImgurService();
  final CategorieService _categorieService = CategorieService();
  final AuthService _authService =
      AuthService(); // Ajouter le service d'auth personnalisé

  int _currentStep = 1;

  //Plan Controller
  final TextEditingController titlePlanController = TextEditingController();
  final TextEditingController descriptionPlanController =
      TextEditingController();

  //Step Controller
  final TextEditingController titleStepController = TextEditingController();
  final TextEditingController descriptionStepController =
      TextEditingController();
  final TextEditingController durationStepController = TextEditingController();
  final TextEditingController costStepController = TextEditingController();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _showTagContainer = false;
  XFile? _imageStep;
  final List<StepCard> _stepCards = [];
  bool _isLoading = false;
  String? _error;
  String selectedUnit = 'Heures';

  // Step creation fields
  LatLng? _selectedLocation;
  String? _selectedLocationName;

  // Nouvel attribut pour stocker l'index de l'étape en cours d'édition
  int? _editingStepIndex;
  bool _isEditingStep = false;

  // Getters
  int get currentStep => _currentStep;
  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get showTagContainer => _showTagContainer;
  XFile? get imageStep => _imageStep;
  List<StepCard> get stepCards => _stepCards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LatLng? get selectedLocation => _selectedLocation;
  String? get selectedLocationName => _selectedLocationName;

  // Nouveaux getters
  bool get isEditingStep => _isEditingStep;
  int? get editingStepIndex => _editingStepIndex;

  // Setters
  set selectedLocation(LatLng? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  set selectedLocationName(String? name) {
    _selectedLocationName = name;
    notifyListeners();
  }

  // Constructor
  CreatePlanProvider() {
    _init();
  }

  void _init() async {
    await loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      final categories = await _categorieService.getCategories();
      _categories = categories.cast<Category>();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void setCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setImageStep(XFile? image) {
    _imageStep = image;
    notifyListeners();
  }

  Future<void> pickStepImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _imageStep = image;
      notifyListeners();
    }
  }

  void removeStepCard(int index) {
    if (index >= 0 && index < _stepCards.length) {
      _stepCards.removeAt(index);
      notifyListeners();
    }
  }

  void removePlanImage() {
    notifyListeners();
  }

  void removeStepImage() {
    _imageStep = null;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Méthode pour commencer l'édition d'une étape existante
  void startEditingStep(int index) {
    if (index >= 0 && index < _stepCards.length) {
      _isEditingStep = true;
      _editingStepIndex = index;

      final stepToEdit = _stepCards[index];

      // Pré-remplir les champs du formulaire avec les données de l'étape
      titleStepController.text = stepToEdit.title;
      descriptionStepController.text = stepToEdit.description;

      if (stepToEdit.duration != null) {
        durationStepController.text = stepToEdit.duration!;
      }

      if (stepToEdit.durationUnit != null) {
        selectedUnit = stepToEdit.durationUnit!;
      }

      if (stepToEdit.cost != null) {
        costStepController.text = stepToEdit.cost.toString();
      }

      // Gérer l'image si elle existe
      if (stepToEdit.imageUrl.isNotEmpty) {
        _imageStep = XFile(stepToEdit.imageUrl);
      } else {
        _imageStep = null;
      }

      // Gérer la localisation si elle existe
      _selectedLocation = stepToEdit.location;
      _selectedLocationName = stepToEdit.locationName;

      notifyListeners();
    }
  }

  // Méthode pour annuler l'édition en cours
  void cancelEditingStep() {
    _isEditingStep = false;
    _editingStepIndex = null;
    _resetStepFields();
    notifyListeners();
  }

  // Méthode modifiée pour mettre à jour une étape existante ou en ajouter une nouvelle
  void saveStep(
    String title,
    String description,
    File? imageFile,
    String durationText,
    double? cost,
  ) {
    // Vérifier que le lieu sélectionné n'est pas un message de chargement
    final locationNameToSave =
        _selectedLocationName == "Recherche de l'adresse..." ||
                _selectedLocationName == "Impossible d'obtenir l'adresse"
            ? null
            : _selectedLocationName;

    final stepCard = StepCard(
      title: title,
      description: description,
      imageUrl: imageFile?.path ?? '',
      duration: durationText,
      durationUnit: selectedUnit,
      cost: cost,
      location: selectedLocation,
      locationName: locationNameToSave,
    );

    if (_isEditingStep && _editingStepIndex != null) {
      // Mise à jour d'une étape existante
      _stepCards[_editingStepIndex!] = stepCard;
      _isEditingStep = false;
      _editingStepIndex = null;
    } else {
      // Ajout d'une nouvelle étape
      _stepCards.add(stepCard);
    }

    // Réinitialiser les champs après ajout/mise à jour
    _resetStepFields();
    notifyListeners();
  }

  Future<String?> _getCurrentUserId() async {
    final user = await _authService
        .getUser(); // Utiliser le service d'auth au lieu de Firebase
    return user?.id;
  }

  Future<bool> createPlan() async {
    try {
      _setLoading(true);
      _setError(null);

      // Validation des données du plan (inchangée)
      if (titlePlanController.text.trim().isEmpty) {
        _setError('Le titre du plan est obligatoire');
        return false;
      }

      if (descriptionPlanController.text.trim().isEmpty) {
        _setError('La description du plan est obligatoire');
        return false;
      }

      if (_selectedCategory == null) {
        _setError('Veuillez sélectionner une catégorie');
        return false;
      }

      if (_stepCards.isEmpty) {
        _setError('Ajoutez au moins une étape à votre plan');
        return false;
      }

      // Obtenir l'ID utilisateur à partir du service personnalisé
      final String? userId = await _getCurrentUserId();
      if (userId == null) {
        _setError('Utilisateur non connecté');
        return false;
      }

      // Créer chaque step individuellement et collecter leurs IDs
      final List<String> stepIds = [];

      for (int i = 0; i < _stepCards.length; i++) {
        // Vérifier si l'image existe
        if (_stepCards[i].imageUrl.isEmpty) {
          _setError('L\'image est obligatoire pour l\'étape ${i + 1}');
          return false;
        }

        // Upload step image
        String? imageUrl;
        try {
          final imgResponse =
              await _imgurService.uploadImage(File(_stepCards[i].imageUrl));
          imageUrl = imgResponse.link;
        } catch (e) {
          _setError(
              'Erreur lors de l\'upload de l\'image pour l\'étape ${i + 1}: ${e.toString()}');
          return false;
        }

        // Formater la durée
        String? formattedDuration;
        if (_stepCards[i].duration != null &&
            _stepCards[i].duration!.isNotEmpty) {
          formattedDuration =
              '${_stepCards[i].duration} ${_stepCards[i].durationUnit?.toLowerCase()}';
        }

        // Créer un step
        final step = step_model.Step(
          title: _stepCards[i].title,
          description: _stepCards[i].description,
          order: i + 1,
          duration: formattedDuration,
          cost: _stepCards[i].cost,
          position: _stepCards[i].location,
          image: imageUrl,
          // Ne pas envoyer l'adresse car elle n'est pas acceptée par le backend
          // address: _stepCards[i].locationName,
        );

        // Appel API pour créer le step et récupérer son ID
        final createdStepId = await _stepService.createStep(step);
        stepIds.add(createdStepId);
      }

      // Créer le plan avec les IDs des steps au lieu des objets steps
      final plan = Plan(
        title: titlePlanController.text.trim(),
        description: descriptionPlanController.text.trim(),
        category: _selectedCategory!.id,
        userId: userId, // Utiliser l'ID utilisateur récupéré
        steps: stepIds,
        isPublic: true,
      );

      // Créer le plan dans la base de données
      await _planService.createPlan(plan);

      // Réinitialiser le formulaire après la création réussie
      _resetFormFields();

      return true;
    } catch (e) {
      _setError('Erreur lors de la création du plan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _resetFormFields() {
    titlePlanController.clear();
    descriptionPlanController.clear();
    _selectedCategory = null;
    _showTagContainer = false;
    _stepCards.clear();
    _currentStep = 1;
    _resetStepFields();
    notifyListeners();
  }

  void _resetStepFields() {
    titleStepController.clear();
    descriptionStepController.clear();
    durationStepController.clear();
    costStepController.clear();
    selectedUnit = 'Minutes';
    setImageStep(null);
    selectedLocation = null;
    selectedLocationName = null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void setStepWithoutNotify(int step) {
    _currentStep = step;
  }

  bool validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        // Vérification des champs de l'étape 1
        if (titlePlanController.text.trim().isEmpty) {
          _setError('Le titre du plan est obligatoire');
          return false;
        }
        if (descriptionPlanController.text.trim().isEmpty) {
          _setError('La description du plan est obligatoire');
          return false;
        }
        if (_selectedCategory == null) {
          _setError('Veuillez sélectionner une catégorie');
          return false;
        }
        return true;

      case 2:
        // Vérification des étapes ajoutées
        if (_stepCards.isEmpty) {
          _setError('Ajoutez au moins une étape à votre plan');
          return false;
        }
        return true;

      case 3:
        // La dernière étape est juste une prévisualisation
        return true;

      default:
        return false;
    }
  }

  void reorderStepCards(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = stepCards.removeAt(oldIndex);
    stepCards.insert(newIndex, item);
    notifyListeners();
  }

  // Fonctions de gestion des tags à supprimer ou neutraliser
  void clearTagSearch() {
    // Méthode gardée mais vidée
    notifyListeners();
  }

  void setShowTagContainer(bool value) {
    _showTagContainer = value;
    notifyListeners();
  }

  @override
  void dispose() {
    titlePlanController.dispose();
    descriptionPlanController.dispose();
    super.dispose();
  }
}
