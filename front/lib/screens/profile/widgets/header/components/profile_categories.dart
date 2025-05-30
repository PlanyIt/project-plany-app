import 'package:flutter/material.dart';
import 'package:front/models/categorie.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/services/user_service.dart';
import 'package:front/utils/icon_utils.dart';

class ProfileCategories extends StatefulWidget {
  final String userId;

  const ProfileCategories({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileCategories> createState() => _ProfileCategoriesState();
}

class _ProfileCategoriesState extends State<ProfileCategories> {
  final CategorieService _categorieService = CategorieService();
  final UserService _userService = UserService();
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
    try {
      final userPlans = await _userService.getUserPlans(widget.userId);
      if (userPlans.isEmpty) {
        print('Aucun plan trouvé pour l\'utilisateur');
        return [];
      }
      final categoryIds = userPlans
          .where((plan) => plan.category != null)
          .map((plan) => plan.category)
          .toSet()
          .toList();

      if (categoryIds.isEmpty) {
        return [];
      }

      final allCategories = await _categorieService.getCategories();

      final userCategories = allCategories
          .where((category) => categoryIds.contains(category.id))
          .toList();

      return userCategories;
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      return [];
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
                      category.name,
                      category.icon 
                      );
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
        color: const Color(0xFF3425B5).withOpacity(0.08),
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