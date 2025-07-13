import 'package:flutter/material.dart';

import '../../../core/ui/card/compact_plan_card.dart';
import '../../view_models/my_plan_viewmodel.dart';
import '../common/section_header.dart';

class MyPlansSection extends StatelessWidget {
  final MyPlansViewModel viewModel;

  const MyPlansSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final plans = viewModel.displayedPlans;
    if (plans.isEmpty) {
      return const Center(
        child: Text('Aucun plan créé'),
      );
    }

    return Column(
      children: [
        SectionHeader(
          title: "Plans Créés",
          subtitle: "${viewModel.totalPlans} plans créés",
          icon: Icons.map_rounded,
          gradientColors: const [Colors.purple, Colors.purpleAccent],
        ),
        ...plans.map((plan) => CompactPlanCard(
              title: plan.title,
              description: plan.description,
              // ...
            )),
        if (viewModel.totalPlans > viewModel.displayLimit)
          ElevatedButton(
            onPressed: viewModel.showMore,
            child: const Text('Afficher plus'),
          ),
      ],
    );
  }
}
