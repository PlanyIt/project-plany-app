import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../../../../widgets/card/compact_plan_card.dart';
import '../../view_models/profile_view_model.dart';
import '../section_header.dart';

class MyPlansSection extends StatefulWidget {
  final ProfileViewModel viewModel;

  const MyPlansSection({
    super.key,
    required this.viewModel,
  });

  @override
  State<MyPlansSection> createState() => _MyPlansSectionState();
}

class _MyPlansSectionState extends State<MyPlansSection>
    with AutomaticKeepAliveClientMixin {
  int _displayLimit = 5;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final plans = widget.viewModel.userPlans;
    final displayedPlans = plans.take(_displayLimit).toList();
    final hasMorePlans = plans.length > _displayLimit;

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          SectionHeader(
            title: widget.viewModel.isCurrentUser ? 'Mes plans' : 'Ses plans',
            subtitle:
                '${plans.length} plan${plans.length > 1 ? 's' : ''} créé${plans.length > 1 ? 's' : ''}',
            icon: Icons.map_outlined,
            action: widget.viewModel.isCurrentUser
                ? TextButton.icon(
                    onPressed: () => context.go(Routes.createPlan),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Créer'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  )
                : null,
          ),
          if (plans.isEmpty)
            _buildEmptyState()
          else
            _buildPlansList(displayedPlans, hasMorePlans),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.viewModel.isCurrentUser
                ? 'Aucun plan créé'
                : 'Aucun plan trouvé',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.viewModel.isCurrentUser
                ? 'Créez votre premier plan pour commencer votre aventure !'
                : 'Cet utilisateur n\'a pas encore créé de plans.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          if (widget.viewModel.isCurrentUser) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go(Routes.createPlan),
              icon: const Icon(Icons.add),
              label: const Text('Créer mon premier plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlansList(List plans, bool hasMorePlans) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayedPlans.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final plan = displayedPlans[index];
            return CompactPlanCard(
              plan: plan,
              onTap: () {
                // Navigate to plan details
                // context.go('/plan/${plan.id}');
              },
              onLike: () {
                // Handle like
              },
              onShare: () {
                // Handle share
              },
              showActions: widget.viewModel.isCurrentUser,
            );
          },
        ),
        if (hasMorePlans) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _displayLimit += 5;
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Voir plus de plans'),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
