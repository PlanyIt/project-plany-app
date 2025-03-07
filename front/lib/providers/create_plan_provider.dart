import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:front/models/categorie.dart';
import 'package:front/models/plan.dart';
import 'package:front/models/tag.dart';
import 'package:front/models/step.dart' as StepModel;
import 'package:front/services/categorie_service.dart';
import 'package:front/services/imgur_service.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/services/tag_service.dart';
import 'package:front/widgets/card/step_card.dart';
import 'package:image_picker/image_picker.dart';

class CreatePlanProvider extends ChangeNotifier {
  // Services
  final PlanService _planService = PlanService();
  final StepService _stepService = StepService();
  final TagService _tagService = TagService();
  final ImgurService _imgurService = ImgurService();
  final CategorieService _categorieService = CategorieService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _currentStep = 1;

  //Plan Controller
  final TextEditingController titlePlanController = TextEditingController();
  final TextEditingController descriptionPlanController =
      TextEditingController();
  final TextEditingController tagSearchPlanController = TextEditingController();

  //Step Controller
  final TextEditingController titleStepController = TextEditingController();
  final TextEditingController descriptionStepController =
      TextEditingController();
  final TextEditingController durationStepController = TextEditingController();
  final TextEditingController costStepController = TextEditingController();

  List<Category> _categories = [];
  List<Tag> _tags = [];
  List<Tag> _filteredTags = [];
  final List<Tag> _selectedTags = [];
  Category? _selectedCategory;
  bool _showTagContainer = false;
  XFile? _imageStep;
  final List<StepCard> _stepCards = [];
  bool _isLoading = false;
  String? _error;
  String selectedUnit = 'Heures';

  // Step creation fields
  GeoPoint? _selectedLocation;
  String? _selectedLocationName;

  // Getters
  int get currentStep => _currentStep;
  List<Category> get categories => _categories;
  List<Tag> get tags => _tags;
  List<Tag> get filteredTags => _filteredTags;
  List<Tag> get selectedTags => _selectedTags;
  Category? get selectedCategory => _selectedCategory;
  bool get showTagContainer => _showTagContainer;
  XFile? get imageStep => _imageStep;
  List<StepCard> get stepCards => _stepCards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GeoPoint? get selectedLocation => _selectedLocation;
  String? get selectedLocationName => _selectedLocationName;

  // Setters
  set selectedLocation(GeoPoint? location) {
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
    await loadTags();
  }

  // Methods
  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      final categories = await _categorieService.getCategories();
      _categories = categories;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTags() async {
    try {
      _setLoading(true);
      final tags = await _tagService.getCategories();
      _tags = tags;
      _filteredTags = tags;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tags: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void filterTags(String query) {
    final filteredTags = _tags.where((tag) {
      final tagName = tag.name.toLowerCase();
      final input = query.toLowerCase();
      return tagName.contains(input);
    }).toList();

    _filteredTags = filteredTags;
    _showTagContainer = query.isNotEmpty;
    notifyListeners();
  }

  void toggleTag(Tag tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void removeTag(Tag tag) {
    _selectedTags.remove(tag);
    notifyListeners();
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

  void addStepCard(
    String title,
    String description,
    File? imageFile,
    String durationText,
    double? cost,
  ) {
    stepCards.add(StepCard(
      title: title,
      description: description,
      imageUrl: imageFile?.path ?? '',
      duration: durationText,
      durationUnit: selectedUnit,
      cost: cost,
      location: selectedLocation,
      locationName: selectedLocationName,
    ));

    // Réinitialiser les champs après ajout
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

    notifyListeners();
  }

  void reorderStepCards(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = stepCards.removeAt(oldIndex);
    stepCards.insert(newIndex, item);
    notifyListeners();
  }

  void setLocation(GeoPoint location, String locationName) {
    _selectedLocation = location;
    _selectedLocationName = locationName;
    notifyListeners();
  }

  void clearTagSearch() {
    tagSearchPlanController.clear();
    _showTagContainer = false;
    notifyListeners();
  }

  void setShowTagContainer(bool value) {
    _showTagContainer = value;
    notifyListeners();
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
        final step = StepModel.Step(
          title: _stepCards[i].title,
          description: _stepCards[i].description,
          order: i + 1,
          userId: _auth.currentUser!.uid,
          duration: formattedDuration,
          cost: _stepCards[i].cost,
          position: _stepCards[i].location,
          image: imageUrl,
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
        tags: _selectedTags.map((tag) => tag.id).toList(),
        userId: _auth.currentUser!.uid,
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
    _selectedTags.clear();
    _showTagContainer = false;
    _stepCards.clear();
    _currentStep = 1;
    _resetStepFields();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  @override
  void dispose() {
    titlePlanController.dispose();
    descriptionPlanController.dispose();
    tagSearchPlanController.dispose();
    super.dispose();
  }
}
