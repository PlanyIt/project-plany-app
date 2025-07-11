import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/category/category_repository.dart';
import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/repositories/step/step_repository.dart';
import '../../../domain/models/category/category.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart' as step_model;
import '../../../domain/models/user/user.dart';
import '../../../domain/use_cases/plan/create_plan_use_case.dart';
import '../../../routing/routes.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../../../widgets/card/step_card.dart';

class CreatePlanViewModel extends ChangeNotifier {
  CreatePlanViewModel({
    required AuthRepository authRepository,
    required CategoryRepository categoryRepository,
    required PlanRepository planRepository,
    required StepRepository stepRepository,
  })  : _authRepository = authRepository,
        _categoryRepository = categoryRepository,
        _createPlanUseCase = CreatePlanUseCase(
          planRepository: planRepository,
          stepRepository: stepRepository,
        ) {
    load = Command0(_load)..execute();
  }

  final AuthRepository _authRepository;
  final CategoryRepository _categoryRepository;
  final CreatePlanUseCase _createPlanUseCase;

  int _currentStep = 1;
  late Command0 load;

  final TextEditingController titlePlanController = TextEditingController();
  final TextEditingController descriptionPlanController =
      TextEditingController();
  final TextEditingController titleStepController = TextEditingController();
  final TextEditingController descriptionStepController =
      TextEditingController();
  final TextEditingController durationStepController = TextEditingController();
  final TextEditingController costStepController = TextEditingController();

  List<Category> _categories = [];
  Category? _selectedCategory;
  XFile? _imageStep;
  final List<StepCard> _stepCards = [];
  bool _isLoading = false;
  String? _error;
  String selectedUnit = 'Heures';
  LatLng? _selectedLocation;
  String? _selectedLocationName;
  int? _editingStepIndex;
  bool _isEditingStep = false;
  User? _user;

  int get currentStep => _currentStep;
  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  XFile? get imageStep => _imageStep;
  List<StepCard> get stepCards => _stepCards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LatLng? get selectedLocation => _selectedLocation;
  String? get selectedLocationName => _selectedLocationName;
  AnimationController? get animationController => _animationController;
  User? get user => _user;
  bool get isEditingStep => _isEditingStep;
  int? get editingStepIndex => _editingStepIndex;

