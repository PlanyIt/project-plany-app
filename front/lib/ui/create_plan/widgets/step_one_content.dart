import 'package:flutter/material.dart';

import '../../../domain/models/category/category.dart';
import '../../../utils/icon_utils.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/create_plan_view_model.dart';
import 'grid_selector_modal.dart';

class StepOneContent extends StatelessWidget {
  const StepOneContent({super.key, required this.viewModel});

  final CreatePlanViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildValueTextField(
            key: const Key('titleField'),
            context: context,
            title: 'Titre du plan',
            hint: 'Ex: Weekend à Paris, Randonnée en montagne...',
            icon: Icons.title,
            valueNotifier: viewModel.title,
            maxLines: 1,
          ),
          const SizedBox(height: 24),
          _buildValueTextField(
            key: const Key('descriptionField'),
            context: context,
            title: 'Description',
            hint: 'Décrivez votre plan en détail...',
            icon: Icons.description,
            valueNotifier: viewModel.description,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Catégorie'),
          const SizedBox(height: 16),
          _buildCategorySelector(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildValueTextField({
    required Key key,
    required BuildContext context,
    required String title,
    required String hint,
    required IconData icon,
    required ValueNotifier<String> valueNotifier,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
        const SizedBox(height: 12),
        ValueListenableBuilder<String>(
          valueListenable: valueNotifier,
          builder: (context, value, _) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                key: key,
                onChanged: (text) => valueNotifier.value = text,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: value,
                    selection: TextSelection.collapsed(offset: value.length),
                  ),
                ),
                maxLines: maxLines,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: Icon(icon, color: AppTheme.primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            );
          },
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: .8),
            AppTheme.secondaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline,
                color: Colors.white, size: 28),
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
                      fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Commencez par donner un titre, une description et choisir une catégorie pour votre plan',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final selected = viewModel.selectedCategory;

    return InkWell(
      onTap: () => _showCategoryBottomSheet(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected == null
              ? Colors.white
              : Theme.of(context).primaryColor.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected == null
                ? Colors.grey.withValues(alpha: .3)
                : Theme.of(context).primaryColor.withValues(alpha: .3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected == null
                  ? Icons.category_outlined
                  : getIconData(selected.icon),
              color: selected == null
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                selected?.name ?? 'Choisir une catégorie',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: selected == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: selected == null
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryBottomSheet(BuildContext context) {
    GridSelectorModal.show<Category>(
      context: context,
      items: viewModel.categories,
      selectedItem: viewModel.selectedCategory,
      title: 'Choisir une catégorie',
      onItemSelected: viewModel.setCategory,
      itemBuilder: (context, cat, isSelected) {
        return Column(
          key: Key('category_${cat.id}'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: .1)
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
