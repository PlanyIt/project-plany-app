import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/repositories/comment/comment_repository.dart';
import 'package:front/data/services/imgur_service.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:front/domain/models/user/user.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/utils/result.dart';
import 'dart:io';

class DetailsPlanViewModel extends ChangeNotifier {
  DetailsPlanViewModel({
    required UserRepository userRepository,
    required CategoryRepository categoryRepository,
    required PlanRepository planRepository,
    required StepRepository stepRepository,
    required CommentRepository commentRepository,
  })  : _userRepository = userRepository,
        _categoryRepository = categoryRepository,
        _planRepository = planRepository,
        _stepRepository = stepRepository,
        _commentRepository = commentRepository,
        _imgurService = ImgurService();

  final UserRepository _userRepository;
  final CategoryRepository _categoryRepository;
  final PlanRepository _planRepository;
  final StepRepository _stepRepository;
  final CommentRepository _commentRepository;
  final ImgurService _imgurService;

  Plan? _plan;
  List<step_model.Step> _steps = [];
  Category? _category;
  bool _isLoading = false;
  String? _error;

  // Comment-related properties
  List<Comment> _comments = [];
  Map<String, List<Comment>> _responses = {};
  Map<String, bool> _showAllResponsesMap = {};
  String? _currentUserId;
  bool _hasMoreComments = true;
  File? _selectedImage;
  File? _selectedResponseImage;
  String? _existingImageUrl;
  bool _isUploadingImage = false;
  bool _isUploadingResponseImage = false;

  // Getters
  Plan? get plan => _plan;
  List<step_model.Step> get steps => _steps;
  Category? get category => _category;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Comment> get comments => _comments;
  Map<String, List<Comment>> get responses => _responses;
  Map<String, bool> get showAllResponsesMap => _showAllResponsesMap;
  String? get currentUserId => _currentUserId;
  bool get hasMoreComments => _hasMoreComments;
  File? get selectedImage => _selectedImage;
  File? get selectedResponseImage => _selectedResponseImage;
  String? get existingImageUrl => _existingImageUrl;
  bool get isUploadingImage => _isUploadingImage;
  bool get isUploadingResponseImage => _isUploadingResponseImage;

  // Computed property for category color
  Color get categoryColor {
    if (_category == null || _category!.color.isEmpty) {
      return const Color(0xFF3425B5); // Default color
    }
    try {
      final colorString = _category!.color.startsWith('#')
          ? _category!.color.replaceFirst('#', '0xFF')
          : '0xFF${_category!.color}';
      return Color(int.parse(colorString));
    } catch (e) {
      return const Color(0xFF3425B5);
    }
  }

