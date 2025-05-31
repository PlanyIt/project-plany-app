import 'package:flutter/material.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:front/screens/create-plan/widgets/build_category_selector.dart';
import 'package:front/widgets/section/section_text_field.dart';
import 'package:provider/provider.dart';

class StepOneContent extends StatelessWidget {
  const StepOneContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreatePlanProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTextField(
          title: 'Titre du plan',
          controller: provider.titlePlanController,
          labelText: "Donnez un titre attractif",
        ),
        const SizedBox(height: 24),
        SectionTextField(
          title: 'Description',
          controller: provider.descriptionPlanController,
          labelText: "Décrivez votre plan en détail",
          maxLines: 5,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 8),
          child: Text(
            'Catégorie',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        buildCategorySelector(context),
        const SizedBox(height: 10),
      ],
    );
  }
}
