import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/create_plan_view_model.dart';
import 'step_card_timeline.dart';
import 'step_modal.dart';

class StepTwoContent extends StatefulWidget {
  const StepTwoContent({super.key, required this.viewModel});

  final CreatePlanViewModel viewModel;

  @override
  State<StepTwoContent> createState() => _StepTwoContentState();
}

class _StepTwoContentState extends State<StepTwoContent> {
  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          const Text(
            'Étapes du plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          widget.viewModel.stepCards.isEmpty
              ? _buildEmptyCard()
              : _buildStepsList(themeColor),
          const SizedBox(height: 24),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryColor,
            const Color(0xFF8278FF),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_walk,
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
                  'Composez votre parcours',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ajoutez des étapes à votre plan. Vous pourrez les réorganiser facilement en les faisant glisser.',
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

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_road,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune étape ajoutée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre plan en ajoutant des étapes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(Color themeColor) {
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
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.viewModel.stepCards.length,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        onReorder: (oldIndex, newIndex) {
          widget.viewModel.reorderStepCards(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final step = widget.viewModel.stepCards[index];
          final isFirst = index == 0;
          final isLast = index == widget.viewModel.stepCards.length - 1;

          return Padding(
            key: Key('step_card_$index'),
            padding: const EdgeInsets.only(bottom: 8),
            child: StepCardTimeline(
              index: index,
              isFirst: isFirst,
              isLast: isLast,
              title: step.title,
              description: step.description,
              imagePath: step.imageUrl,
              duration: step.duration,
              durationUnit: step.durationUnit,
              cost: step.cost,
              locationName: step.locationName,
              onDelete: () {
                widget.viewModel.removeStepCard(index);
                setState(() {});
              },
              onEdit: () async {
                widget.viewModel.startEditingStep(index);

                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return StepModal(
                      viewModel: widget.viewModel,
                    );
                  },
                );

                if (widget.viewModel.isEditingStep) {
                  widget.viewModel.cancelEditingStep();
                }

                setState(() {});
              },
              themeColor: themeColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddStepButton() {
    return InkWell(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return StepModal(
              viewModel: widget.viewModel,
            );
          },
        );
        setState(() {});
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Ajouter une étape',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