  Future<void> loadPlan(String planId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Récupérer la position utilisateur en premier
      await getUserLocation();

      // Load plan
      final planResult = await _planRepository.getPlanById(planId);
      if (planResult is Ok<Plan>) {
        _plan = planResult.value;
      } else {
        _setError('Échec du chargement du plan');
        return;
      }

      // Load steps
      final stepResults = await Future.wait(
        _plan!.steps.map((stepId) => _stepRepository.getStepById(stepId)),
      );
      _steps = stepResults
          .whereType<Ok<step_model.Step>>()
          .map((result) => result.value)
          .toList();

      // Load category
      final categoryResult =
          await _categoryRepository.getCategoryById(_plan!.category);
      if (categoryResult is Ok<Category>) {
        _category = categoryResult.value;
      } else {
        _setError('Échec du chargement de la catégorie');
      }

      // Initialiser les commentaires après que le plan soit chargé
      await initializeComments();
      // Charger les commentaires si l'utilisateur est disponible
      if (_currentUserId != null) {
        await loadComments(reset: true);
      }
    } catch (e) {
      _setError('Erreur inattendue: $e');
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

  Future<String?> getCurrentUserId() async {
    try {
      final userResult = await _userRepository.getCurrentUser();
      if (userResult is Ok<User>) {
        return userResult.value.id;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserProfile(String userId) async {
    try {
      final userResult = await _userRepository.getUserProfile(userId);
      if (userResult is Ok<User>) {
        return userResult.value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isFollowing(String userId) async {
    try {
      final currentUserResult = await _userRepository.getCurrentUser();
      if (currentUserResult is Ok<User>) {
        final currentUserId = currentUserResult.value.id;
        final result =
            await _userRepository.checkFollowing(currentUserId, userId);
        if (result is Ok<Map<String, dynamic>>) {
          return result.value['isFollowing'] == true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> followUser(String userId) async {
    try {
      final result = await _userRepository.followUser(userId);
      if (result is Ok<Map<String, dynamic>>) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      final result = await _userRepository.unfollowUser(userId);
      if (result is Ok<Map<String, dynamic>>) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> addToFavorites(String planId) async {
    try {
      final result = await _planRepository.addToFavorites(planId);
      if (result is Error) {
        throw Exception('Failed to add to favorites');
      }
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String planId) async {
    try {
      final result = await _planRepository.removeFromFavorites(planId);
      if (result is Error) {
        throw Exception('Failed to remove from favorites');
      }
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  Future<step_model.Step?> getStepById(String stepId) async {
    try {
      final stepResult = await _stepRepository.getStepById(stepId);
      if (stepResult is Ok<step_model.Step>) {
        return stepResult.value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Comment methods
  Future<List<Comment>> getCommentsByPlanId(String planId,
      {int page = 1, int limit = 10}) async {
    try {
      final result = await _commentRepository.getCommentsByPlanId(planId,
          page: page, limit: limit);
      if (result is Ok<List<Comment>>) {
        return result.value;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Comment?> createComment(Comment comment) async {
    try {
      final result = await _commentRepository.createComment(comment);
      if (result is Ok<Comment>) {
        return result.value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Comment?> updateComment(String commentId, Comment comment) async {
    try {
      final result = await _commentRepository.updateComment(commentId, comment);
      if (result is Ok<Comment>) {
        return result.value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      final result = await _commentRepository.deleteComment(commentId);
      return result is Ok;
    } catch (e) {
      return false;
    }
  }

  Future<Comment?> getCommentById(String commentId) async {
    try {
      final result = await _commentRepository.getCommentById(commentId);
      if (result is Ok<Comment>) {
        return result.value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> likeComment(String commentId) async {
    try {
      final result = await _commentRepository.likeComment(commentId);
      return result is Ok;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unlikeComment(String commentId) async {
    try {
      final result = await _commentRepository.unlikeComment(commentId);
      return result is Ok;
    } catch (e) {
      return false;
    }
  }

  Future<Comment?> addCommentResponse(
      String commentId, Comment response) async {
    try {
      final result =
          await _commentRepository.addCommentResponse(commentId, response);
      if (result is Ok<Comment>) {
        return result.value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Comment>> getCommentResponses(String commentId) async {
    try {
      final result = await _commentRepository.getCommentResponses(commentId);
      if (result is Ok<List<Comment>>) {
        return result.value;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> removeCommentResponse(
      String commentId, String responseId) async {
    try {
      final result =
          await _commentRepository.removeCommentResponse(commentId, responseId);
      return result is Ok;
    } catch (e) {
      return false;
    }
  }

  // Méthodes intégrées du CommentController
  Future<void> initializeComments() async {
    _currentUserId = await getCurrentUserId();
    notifyListeners();
  }

  Future<List<Comment>> loadComments(
      {bool reset = false, int currentPage = 1, int pageLimit = 10}) async {
    try {
      // Vérifier que le plan est disponible
      if (_plan?.id == null) {
        print('⚠️ Plan non disponible pour charger les commentaires');
        return [];
      }

      print('📝 Chargement des commentaires pour plan: ${_plan!.id}');
      final commentsData = await getCommentsByPlanId(_plan!.id!,
          page: currentPage, limit: pageLimit);

      print('📥 Commentaires reçus: ${commentsData.length}');
      for (var comment in commentsData) {
        print('   - ${comment.content} (${comment.id})');
      }

      if (commentsData.length < pageLimit) {
        _hasMoreComments = false;
      }

      if (reset) {
        _comments = commentsData;
      } else {
        _comments.addAll(commentsData);
      }

      for (final comment in commentsData) {
        if (comment.id != null && comment.responses.isNotEmpty) {
          loadResponsesForComment(comment.id!);
        }
      }

      notifyListeners();
      return commentsData;
    } catch (e) {
      print('❌ Erreur lors du chargement des commentaires : $e');
      return [];
    }
  }

  Future<void> loadResponsesForComment(String commentId) async {
    try {
      if (_responses.containsKey(commentId)) return;

      final responsesData = await getCommentResponses(commentId);
      _responses[commentId] = responsesData;
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des réponses pour $commentId : $e');
    }
  }

  // Updated saveComment method with image upload support
  Future<Comment?> saveComment(String content) async {
    if (_plan == null || currentUserId == null) return null;

    try {
      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
        if (imageUrl == null) {
          print('Échec de l\'upload d\'image');
          return null;
        }
      }
      final comment = Comment(
        content: content,
        userId: currentUserId!,
        planId: _plan!.id!,
        imageUrl: imageUrl,
      );

      final result = await _commentRepository.createComment(comment);

      switch (result) {
        case Ok<Comment>():
          final createdComment = result.value;
          _comments.insert(0, createdComment);

          // Clear selected image after successful save
          clearSelectedImage();

          notifyListeners();
          print('💬 Commentaire créé avec succès');
          return createdComment;

        case Error<Comment>():
          print('❌ Erreur lors de la création du commentaire: ${result.error}');
          return null;
      }
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde du commentaire: $e');
      return null;
    }
  }

  // Save response method with image support
  Future<Comment?> saveResponse(String commentId, String content) async {
    try {
      String? imageUrl;

      // Upload image if selected
      if (_selectedResponseImage != null) {
        _isUploadingResponseImage = true;
        notifyListeners();

        try {
          imageUrl = await _imgurService.uploadImage(_selectedResponseImage!);
        } catch (e) {
          print('Erreur lors de l\'upload d\'image de réponse: $e');
          _isUploadingResponseImage = false;
          notifyListeners();
          return null;
        }

        _isUploadingResponseImage = false;
        notifyListeners();
      }

      final response = Comment(
        content: content,
        userId: currentUserId!,
        planId: _plan!.id!,
        parentId: commentId,
        imageUrl: imageUrl,
      );

      final result =
          await _commentRepository.addCommentResponse(commentId, response);

      switch (result) {
        case Ok<Comment>():
          final createdResponse = result.value;

          // Add to responses map
          if (!_responses.containsKey(commentId)) {
            _responses[commentId] = [];
          }
          _responses[commentId]!.insert(0, createdResponse);

          // Update parent comment's responses list
          final parentCommentIndex =
              _comments.indexWhere((c) => c.id == commentId);
          if (parentCommentIndex != -1) {
            final parentComment = _comments[parentCommentIndex];
            final updatedResponses = List<String>.from(parentComment.responses);
            updatedResponses.add(createdResponse.id!);

            _comments[parentCommentIndex] = parentComment.copyWith(
              responses: updatedResponses,
            );
          }

          // Clear selected response image
          clearSelectedResponseImage();

          notifyListeners();
          print('💬 Réponse créée avec succès');
          return createdResponse;

        case Error<Comment>():
          print('❌ Erreur lors de la création de la réponse: ${result.error}');
          return null;
      }
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde de la réponse: $e');
      return null;
    }
  }

  Future<bool> toggleLike(Comment comment, bool isLiked) async {
    try {
      bool success;
      if (isLiked) {
        success = await unlikeComment(comment.id!);
      } else {
        success = await likeComment(comment.id!);
      }

      if (success) {
        final updatedLikes = List<String>.from(comment.likes);
        if (isLiked) {
          updatedLikes.remove(_currentUserId);
        } else {
          updatedLikes.add(_currentUserId!);
        }

        final updatedComment = comment.copyWith(likes: updatedLikes);

        final index = _comments.indexWhere((c) => c.id == comment.id);
        if (index != -1) {
          _comments[index] = updatedComment;
        } else {
          for (var entry in _responses.entries) {
            final responseIndex =
                entry.value.indexWhere((r) => r.id == comment.id);
            if (responseIndex != -1) {
              _responses[entry.key]![responseIndex] = updatedComment;
              break;
            }
          }
        }
        notifyListeners();
      }

      return success;
    } catch (e) {
      print('Erreur lors du like/unlike: $e');
      return false;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    _isUploadingImage = true;
    notifyListeners();

    try {
      final response = await _imgurService.uploadImage(imageFile);
      return response;
    } catch (e) {
      print("Erreur lors de l'upload: $e");
      return null;
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<String?> uploadResponseImage(File imageFile) async {
    _isUploadingResponseImage = true;
    notifyListeners();

    try {
      final response = await _imgurService.uploadImage(imageFile);
      return response;
    } catch (e) {
      print("Erreur lors de l'upload: $e");
      return null;
    } finally {
      _isUploadingResponseImage = false;
      notifyListeners();
    }
  }

  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void setSelectedResponseImage(File? image) {
    _selectedResponseImage = image;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    _existingImageUrl = null;
    notifyListeners();
  }

  void clearSelectedResponseImage() {
    _selectedResponseImage = null;
    _existingImageUrl = null;
    notifyListeners();
  }

  void toggleResponsesVisibility(String commentId) {
    _showAllResponsesMap[commentId] =
        !(_showAllResponsesMap[commentId] ?? false);
    notifyListeners();
  }

  String formatTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 8) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}j';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }

  // Map methods
  double? _userLatitude;
  double? _userLongitude;

  bool get hasMapData =>
      stepsWithPosition.isNotEmpty ||
      (_userLatitude != null && _userLongitude != null);

  // Retourne la première position trouvée ou la position de l'utilisateur ou Paris par défaut
  Map<String, double> get mapCenterPosition {
    final stepsWithPos = stepsWithPosition;
    if (stepsWithPos.isNotEmpty) {
      final firstStep = stepsWithPos.first;
      return {
        'latitude': firstStep.position!.latitude,
        'longitude': firstStep.position!.longitude,
      };
    }

    // Position de l'utilisateur si disponible
    if (_userLatitude != null && _userLongitude != null) {
      return {
        'latitude': _userLatitude!,
        'longitude': _userLongitude!,
      };
    }

    // Position par défaut : Paris
    return {
      'latitude': 48.8566,
      'longitude': 2.3522,
    };
  }

  // Méthode pour récupérer la position de l'utilisateur
  Future<void> getUserLocation() async {
    try {
      // Import à ajouter : import 'package:geolocator/geolocator.dart';
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 Service de localisation désactivé');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('📍 Permission de localisation refusée');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('📍 Permission de localisation refusée définitivement');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _userLatitude = position.latitude;
      _userLongitude = position.longitude;
      print('📍 Position utilisateur: ${_userLatitude}, ${_userLongitude}');
      notifyListeners();
    } catch (e) {
      print('❌ Erreur lors de la récupération de la position: $e');
    }
  }

  // Retourne les étapes avec position pour les marqueurs
  List<step_model.Step> get stepsWithPosition =>
      _steps.where((step) => step.position != null).toList();

  // Vérifie si on doit afficher la map (toujours true maintenant)
  bool get shouldShowMap => true;
}