  set selectedLocation(LatLng? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  set selectedLocationName(String? name) {
    _selectedLocationName = name;
    notifyListeners();
  }

  void setCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<Result> _load() async {
    try {
      _setLoading(true);
      _setError(null);

      _user = _authRepository.currentUser;

      final categoryResult = await _categoryRepository.getCategoriesList();
      if (categoryResult is Ok<List<Category>>) {
        _categories = categoryResult.value;
      } else {
        _setError('Erreur lors du chargement des catégories');
        return categoryResult;
      }

      return Result.ok(null);
    } catch (e) {
      _setError('Erreur lors du chargement des données: ${e.toString()}');
      return Result.error(Exception('Erreur lors du chargement des données'));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPlan() async {
    try {
      _setLoading(true);
      _setError(null);

      if (titlePlanController.text.trim().isEmpty ||
          descriptionPlanController.text.trim().isEmpty ||
          _selectedCategory == null ||
          _stepCards.isEmpty) {
        _setError('Vérifiez tous les champs avant de continuer.');
        return false;
      }

      // Préparer les steps et images pour le use case
      final steps = <step_model.Step>[];
      final stepImages = <File?>[];
      for (var i = 0; i < _stepCards.length; i++) {
        final card = _stepCards[i];
        if (card.imageUrl.isEmpty) {
          _setError('L\'image est obligatoire pour l\'etape ${i + 1}');
          return false;
        }
        final formattedDuration = (card.duration?.isNotEmpty ?? false)
            ? '${card.duration} ${card.durationUnit?.toLowerCase()}'
            : null;

        // Utiliser la position de la carte pour créer l'étape
        steps.add(step_model.Step(
          title: card.title,
          description: card.description,
          order: i + 1,
          duration: formattedDuration,
          cost: card.cost,
          latitude:
              card.location?.latitude, // Utiliser la position de la StepCard
          longitude:
              card.location?.longitude, // Utiliser la position de la StepCard
          image: card.imageUrl,
        ));
        stepImages.add(File(card.imageUrl));
      }

      final plan = Plan(
        title: titlePlanController.text.trim(),
        description: descriptionPlanController.text.trim(),
        category: _selectedCategory!,
        user: _user!,
        steps: const [],
        isPublic: true,
      );

      final result = await _createPlanUseCase(
        plan: plan,
        steps: steps,
        stepImages: stepImages,
        user: _user?.id ?? '',
      );

      if (result is! Ok<Plan>) {
        _setError('Erreur lors de la création du plan');
        return false;
      }

      _resetFormFields();
      return true;
    } catch (e, _) {
      _setError('Erreur interne: ${e.toString()}');
      print('Erreur lors de la création du plan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void setStepWithoutNotify(int step) {
    _currentStep = step;
  }

  void _resetFormFields() {
    titlePlanController.clear();
    descriptionPlanController.clear();
    titleStepController.clear();
    descriptionStepController.clear();
    durationStepController.clear();
    costStepController.clear();
    _selectedCategory = null;
    _imageStep = null;
    _stepCards.clear();
    _selectedLocation = null;
    _selectedLocationName = null;
    _currentStep = 1;
    _editingStepIndex = null;
    _isEditingStep = false;
  }

  void handlePreviousStep(PageController controller) {
    if (_currentStep > 1) {
      _animationController?.reverse();
      controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _currentStep--;
      notifyListeners();
    }
  }

  Future<bool> handleNextStep(
      BuildContext context, PageController controller) async {
    if (_currentStep < 3) {
      if (!validateCurrentStep()) {
        _showErrorSnackBar(
            context, _error ?? 'Veuillez compléter tous les champs requis.');
        return false;
      }

      _currentStep++;
      _animationController?.forward();
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
      return false;
    } else {
      final success = await createPlan();
      return success;
    }
  }

  bool validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        if (titlePlanController.text.trim().isEmpty ||
            descriptionPlanController.text.trim().isEmpty ||
            _selectedCategory == null) {
          _setError('Veuillez remplir tous les champs du plan.');
          return false;
        }
        return true;
      case 2:
        if (_stepCards.isEmpty) {
          _setError('Ajoutez au moins une étape.');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Plan créé avec succès'),
        content: const Text(
            'Votre plan est maintenant disponible dans votre dashboard.'),
        actions: [
          TextButton(
            onPressed: () {
              GoRouter.of(context).go(Routes.dashboard);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> pickStepImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      _imageStep = pickedImage;
      notifyListeners();
    }
  }

  void removeStepImage() {
    _imageStep = null;
    notifyListeners();
  }

  void saveStep(
    String title,
    String description,
    File? image,
    String duration,
    double? cost,
  ) {
    final newCard = StepCard(
      title: title,
      description: description,
      imageUrl: image?.path ?? '',
      duration: duration,
      durationUnit: selectedUnit,
      cost: cost,
      location: selectedLocation,
      locationName: selectedLocationName, // Ajouter aussi le nom
    );

    if (_isEditingStep && _editingStepIndex != null) {
      _stepCards[_editingStepIndex!] = newCard;
    } else {
      _stepCards.add(newCard);
    }

    _resetStepFields();
    notifyListeners();
  }

  void editStep(int index) {
    final step = _stepCards[index];
    titleStepController.text = step.title;
    descriptionStepController.text = step.description;
    durationStepController.text = step.duration ?? '';
    costStepController.text = step.cost?.toString() ?? '';
    selectedUnit = step.durationUnit ?? 'Heures';
    _imageStep = step.imageUrl.isNotEmpty ? XFile(step.imageUrl) : null;
    _selectedLocation = step.location;
    _editingStepIndex = index;
    _isEditingStep = true;
    notifyListeners();
  }

  void cancelEditingStep() {
    _resetStepFields();
    _isEditingStep = false;
    _editingStepIndex = null;
    notifyListeners();
  }

  void _resetStepFields() {
    titleStepController.clear();
    descriptionStepController.clear();
    durationStepController.clear();
    costStepController.clear();
    _imageStep = null;
    _selectedLocation = null;
    _selectedLocationName = null;
    _editingStepIndex = null;
    _isEditingStep = false;
  }

  void removeStepCard(int index) {
    _stepCards.removeAt(index);
    notifyListeners();
  }

  void reorderStepCards(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _stepCards.removeAt(oldIndex);
    _stepCards.insert(newIndex, item);
    notifyListeners();
  }

  void startEditingStep(int index) {
    final step = _stepCards[index];
    titleStepController.text = step.title;
    descriptionStepController.text = step.description;
    durationStepController.text = step.duration ?? '';
    costStepController.text = step.cost?.toString() ?? '';
    selectedUnit = step.durationUnit ?? 'Heures';
    _imageStep = step.imageUrl.isNotEmpty ? XFile(step.imageUrl) : null;
    _selectedLocation = step.location;
    _selectedLocationName = step.locationName;
    _editingStepIndex = index;
    _isEditingStep = true;
  }

  AnimationController? _animationController;

  void initAnimationController(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
  }

  void disposeAnimationController() {
    _animationController?.dispose();
  }

  @override
  void dispose() {
    titlePlanController.dispose();
    descriptionPlanController.dispose();
    titleStepController.dispose();
    descriptionStepController.dispose();
    durationStepController.dispose();
    costStepController.dispose();
    disposeAnimationController();
    super.dispose();
  }
}
