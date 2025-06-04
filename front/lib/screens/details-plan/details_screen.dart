import 'package:flutter/material.dart';
import 'package:front/domain/models/category.dart';
import 'package:front/screens/details-plan/widgets/content/plan_content.dart';
import 'package:front/screens/details-plan/widgets/header/details_header.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/domain/models/plan.dart';
import 'package:front/domain/models/step.dart' as plan_steps;
import 'package:front/services/categorie_service.dart';

final GlobalKey<DetailsHeaderState> _headerKey =
    GlobalKey<DetailsHeaderState>();

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  final PlanService _planService = PlanService();
  final StepService _stepService = StepService();
  final CategorieService _categorieService = CategorieService();
  Plan? _plan;
  List<plan_steps.Step>? _steps;
  bool _isLoading = true;
  late DraggableScrollableController _bottomSheetController;

  Category? _currentCategory;

  @override
  void initState() {
    super.initState();
    _bottomSheetController = DraggableScrollableController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final String? planId =
            ModalRoute.of(context)?.settings.arguments as String?;
        if (planId != null) {
          _fetchPlanDetails(planId);
        }
      }
    });
  }

  @override
  void dispose() {
    _bottomSheetController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Color _getCategoryColor() {
    if (_plan == null) return const Color(0xFF3425B5);

    if (_currentCategory != null && _currentCategory!.id == _plan!.category) {
      return CategorieService.getColorFromHex(_currentCategory!.color);
    }

    return const Color(0xFF3425B5);
  }

  Future<void> _loadCategory() async {
    if (_plan == null) return;

    try {
      final category = await _categorieService.getCategoryById(_plan!.category);
      setState(() {
        _currentCategory = category;
      });
    } catch (e) {
      print("Erreur lors du chargement de la catégorie: $e");
    }
  }

  Future<void> _fetchPlanDetails(String planId) async {
    try {
      final plan = await _planService.getPlanById(planId);

      setState(() {
        _plan = plan;
        _isLoading = false;
      });

      _loadCategory();

      List<plan_steps.Step> steps = [];
      for (String stepId in _plan!.steps) {
        try {
          final step = await _stepService.getStepById(stepId);
          if (step != null) {
            steps.add(step);
          }
        } catch (e) {
          print("Erreur lors du chargement de l'étape $stepId: $e");
        }
      }
      setState(() {
        _steps = steps;
      });

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print("_fetchPlanDetails: Erreur - $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    if (_plan == null) {
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

    return Scaffold(
      body: Stack(
        children: [
          _plan!.steps.isNotEmpty
              ? DetailsHeader(
                  key: _headerKey,
                  stepIds: _plan!.steps,
                  category: _plan!.category,
                  categoryColor: _getCategoryColor(),
                  planTitle: _plan!.title,
                  planDescription: _plan!.description,
                )
              //TODO voir par défaut
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
                  plan: _plan!,
                  categoryColor: _getCategoryColor(),
                  scrollController: scrollController,
                  category: _currentCategory,
                  steps: _steps);
            },
          ),
        ],
      ),
    );
  }
}
