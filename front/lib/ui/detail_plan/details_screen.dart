import 'package:flutter/material.dart';
import '../../services/categorie_service.dart';
import '../../services/plan_service.dart';
import '../../services/step_service.dart';
import 'view_models/plan_detail_view_model.dart';
import 'widgets/content/plan_content.dart';
import 'widgets/header/details_header.dart';

final GlobalKey<DetailsHeaderState> _headerKey =
    GlobalKey<DetailsHeaderState>();

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final PlanDetailViewModel viewModel;
  final DraggableScrollableController _bottomSheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    viewModel = PlanDetailViewModel(
      planService: PlanService(),
      stepService: StepService(),
      categorieService: CategorieService(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final planId = ModalRoute.of(context)?.settings.arguments as String?;
      if (planId != null) {
        viewModel.fetchPlanDetails(planId);
      }
    });
  }

  @override
  void dispose() {
    _bottomSheetController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor.withAlpha(180),
                ),
              ),
            ),
          );
        }

        if (viewModel.plan == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Impossible de charger les détails du plan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          );
        }

        final plan = viewModel.plan!;
        final categoryColor = viewModel.categoryColor;

        return Scaffold(
          body: Stack(
            children: [
              plan.steps.isNotEmpty
                  ? DetailsHeader(
                      key: _headerKey,
                      stepIds: plan.steps.map((e) => e.id ?? '').toList(),
                      category: plan.category?.id ?? '',
                      categoryColor: categoryColor,
                      planTitle: plan.title,
                      planDescription: plan.description,
                    )
                  : Image.network(
                      "https://www.vivre-a-niort.com/fileadmin/_processed_/a/5/csm_Coucher_de_soleil_pris_depuis_le_Moulin_du_Roc__c__TOUTATIS_Drone_3168e85b55.jpg",
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
              DraggableScrollableSheet(
                initialChildSize: 0.2,
                minChildSize: 0.2,
                maxChildSize: 0.9,
                controller: _bottomSheetController,
                builder: (context, scrollController) {
                  return PlanContent(
                    plan: plan,
                    categoryColor: categoryColor,
                    scrollController: scrollController,
                    category: viewModel.category,
                    steps: viewModel.steps,
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
