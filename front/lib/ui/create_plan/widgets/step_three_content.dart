import 'package:flutter/material.dart';

import '../../../../utils/helpers.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/card/compact_plan_card.dart';
import '../view_models/create_plan_view_model.dart';
import '../view_models/create_step_viewmodel.dart';
import 'step_card_timeline.dart';

class StepThreeContent extends StatelessWidget {
  const StepThreeContent({super.key, required this.viewModel});

  final CreatePlanViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      physics: const BouncingScrollPhysics(),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Aperçu final'),
            const SizedBox(height: 16),
            _buildPlanPreview(),
            const SizedBox(height: 24),
            ValueListenableBuilder<List<StepData>>(
              valueListenable: viewModel.steps,
              builder: (_, steps, __) {
                if (steps.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Étapes'),
                      const SizedBox(height: 16),
                      _buildStepsList(steps),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
            _buildPublishCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanPreview() {
    return ValueListenableBuilder<List<StepData>>(
      valueListenable: viewModel.steps,
      builder: (_, stepCards, __) {
        final stepImages = stepCards
            .where((step) => step.imageUrl.isNotEmpty)
            .map((step) => step.imageUrl)
            .toList();

        double totalCost = 0;
        var totalDurationInMinutes = 0;

        for (final step in stepCards) {
          if (step.cost != null) totalCost += step.cost!;
          if (step.duration != null &&
              step.duration! > 0 &&
              step.durationUnit != null) {
            totalDurationInMinutes = formatDurationToMinutes(
                '${step.duration} ${step.durationUnit!.toLowerCase()}');
          }
        }

        return ValueListenableBuilder<String>(
          valueListenable: viewModel.title,
          builder: (_, title, __) {
            return ValueListenableBuilder<String>(
              valueListenable: viewModel.description,
              builder: (_, description, __) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CompactPlanCard(
                    title: title,
                    description: description,
                    category: viewModel.selectedCategory,
                    stepsCount: stepCards.length,
                    borderRadius: BorderRadius.circular(16),
                    imageUrls: stepImages.isEmpty ? null : stepImages,
                    totalCost: totalCost > 0 ? totalCost : null,
                    totalDuration: totalDurationInMinutes > 0
                        ? totalDurationInMinutes
                        : null,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStepsList(List<StepData> steps) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: steps.length,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemBuilder: (context, index) {
          final step = steps[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StepCardTimeline(
              index: index,
              isFirst: index == 0,
              isLast: index == steps.length - 1,
              title: step.title,
              description: step.description,
              imagePath: step.imageUrl.isNotEmpty ? step.imageUrl : null,
              duration: step.duration,
              durationUnit: step.durationUnit,
              cost: step.cost,
              locationName: step.locationName,
              themeColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentColor,
            const Color(0xFFFF5A85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presque terminé !',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vérifiez les détails de votre plan avant de le publier. Vous pourrez le modifier ultérieurement.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: .3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.public,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Prêt à publier ?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'En publiant ce plan, vous le rendez visible par tous les utilisateurs. Vous pourrez le modifier ou le supprimer plus tard.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                'Vos coordonnées ne sont pas partagées',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                'Vous pouvez modifier ce plan à tout moment',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
