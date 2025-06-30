import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/utils/result.dart';
import 'package:front/providers/providers.dart';
import 'package:front/providers/ui/unified_state_management.dart';
import 'dart:io';

// État pour le profil utilisateur
class ProfileState extends UnifiedState {
  final User? user;
  final List<Plan> userPlans;
  final List<Plan> favorites;
  final List<Category> categories;

  const ProfileState({
    this.user,
    this.userPlans = const [],
    this.favorites = const [],
    this.categories = const [],
    super.isLoading = false,
    super.error,
    super.isInitialized = false,
  });

  ProfileState copyWith({
    User? user,
    List<Plan>? userPlans,
    List<Plan>? favorites,
    List<Category>? categories,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return ProfileState(
      user: user ?? this.user,
      userPlans: userPlans ?? this.userPlans,
      favorites: favorites ?? this.favorites,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  ProfileState copyWithBase({
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return copyWith(
      isLoading: isLoading,
      error: error,
      isInitialized: isInitialized,
    );
  }

  @override
  ProfileState clearError() {
    return copyWith(error: null);
  }

  @override
  ProfileState reset() {
    return const ProfileState();
  }
}

class ProfileNotifier extends StateNotifier<ProfileState>
    with UnifiedStateManagement<ProfileState> {
  ProfileNotifier(
    this._userRepository,
    this._planRepository,
    this._categoryRepository,
  ) : super(const ProfileState());

  final UserRepository _userRepository;
  final PlanRepository _planRepository;
  final CategoryRepository _categoryRepository;

  Future<void> loadProfile() async {
    await executeWithStateManagement(
      () async {
        final userResult = await _userRepository.getCurrentUser();
        switch (userResult) {
          case Ok<User>():
            state = state.copyWith(user: userResult.value);
            await _loadUserData(userResult.value.id);
            break;
          case Error<User>():
            throw Exception('Erreur lors du chargement du profil');
        }
      },
    );
  }

  Future<void> _loadUserData(String userId) async {
    // Charger les plans de l'utilisateur
    final plansResult = await _planRepository.getPlansByUserId(userId);
    List<Plan> userPlans = [];
    if (plansResult is Ok<List<Plan>>) {
      userPlans = plansResult.value;
    }

    // Charger les favoris
    final favoritesResult = await _planRepository.getFavoritesByUserId(userId);
    List<Plan> favorites = [];
    if (favoritesResult is Ok<List<Plan>>) {
      favorites = favoritesResult.value;
    }

    // Charger les catégories
    final categoriesResult = await _categoryRepository.getCategoriesList();
    List<Category> categories = [];
    if (categoriesResult is Ok<List<Category>>) {
      categories = categoriesResult.value;
    }

    state = state.copyWith(
      userPlans: userPlans,
      favorites: favorites,
      categories: categories,
    );
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (state.user == null) return false;

    return await executeWithStateManagement(
          () async {
            final result = await _userRepository.patchCurrentUser(data);
            switch (result) {
              case Ok<User>():
                state = state.copyWith(user: result.value);
                return true;
              case Error<User>():
                throw Exception('Erreur lors de la mise à jour du profil');
            }
          },
        ) ??
        false;
  }

  Future<bool> updateProfilePhoto(File imageFile) async {
    if (state.user == null) return false;

    return await executeWithStateManagement(
          () async {
            final result = await _userRepository.updateUserPhoto(
                state.user!.id, imageFile.path);
            switch (result) {
              case Ok<User>():
                state = state.copyWith(user: result.value);
                return true;
              case Error<User>():
                throw Exception('Erreur lors de la mise à jour de la photo');
            }
          },
        ) ??
        false;
  }

  void clearProfileError() {
    clearError();
  }
}

// Utiliser StateNotifierProvider pour une gestion d'état cohérente avec Riverpod
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.read(userRepositoryProvider),
    ref.read(planRepositoryProvider),
    ref.read(categoryRepositoryProvider),
  );
});
