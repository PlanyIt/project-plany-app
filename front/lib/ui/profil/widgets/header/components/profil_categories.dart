import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/providers/providers.dart';
import 'package:front/core/utils/icon_utils.dart';
import 'package:front/core/utils/result.dart';

// Providers pour l'état des catégories du profil
final profileCategoriesProvider =
    StateProvider.family<List<Category>, String>((ref, userId) => []);
final profileCategoriesLoadingProvider =
    StateProvider.family<bool, String>((ref, userId) => false);

class ProfileCategories extends ConsumerStatefulWidget {
  final String userId;

  const ProfileCategories({
    super.key,
    required this.userId,
  });
  @override
  ConsumerState<ProfileCategories> createState() => _ProfilCategoriesState();
}

class _ProfilCategoriesState extends ConsumerState<ProfileCategories> {
  Future<List<Category>>? _userCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _userCategoriesFuture = _loadUserCategories();
    });
  }

  Future<List<Category>> _loadUserCategories() async {
    ref.read(profileCategoriesLoadingProvider(widget.userId).notifier).state =
        true;

    try {
      final planRepository = ref.read(planRepositoryProvider);
      final categoryRepository = ref.read(categoryRepositoryProvider);

      // Charger les plans de l'utilisateur
      final plansResult = await planRepository.getPlansByUserId(widget.userId);

      if (plansResult is Ok<List<Plan>>) {
        final plans = plansResult.value;

        if (plans.isEmpty) {
          print('Aucun plan trouvé pour l\'utilisateur');
          return [];
        }

        // Extraire les IDs de catégories uniques
        final categoryIds = plans.map((plan) => plan.category).toSet().toList();

        if (categoryIds.isEmpty) {
          return [];
        }

        // Charger toutes les catégories
        final categoriesResult = await categoryRepository.getCategoriesList();

        if (categoriesResult is Ok<List<Category>>) {
          final allCategories = categoriesResult.value;

          // Filtrer les catégories utilisées par l'utilisateur
          final userCategories = allCategories
              .where((category) => categoryIds.contains(category.id))
              .toList();

          // Mettre à jour le provider
          ref.read(profileCategoriesProvider(widget.userId).notifier).state =
              userCategories;

          return userCategories;
        }
      }

      return [];
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      return [];
    } finally {
      ref.read(profileCategoriesLoadingProvider(widget.userId).notifier).state =
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.yellow[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Mes activités préférées",
                style: TextStyle(
                  color: Colors.grey[850],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Category>>(
            future: _userCategoriesFuture ?? Future.value([]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Text(
                  "Impossible de charger les catégories",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              }

              final categories = snapshot.data!;

              if (categories.isEmpty) {
                return Text(
                  "Aucune catégorie utilisée pour l'instant",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                );
              }

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((category) {
                  return _buildActivityTagWithIcon(
                      category.name, category.icon);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTagWithIcon(String text, String? iconName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3425B5).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getIconData(iconName ?? "category"),
            size: 14,
            color: const Color(0xFF3425B5),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3425B5),
            ),
          ),
        ],
      ),
    );
  }
}
