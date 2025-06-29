import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/domain/models/step/step.dart' as plan_steps;

// ============================================================================
// PROVIDERS UI CENTRALISÉS - Regroupement de tous les providers UI éparpillés
// ============================================================================

// Providers de base pour les composants UI
final passwordVisibilityProvider =
    StateProvider.family<bool, String>((ref, fieldId) => true);
final loadingStateProvider =
    StateProvider.family<bool, String>((ref, componentId) => false);
final errorStateProvider =
    StateProvider.family<String?, String>((ref, componentId) => null);

// Providers pour les boutons avec effet de pression
final buttonPressStateProvider =
    StateProvider.family<bool, String>((ref, buttonId) => false);

// Providers pour Create Plan Screen
final createPlanCurrentStepProvider = StateProvider<int>((ref) => 1);
final createPlanIsPublishingProvider = StateProvider<bool>((ref) => false);

// Providers pour Step Modal
final stepModalCurrentTabProvider =
    StateProvider.family<int, String>((ref, modalId) => 0);
final stepModalTitleProvider = StateProvider<String>((ref) => '');
final stepModalDescriptionProvider = StateProvider<String>((ref) => '');
final stepModalDurationProvider = StateProvider<String>((ref) => '');
final stepModalCostProvider = StateProvider<String>((ref) => '');
final stepModalSelectedUnitProvider = StateProvider<String>((ref) => 'Heures');
final stepModalSelectedImageProvider = StateProvider<File?>((ref) => null);
final stepModalSelectedLocationProvider = StateProvider<dynamic>((ref) => null);
final stepModalSelectedLocationNameProvider =
    StateProvider<String?>((ref) => null);

// Providers pour Create Plan - Step One
final stepOneTitleProvider = StateProvider<String>((ref) => '');
final stepOneDescriptionProvider = StateProvider<String>((ref) => '');
final stepOneSelectedCategoryProvider = StateProvider<Category?>((ref) => null);
final stepOneCategoriesProvider = StateProvider<List<Category>>((ref) => []);

// Providers pour Create Plan - Step Two
final stepTwoStepsProvider = StateProvider<List<plan_steps.Step>>((ref) => []);
final stepTwoCurrentStepIndexProvider = StateProvider<int>((ref) => 0);

// Providers pour Create Plan - Step Three
final stepThreeIsPublishingProvider = StateProvider<bool>((ref) => false);

// Providers pour les détails de plan
final planFavoriteStateProvider =
    StateProvider.family<bool, String>((ref, planId) => false);
final planFavoritesCountProvider =
    StateProvider.family<int, String>((ref, planId) => 0);
final planAuthorProvider =
    StateProvider.family<User?, String>((ref, planId) => null);
final planFollowStateProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final planProcessingStateProvider =
    StateProvider.family<bool, String>((ref, planId) => false);

// Providers pour la carte et navigation
final mapStepsProvider =
    StateProvider.family<List<plan_steps.Step>, List<String>>(
        (ref, stepIds) => []);
final mapIsLoadingProvider =
    StateProvider.family<bool, String>((ref, mapId) => true);
final mapCurrentStepIndexProvider =
    StateProvider.family<int, String>((ref, mapId) => 0);
final mapHasCenteredProvider =
    StateProvider.family<bool, String>((ref, mapId) => false);

// Providers pour Header des détails
final headerStepsProvider =
    StateProvider.family<List<plan_steps.Step>, List<String>>(
        (ref, stepIds) => []);
final headerIsLoadingProvider =
    StateProvider.family<bool, String>((ref, headerId) => true);
final headerCurrentStepIndexProvider =
    StateProvider.family<int, String>((ref, headerId) => 0);
final headerShowStepInfoProvider =
    StateProvider.family<bool, String>((ref, headerId) => false);
final headerSelectedStepProvider =
    StateProvider.family<plan_steps.Step?, String>((ref, headerId) => null);
final headerDistanceToStepProvider =
    StateProvider.family<double?, String>((ref, headerId) => null);

// Providers pour le profil
final profilUserProvider =
    StateProvider.family<User?, String>((ref, userId) => null);
final profilLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final profilSelectedSectionProvider = StateProvider<String>((ref) => 'plans');

