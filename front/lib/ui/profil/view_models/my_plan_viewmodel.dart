import 'package:flutter/material.dart';

import '../../../data/repositories/plan/plan_repository.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../utils/result.dart';

class MyPlansViewModel extends ChangeNotifier {
  final PlanRepository planRepository;

  MyPlansViewModel({required this.planRepository});

  List<Plan> _plans = [];
  bool isLoading = true;
  int displayLimit = 5;

  List<Plan> get displayedPlans => _plans.take(displayLimit).toList();
  int get totalPlans => _plans.length;

  Future<void> loadPlans(String userId) async {
    isLoading = true;
    notifyListeners();

    final result = await planRepository.getPlansByUser(userId);
    if (result is Ok<List<Plan>>) {
      _plans = result.value;
    } else {
      _plans = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void showMore() {
    displayLimit += 5;
    notifyListeners();
  }

  Future<void> deletePlan(BuildContext context, String planId) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 70,
                width: 70,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child:
                      Icon(Icons.delete_outline, color: Colors.red, size: 36),
                ),
              ),
              const Text(
                "Supprimer ce plan ?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Ce plan sera définitivement supprimé. Cette action est irréversible.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Supprimer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    final result = await planRepository.deletePlan(planId);
    if (result is Ok<void>) {
      _plans.removeWhere((p) => p.id == planId);
      displayLimit = _plans.length.clamp(0, 5);
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan supprimé avec succès')),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }
}
