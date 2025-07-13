import 'package:flutter/material.dart';
import '../../../../../domain/models/step/step.dart' as custom;
import '../../../view_models/plan_details_viewmodel.dart';

class HeaderCarousel extends StatelessWidget {
  final ScrollController scrollController;
  final PlanDetailsViewModel viewModel;

  const HeaderCarousel({
    super.key,
    required this.scrollController,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final steps = vm.steps;
    final currentIndex = vm.currentStepIndex;
    final categoryColor = vm.planCategoryColor ?? Colors.grey;

    if (steps.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: 110,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: steps.length,
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              itemExtent: 90,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isSelected = index == currentIndex;

                return GestureDetector(
                  onTap: () => vm.selectStep(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    height: isSelected ? 92 : 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isSelected ? 0.25 : 0.1),
                          blurRadius: isSelected ? 10 : 4,
                          offset: Offset(0, isSelected ? 3 : 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        _buildImage(step, isSelected, categoryColor),
                        _buildBadge(index, isSelected, categoryColor),
                        _buildTitle(step.title, isSelected),
                        if (isSelected) _buildSelectionDot(categoryColor),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: .05),
            ),
            child: Text(
              "${currentIndex + 1}/${steps.length}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                shadows: [
                  Shadow(
                      color: Colors.black38,
                      blurRadius: 2,
                      offset: Offset(0, 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(custom.Step step, bool isSelected, Color categoryColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: .4),
          width: isSelected ? 2.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            step.image.isNotEmpty
                ? Image.network(
                    step.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _defaultStepImage(step, categoryColor),
                  )
                : _defaultStepImage(step, categoryColor),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.1),
                    Color.fromRGBO(0, 0, 0, 0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int index, bool isSelected, Color categoryColor) {
    return Positioned(
      top: 6,
      right: 6,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color:
              isSelected ? categoryColor : Colors.black.withValues(alpha: .5),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          "${index + 1}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title, bool isSelected) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black.withValues(alpha: .7)
              : Colors.black.withValues(alpha: .5),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSelected ? 12 : 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionDot(Color categoryColor) {
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: categoryColor.withValues(alpha: .6),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultStepImage(custom.Step step, Color color) {
    return Container(
      color: color.withValues(alpha: .8),
      child: Center(
        child: Text(
          step.title.isNotEmpty ? step.title[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