// Providers pour les plans de l'utilisateur
final myPlansProvider =
    StateProvider.family<List<Plan>, String>((ref, userId) => []);
final myPlansLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final myPlansDisplayLimitProvider = StateProvider<int>((ref) => 5);

// Providers pour les favoris
final favoritesDisplayLimitProvider = StateProvider<int>((ref) => 5);

// Providers pour les followers/following
final followersProvider =
    StateProvider.family<List<User>, String>((ref, userId) => []);
final followersLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final followingProvider =
    StateProvider.family<List<User>, String>((ref, userId) => []);
final followingLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final followingStatusProvider = StateProvider<Map<String, bool>>((ref) => {});
final loadingUserIdsProvider = StateProvider<Set<String>>((ref) => {});
final followingLoadingUserIdsProvider = StateProvider<Set<String>>((ref) => {});

// Providers pour les catégories du profil
final profileCategoriesProvider =
    StateProvider.family<List<Category>, String>((ref, userId) => []);
final profileCategoriesLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final myCategoriesProvider = StateProvider<List<Category>>((ref) => []);

// Providers pour les paramètres
final settingsLoadingProvider = StateProvider<bool>((ref) => false);

// Providers pour les commentaires
final commentsProvider =
    StateProvider.family<List<Comment>, String>((ref, planId) => []);
final selectedImageProvider = StateProvider<File?>((ref) => null);
final isUploadingImageProvider = StateProvider<bool>((ref) => false);

// Provider pour les états de carousel d'images
final imageCarouselProvider = StateNotifierProvider.family<
    ImageCarouselNotifier, ImageCarouselState, String>((ref, carouselId) {
  return ImageCarouselNotifier();
});

class ImageCarouselState {
  final int currentPage;
  final bool isLoading;

  const ImageCarouselState({
    this.currentPage = 0,
    this.isLoading = false,
  });

  ImageCarouselState copyWith({
    int? currentPage,
    bool? isLoading,
  }) {
    return ImageCarouselState(
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ImageCarouselNotifier extends StateNotifier<ImageCarouselState> {
  ImageCarouselNotifier() : super(const ImageCarouselState());

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

// ============================================================================
// MIXINS DE GESTION D'ÉTAT POUR WIDGETS
// ============================================================================

/// Mixin pour standardiser la gestion d'état avec Riverpod
/// À utiliser avec ConsumerWidget ou ConsumerStatefulWidget
mixin StateManagementMixin {
  /// Méthode helper pour gérer les erreurs de façon unifiée
  void handleError(WidgetRef ref, dynamic error, [String? context]) {
    final errorMessage = _mapErrorToUserMessage(error);
    // Log l'erreur avec le contexte si fourni
    debugPrint('Erreur ${context ?? ''}: $errorMessage');
  }

  /// Méthode helper pour gérer les états de chargement
  void setLoadingState(WidgetRef ref, bool isLoading, [String? componentId]) {
    if (componentId != null) {
      ref.read(loadingStateProvider(componentId).notifier).state = isLoading;
    }
  }

  /// Méthode helper pour gérer la visibilité des mots de passe
  void togglePasswordVisibility(WidgetRef ref, String fieldId) {
    final currentValue = ref.read(passwordVisibilityProvider(fieldId));
    ref.read(passwordVisibilityProvider(fieldId).notifier).state =
        !currentValue;
  }

  /// Méthode helper pour obtenir la visibilité d'un mot de passe
  bool getPasswordVisibility(WidgetRef ref, String fieldId) {
    return ref.watch(passwordVisibilityProvider(fieldId));
  }

  /// Méthode helper pour vérifier l'état de chargement d'un composant
  bool isLoading(WidgetRef ref, String componentId) {
    return ref.watch(loadingStateProvider(componentId));
  }

  String _mapErrorToUserMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }
    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'Vous n\'avez pas les permissions nécessaires.';
    }
    if (errorString.contains('500') || errorString.contains('server error')) {
      return 'Erreur du serveur. Réessayez plus tard.';
    }
    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Ressource introuvable';
    }
    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return 'Données invalides. Vérifiez vos informations.';
    }
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Problème de connexion. Vérifiez votre réseau.';
    }

    return 'Une erreur inattendue s\'est produite';
  }
}
