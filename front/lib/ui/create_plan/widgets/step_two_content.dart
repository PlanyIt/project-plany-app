import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/theme/app_theme.dart';
import 'package:front/ui/create_plan/widgets/step_card_timeline.dart';
import 'package:front/domain/models/step/step.dart' as plan_steps;

class StepTwoContent extends ConsumerStatefulWidget {
  const StepTwoContent({super.key});

  @override
  ConsumerState<StepTwoContent> createState() => _StepTwoContentState();
}

class _StepTwoContentState extends ConsumerState<StepTwoContent> {
  @override
  Widget build(BuildContext context) {
    // Temporary implementation until providers are properly set up
    final themeColor = Theme.of(context).primaryColor;
    final steps = <plan_steps.Step>[]; // Empty list for now

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          steps.isEmpty
              ? _buildEmptyCard()
              : _buildStepsList(themeColor, steps),
          const SizedBox(height: 16),
          _buildAddStepButton(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.timeline_rounded,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Créer les étapes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Définissez chaque étape de votre plan avec ses détails.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_road_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune étape créée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter la première étape de votre plan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(Color themeColor, List<plan_steps.Step> steps) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          final isFirst = index == 0;
          final isLast = index == steps.length - 1;

          return StepCardTimeline(
            key: Key('step_${step.id}'),
            index: index,
            isFirst: isFirst,
            isLast: isLast,
            title: step.title,
            description: step.description,
            imagePath: step.image,
            duration: step.duration,
            cost: step.cost,
            locationName: step.position != null
                ? '${step.position!.latitude}, ${step.position!.longitude}'
                : null,
            themeColor: themeColor,
            onDelete: () {
              // Handle delete
            },
            onEdit: () {
              _showStepModal(step, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddStepButton() {
    return InkWell(
      onTap: () async {
        await _showStepModal(null, null);
        // Les changements seront automatiquement reflétés via ref.watch()
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Ajouter une étape',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStepModal(dynamic step, int? index) async {
    // Show modal for creating/editing a step using providers
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const Center(
            child: Text('Step Modal - Using Riverpod providers'),
          ),
        ),
      ),
    );
  }
}
