import 'package:flutter/material.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:front/screens/create-plan/stepModal.dart';
import 'package:front/widgets/button/add_button.dart';
import 'package:front/widgets/card/empty_card.dart';
import 'package:front/widgets/card/step_card_timeline.dart';
import 'package:provider/provider.dart';

class StepTwoContent extends StatefulWidget {
  const StepTwoContent({super.key});

  @override
  State<StepTwoContent> createState() => _StepTwoContentState();
}

class _StepTwoContentState extends State<StepTwoContent> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreatePlanProvider>(context);
    final themeColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 8),
          child: Text(
            'Étapes du plan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        provider.stepCards.isEmpty
            ? EmptyCard(
                title: 'Aucune étape ajoutée',
                message: 'Commencez à créer votre plan en ajoutant des étapes',
                icon: Icons.playlist_add,
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.stepCards.length,
                  onReorder: (oldIndex, newIndex) {
                    provider.reorderStepCards(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final step = provider.stepCards[index];
                    final isFirst = index == 0;
                    final isLast = index == provider.stepCards.length - 1;

                    return StepCardTimeline(
                      key: Key('step_card_$index'),
                      index: index,
                      isFirst: isFirst,
                      isLast: isLast,
                      title: step.title,
                      description: step.description,
                      imagePath: step.imageUrl,
                      duration: step.duration,
                      durationUnit: step.durationUnit,
                      cost: step.cost,
                      locationName: step.locationName,
                      onDelete: () => provider.removeStepCard(index),
                      themeColor: themeColor,
                    );
                  },
                ),
              ),

        const SizedBox(height: 24),
        AddButton(
          label: 'Ajouter une étape',
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return ChangeNotifierProvider<CreatePlanProvider>.value(
                  value: provider,
                  child: const StepModal(),
                );
              },
            );
          },
        ),

        const SizedBox(height: 100),
      ],
    );
  }
}
