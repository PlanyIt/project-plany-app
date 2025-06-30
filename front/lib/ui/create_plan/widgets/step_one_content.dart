import 'package:flutter/material.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/ui/core/theme/app_theme.dart';
import 'package:front/ui/core/ui/widgets/button/select_button.dart';
import 'package:front/ui/create_plan/view_models/create_plan_viewmodel.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/ui/core/ui/widgets/modal/grid_selector_modal.dart';

class StepOneContent extends StatefulWidget {
  const StepOneContent({super.key, required this.viewModel});

  final CreatePlanViewModel viewModel;

  @override
  State<StepOneContent> createState() => _StepOneContentState();
}

class _StepOneContentState extends State<StepOneContent> {
  Widget buildCategorySelector(BuildContext context) {
    if (widget.viewModel.selectedCategory == null) {
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
          onPressed: () => _showCategoryBottomSheet(context),
          leadingIcon: Icons.category_outlined,
          trailingIcon: Icons.arrow_forward_ios,
        ),
      );
    } else {
      return InkWell(
        onTap: () => _showCategoryBottomSheet(context),
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
                  getIconData(widget.viewModel.selectedCategory!.icon),
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
                      widget.viewModel.selectedCategory!.name,
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

  void _showCategoryBottomSheet(BuildContext context) {
    GridSelectorModal.show<Category>(
      context: context,
      items: widget.viewModel.categories,
      selectedItem: widget.viewModel.selectedCategory,
      title: 'Choisir une catégorie',
      onItemSelected: (category) {
        widget.viewModel.setCategory(category);
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
          _buildTextField(
            context: context,
            title: 'Titre du plan',
            hint: 'Ex: Weekend à Paris, Randonnée en montagne...',
            controller: widget.viewModel.titlePlanController,
            icon: Icons.title,
            maxLines: 1,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            context: context,
            title: 'Description',
            hint:
                'Décrivez votre plan en détail pour donner envie aux autres utilisateurs de le suivre...',
            controller: widget.viewModel.descriptionPlanController,
            icon: Icons.description,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Catégorie'),
          const SizedBox(height: 16),
          buildCategorySelector(context),
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
    required TextEditingController controller,
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
            controller: controller,
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
}
