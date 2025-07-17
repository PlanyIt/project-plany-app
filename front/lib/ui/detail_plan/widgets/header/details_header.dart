import 'package:flutter/material.dart';

import '../../view_models/detail/favorite_viewmodel.dart';
import '../../view_models/detail/follow_user_viewmodel.dart';
import '../../view_models/detail/plan_details_viewmodel.dart';
import 'components/header_carousel.dart';
import 'components/header_controls.dart';
import 'components/map_view.dart';
import 'components/step_info_card.dart';

class DetailsHeader extends StatefulWidget {
  const DetailsHeader({
    super.key,
    required this.planViewModel,
    required this.favoriteViewModel,
    required this.followViewModel,
  });

  final PlanDetailsViewModel planViewModel;
  final FavoriteViewModel favoriteViewModel;
  final FollowUserViewModel followViewModel;

  @override
  DetailsHeaderState createState() => DetailsHeaderState();
}

class DetailsHeaderState extends State<DetailsHeader> {
  final GlobalKey<MapViewState> _mapKey = GlobalKey<MapViewState>();
  final PageController _stepPageController = PageController();

  void recenterMapAll() {
    _mapKey.currentState?.recenterMapAll();
  }

  Future<void> _handleStepSelection(int index) async {
    await widget.planViewModel.selectStep(index);
    widget.planViewModel.showStepInformation(true);
    _mapKey.currentState?.centerOnStep(widget.planViewModel.steps[index].id!);
  }

  void _closeStepInfo() {
    widget.planViewModel.showStepInformation(false);
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = widget.planViewModel.planCategoryColor ?? Colors.grey;

    return AnimatedBuilder(
      animation: widget.planViewModel,
      builder: (context, _) {
        final vm = widget.planViewModel;
        final steps = vm.steps;

        return Stack(
          children: [
            MapView(
              key: _mapKey,
              viewModel: vm,
              height: MediaQuery.of(context).size.height,
              onStepSelected: _handleStepSelection,
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: HeaderControls(
                categoryColor: categoryColor,
                onCenterMap: recenterMapAll,
                showBackButton: true,
                planViewModel: vm,
              ),
            ),
            if (steps.isNotEmpty)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                right: 16,
                child: SizedBox(
                  width: 110,
                  height: 180,
                  child: HeaderCarousel(
                    scrollController: _stepPageController,
                    viewModel: vm,
                    onStepSelected: _handleStepSelection,
                  ),
                ),
              ),
            if (vm.showStepInfo && vm.selectedStep != null)
              Positioned(
                top: 0,
                bottom: 0,
                left: 16,
                right: 140,
                child: Align(
                  alignment: const Alignment(0, -0.7),
                  child: StepInfoCard(
                    color: categoryColor,
                    viewModel: vm,
                    onClose: _closeStepInfo,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
