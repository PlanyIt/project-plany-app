import 'package:flutter/material.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/widgets/button/select_button.dart';
import 'package:front/widgets/modal/grid_selector_modal.dart';
import 'package:provider/provider.dart';

Widget buildCategorySelector(BuildContext context) {
  final provider = Provider.of<CreatePlanProvider>(context);

  if (provider.selectedCategory == null) {
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
                getIconData(provider.selectedCategory!.icon),
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
                    provider.selectedCategory!.name,
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

// ...existing code...

void _showCategoryBottomSheet(BuildContext context) {
  final provider = Provider.of<CreatePlanProvider>(context, listen: false);

  GridSelectorModal.show<Category>(
    context: context,
    items: provider.categories,
    selectedItem: provider.selectedCategory,
    title: 'Choisir une catégorie',
    onItemSelected: (category) {
      provider.setCategory(category);
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
              color:
                  isSelected ? Theme.of(context).primaryColor : Colors.black87,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            cat.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color:
                  isSelected ? Theme.of(context).primaryColor : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    },
  );
}
