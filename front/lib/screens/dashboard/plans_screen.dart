import 'package:flutter/material.dart';
import 'package:front/models/plan.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/widgets/cards/p_plan-card.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  PlansScreenState createState() => PlansScreenState();
}

class PlansScreenState extends State<PlansScreen> {
  List<Plan> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    final plans = await PlanService().getPlans();
    setState(() {
      _plans = plans;
      print(_plans);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, top: 60),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                physics: const ClampingScrollPhysics(),
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PlanCard(
                      imageUrl:
                          "https://www.vivre-a-niort.com/fileadmin/_processed_/a/5/csm_Coucher_de_soleil_pris_depuis_le_Moulin_du_Roc__c__TOUTATIS_Drone_3168e85b55.jpg",
                      title: plan.title,
                      description: plan.description,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
