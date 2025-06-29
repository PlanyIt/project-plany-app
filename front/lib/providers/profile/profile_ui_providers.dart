import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/category/category.dart';

// ============================================================================
// PROVIDERS POUR LE PROFIL UTILISATEUR
// ============================================================================

// État principal du profil
final profilUserProvider =
    StateProvider.family<User?, String>((ref, userId) => null);
final profilLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final profilSelectedSectionProvider = StateProvider<String>((ref) => 'plans');

// Mes plans
final myPlansProvider =
    StateProvider.family<List<Plan>, String>((ref, userId) => []);
final myPlansLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final myPlansDisplayLimitProvider = StateProvider<int>((ref) => 5);

// Favoris
final favoritesDisplayLimitProvider = StateProvider<int>((ref) => 5);

// Followers/Following
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

// Catégories du profil
final profileCategoriesProvider =
    StateProvider.family<List<Category>, String>((ref, userId) => []);
final profileCategoriesLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final myCategoriesProvider = StateProvider<List<Category>>((ref) => []);

// Paramètres
final settingsLoadingProvider = StateProvider<bool>((ref) => false);
