import 'package:share_plus/share_plus.dart';
import '../../domain/models/plan/plan.dart';
import '../../utils/helpers.dart';

class ShareService {
  static Future<void> sharePlan(Plan plan, int favoritesCount) async {
    final planUrl = "https://api-plany.onrender.com/api/plans/${plan.id}";
    final shareText = """
🗺️ Découvrez ce plan "${capitalize(plan.title)}" sur Plany !

📍 ${plan.category?.name ?? 'Sans catégorie'}
⏱️ ${formatDurationToString(plan.totalDuration ?? 0)}
💰 ${(calculateTotalStepsCost(plan.steps)).toStringAsFixed(2)} €
⭐️ $favoritesCount personnes aiment déjà ce plan

${plan.description.length > 100 ? '${plan.description.substring(0, 100)}...' : plan.description}

Voir le plan complet : $planUrl
""";

    await Share.share(shareText, subject: 'Découvrez ce plan Plany');
  }
}
