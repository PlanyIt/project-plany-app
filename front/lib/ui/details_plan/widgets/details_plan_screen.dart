import 'package:flutter/material.dart';
import 'package:front/ui/details_plan/view_models/details_plan_viewmodel.dart';
import 'package:front/ui/details_plan/widgets/content/plan_content.dart';
import 'package:front/ui/details_plan/widgets/header/details_header.dart';

class DetailScreen extends StatefulWidget {
  final DetailsPlanViewModel viewModel;
  final String planId;

  const DetailScreen({
    super.key,
    required this.viewModel,
    required this.planId,
  });

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadPlan(widget.planId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, child) {
        if (widget.viewModel.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    widget.viewModel.categoryColor),
              ),
            ),
          );
        }

        if (widget.viewModel.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.loadPlan(widget.planId),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final plan = widget.viewModel.plan;
        final steps = widget.viewModel.steps;
        final category = widget.viewModel.category;

        if (plan == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Plan non trouvé')),
            body: const Center(
              child: Text('Ce plan n\'existe pas ou n\'est plus disponible'),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              // Carte en arrière-plan (plein écran)
              if (steps.isNotEmpty)
                DetailsHeader(
                  stepIds: plan.steps,
                  category: category?.name ?? 'Général',
                  categoryColor: widget.viewModel.categoryColor,
                  viewModel: widget.viewModel,
                  planTitle: plan.title,
                  planDescription: plan.description,
                ),

              // Contenu défilable par-dessus
              DraggableScrollableSheet(
                controller: _scrollController,
                initialChildSize: 0.4,
                minChildSize: 0.4,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return PlanContent(
                    plan: plan,
                    categoryColor: widget.viewModel.categoryColor,
                    scrollController: scrollController,
                    viewModel: widget.viewModel,
                    category: category,
                    steps: steps,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
