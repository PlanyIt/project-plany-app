import 'package:flutter/material.dart';
import 'package:front/models/plan.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/widgets/cards/p_plan-card.dart';
import 'package:front/screens/details_plan/detail_screen.dart';


class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  PlansScreenState createState() => PlansScreenState();
}

class PlansScreenState extends State<PlansScreen> {
  List<Plan> _plans = [];
  List<Plan> _filteredPlans = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    _searchController.addListener(() {
      _searchPlan(_searchController.text);
    });
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final plans = await PlanService().getPlans();
      setState(() {
        _plans = plans ?? [];
        _filteredPlans = _plans;
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la récupération des plans : $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchPlan(String value) {
    setState(() {
      _filteredPlans = _plans
          .where((plan) =>
              plan.title.toLowerCase().contains(value.toLowerCase()) ||
              plan.description.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

 void _navigateToDetails(String planId) {
  Navigator.pushNamed(
    context,
    '/details',
    arguments: planId,
  );
}
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 60),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Rechercher un plan",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.grey),
                    padding: const EdgeInsets.all(14),
                    onPressed: () {},
                    color: Colors.white,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ..._filteredPlans.map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PlanCard(
                      imageUrl:
                          "https://www.vivre-a-niort.com/fileadmin/_processed_/a/5/csm_Coucher_de_soleil_pris_depuis_le_Moulin_du_Roc__c__TOUTATIS_Drone_3168e85b55.jpg",
                      title: plan.title,
                      description: plan.description,
                      onTap: () => _navigateToDetails(plan.id!),
                    ),
                  )),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_filteredPlans.isEmpty && !_isLoading)
            const Center(
              child: Text('Aucun plan trouvé', style: TextStyle(fontSize: 20)),
            ),
        ],
      ),
    );
  }
}
