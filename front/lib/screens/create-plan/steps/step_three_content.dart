import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:front/widgets/card/plan_card.dart';
import 'package:front/widgets/card/step_card_timeline.dart';
import 'package:provider/provider.dart';

class StepThreeContent extends StatelessWidget {
  const StepThreeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreatePlanProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 8),
          child: Text(
            'Vérifier votre plan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        PlanCard(
          title: provider.titlePlanController.text,
          description: provider.descriptionPlanController.text,
          category: provider.selectedCategory,
          stepsCount: provider.stepCards.length,
        ),

        const SizedBox(height: 24),

        if (provider.stepCards.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 8),
            child: Text(
              'Étapes',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: provider.stepCards.length,
            itemBuilder: (context, index) {
              final step = provider.stepCards[index];
              return StepCardTimeline(
                index: index,
                isFirst: index == 0,
                isLast: index == provider.stepCards.length - 1,
                title: step.title,
                description: step.description,
                imagePath: step.imageUrl.isNotEmpty ? step.imageUrl : null,
                duration: step.duration,
                durationUnit: step.durationUnit,
                cost: step.cost,
                locationName: step.locationName,
                themeColor: Theme.of(context).primaryColor,
              );
            },
          ),
        ],

        const SizedBox(height: 16),

        // Publication notice
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.09),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).primaryColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.circleInfo,
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prêt à publier ?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Après publication, votre plan sera visible par tous les utilisateurs.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 150),
      ],
    );
  }
}
