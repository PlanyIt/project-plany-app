import 'dart:io';

import 'package:flutter/material.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/routing/routes.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';
import 'package:front/widgets/card/step_card.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class CreatePlanViewModel extends ChangeNotifier {
  CreatePlanViewModel({
    required CategoryRepository categoryRepository,
    required UserRepository userRepository,
    required PlanRepository planRepository,
    required StepRepository stepRepository,
  })  : _categoryRepository = categoryRepository,
        _userRepository = userRepository,
        _planRepository = planRepository,
        _stepRepository = stepRepository {
    load = Command0(_load)..execute();
  }

  final CategoryRepository _categoryRepository;
  final PlanRepository _planRepository;
  final UserRepository _userRepository;
  final StepRepository _stepRepository;

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
  String _userId = '';
  LatLng? _selectedLocation;
  String? _selectedLocationName;
  int? _editingStepIndex;
  bool _isEditingStep = false;

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
  String get userId => _userId;
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

      final categoryResult = await _categoryRepository.getCategoriesList();
      if (categoryResult is Ok<List<Category>>) {
        _categories = categoryResult.value;
      } else {
        _setError('Erreur lors du chargement des catégories');
        return categoryResult;
      }

      final userResult = await _userRepository.getCurrentUser();
      if (userResult is Ok<User>) {
        _userId = userResult.value.id;
      } else {
        _setError('Erreur lors du chargement de l\'utilisateur');
        return userResult;
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

      final List<String> stepIds = [];

      for (int i = 0; i < _stepCards.length; i++) {
        final card = _stepCards[i];
        if (card.imageUrl.isEmpty) {
          _setError('L\'image est obligatoire pour l\'etape ${i + 1}');
          return false;
        }

        final imageUrlResult =
            await _stepRepository.uploadImage(File(card.imageUrl));
        if (imageUrlResult is! Ok<String>) {
          _setError('Upload image échouée à l\'etape ${i + 1}');
          return false;
        }

        final formattedDuration = (card.duration?.isNotEmpty ?? false)
            ? '${card.duration} ${card.durationUnit?.toLowerCase()}'
            : null;

        final step = step_model.Step(
          title: card.title,
          description: card.description,
          order: i + 1,
          userId: _userId,
          duration: formattedDuration,
          cost: card.cost,
          position: card.location,
          image: imageUrlResult.value,
        );

        final stepResult = await _stepRepository.createStep(step, _userId);
        if (stepResult is Ok<step_model.Step>) {
          stepIds.add(stepResult.value.id!);
        } else {
          _setError('Création de l\'etape ${i + 1} échouée');
          return false;
        }
      }

      final plan = Plan(
        title: titlePlanController.text.trim(),
        description: descriptionPlanController.text.trim(),
        category: _selectedCategory!.id,
        userId: _userId,
        steps: stepIds,
        isPublic: true,
      );

      final planResult = await _planRepository.createPlan(plan);
      if (planResult is! Ok<Plan>) {
        _setError('Erreur lors de la création du plan');
        return false;
      }

      _resetFormFields();
      return true;
    } catch (e) {
      _setError('Erreur interne: ${e.toString()}');
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
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

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
