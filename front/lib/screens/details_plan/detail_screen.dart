import 'package:flutter/material.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/services/step_service.dart';
import 'package:front/models/plan.dart';
import 'package:front/models/step.dart' as plan_steps;
import 'package:front/widgets/contents/details_content.dart';
import 'package:timeline_tile/timeline_tile.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PlanService _planService = PlanService();
  final StepService _stepService = StepService();
  Plan? _plan;
  List<plan_steps.Step>? _steps;
  bool _isLoading = true;
  double _totalCost = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String planId = ModalRoute.of(context)?.settings.arguments as String;
    _fetchPlanDetails(planId);
  }

  Future<void> _fetchPlanDetails(String planId) async {
    try {
      final plan = await _planService.getPlanById(planId);
      final steps = await _stepService.fetchStepsByPlan(planId);
      final double totalCost = steps.fold<double>(0.0, (sum, step) => sum + step.cost);

      setState(() {
        _plan = plan;
        _steps = steps;
        _totalCost = totalCost;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des détails : $e');
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
              Theme.of(context).primaryColor.withOpacity(0.7),
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

    final String planId = ModalRoute.of(context)?.settings.arguments as String;

    return DetailsContent(
      imageUrl: "https://www.vivre-a-niort.com/fileadmin/_processed_/a/5/csm_Coucher_de_soleil_pris_depuis_le_Moulin_du_Roc__c__TOUTATIS_Drone_3168e85b55.jpg",
      onPlanPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Planification en cours...')),
        );
      },
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Coût total et Statistiques
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      context,
                      icon: Icons.attach_money,
                      value: '$_totalCost €',
                      label: 'Coût total',
                    ),
                    _buildStatColumn(
                      context,
                      icon: Icons.favorite_border,
                      value: '123',
                      label: 'Likes',
                    ),
                    _buildStatColumn(
                      context,
                      icon: Icons.star_border,
                      value: 'Premium',
                      label: 'Statut',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Créateur
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user.png'),
                  radius: 30,
                ),
                title: const Text(
                  'Nom du créateur', 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  )
                ),
                subtitle: const Text(
                  'Bio du créateur', 
                  style: TextStyle(fontSize: 16)
                ),
              ),
              const SizedBox(height: 24),

              // Description
              _buildSectionTitle('Description'),
              Text(
                _plan!.description,
                style: TextStyle(
                  fontSize: 16, 
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Catégorie
              _buildSectionTitle('Catégorie'),
              const Text(
                'Catégorie du plan', 
                style: TextStyle(fontSize: 16)
              ),
              const SizedBox(height: 24),

              // Tags
              _buildSectionTitle('Tags'),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: ['Voyage', 'Aventure', 'Découverte']
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Étapes
              _buildSectionTitle('Étapes'),
              _steps != null && _steps!.isNotEmpty
                  ? Column(
                      children: _steps!.map((step) {
                        return TimelineTile(
                          alignment: TimelineAlign.start,
                          isFirst: _steps!.indexOf(step) == 0,
                          isLast: _steps!.indexOf(step) == _steps!.length - 1,
                          indicatorStyle: IndicatorStyle(
                            width: 20,
                            color: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.all(6),
                          ),
                          endChild: Container(
                            constraints: const BoxConstraints(minHeight: 80),
                            margin: const EdgeInsets.only(left: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title, 
                                  style: const TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  step.description, 
                                  style: TextStyle(
                                    fontSize: 14, 
                                    color: Colors.grey[600]
                                  )
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${step.cost}€', 
                                  style: const TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.green
                                  )
                                ),
                              ],
                            ),
                          ),
                          beforeLineStyle: LineStyle(
                            color: Theme.of(context).primaryColor,
                            thickness: 2,
                          ),
                        );
                      }).toList(),
                    )
                  : const Text('Aucune étape trouvée.'),
            ],
          ),
        ),
      ),
      planId: planId,
    );
  }

  // Méthode pour construire une colonne de statistiques
  Widget _buildStatColumn(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  // Méthode pour construire un titre de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[900],
        ),
      ),
    );
  }
}