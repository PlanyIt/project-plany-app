import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/ui/core/theme/app_theme.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/shared/widgets/button/select_button.dart';
import 'package:front/shared/widgets/modal/grid_selector_modal.dart';
import 'package:front/providers/plan/plan_ui_providers.dart';

class StepOneContent extends ConsumerWidget {
  const StepOneContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(stepOneTitleProvider);
    final description = ref.watch(stepOneDescriptionProvider);
    final selectedCategory = ref.watch(stepOneSelectedCategoryProvider);
    final categories = ref.watch(stepOneCategoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildTextField(
            context: context,
            title: 'Titre du plan',
            hint: 'Ex: Weekend à Paris, Randonnée en montagne...',
            value: title,
            onChanged: (value) =>
                ref.read(stepOneTitleProvider.notifier).state = value,
            icon: Icons.title,
            maxLines: 1,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            context: context,
            title: 'Description',
            hint:
                'Décrivez votre plan en détail pour donner envie aux autres utilisateurs de le suivre...',
            value: description,
            onChanged: (value) =>
                ref.read(stepOneDescriptionProvider.notifier).state = value,
            icon: Icons.description,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Catégorie'),
          const SizedBox(height: 16),
          _buildCategorySelector(context, ref, selectedCategory, categories),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.8),
            AppTheme.secondaryColor,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Créez votre plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Commencez par donner un titre, une description et choisir une catégorie pour votre plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String title,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    required IconData icon,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: TextEditingController(text: value)
              ..selection = TextSelection.fromPosition(
                  TextPosition(offset: value.length)),
            onChanged: onChanged,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(icon, color: AppTheme.primaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, WidgetRef ref,
      Category? selectedCategory, List<Category> categories) {
    if (selectedCategory == null) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SelectButton(
          text: "Choisir une catégorie",
          onPressed: () => _showCategoryBottomSheet(context, ref),
          leadingIcon: Icons.category_outlined,
          trailingIcon: Icons.arrow_forward_ios,
        ),
      );
    } else {
      return InkWell(
        onTap: () => _showCategoryBottomSheet(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  getIconData(selectedCategory.icon),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catégorie sélectionnée',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      selectedCategory.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showCategoryBottomSheet(BuildContext context, WidgetRef ref) {
    GridSelectorModal.show<Category>(
      context: context,
      items: ref.read(stepOneCategoriesProvider),
      selectedItem: ref.read(stepOneSelectedCategoryProvider),
      title: 'Choisir une catégorie',
      onItemSelected: (category) {
        ref.read(stepOneSelectedCategoryProvider.notifier).state = category;
      },
      itemBuilder: (context, cat, isSelected) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Icon(
                getIconData(cat.icon),
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cat.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
