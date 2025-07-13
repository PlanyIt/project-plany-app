import 'package:flutter/material.dart';
import '../../../../domain/models/step/step.dart' as custom;
import '../../view_models/plan_details_viewmodel.dart';
import 'components/header_carousel.dart';
import 'components/header_controls.dart';
import 'components/map_view.dart';
import 'components/step_info_card.dart';

class DetailsHeader extends StatefulWidget {
  const DetailsHeader({
    super.key,
    required this.viewModel,
  });

  final PlanDetailsViewModel viewModel;

  @override
  DetailsHeaderState createState() => DetailsHeaderState();
}

class DetailsHeaderState extends State<DetailsHeader> {
  final GlobalKey<MapViewState> _mapKey = GlobalKey<MapViewState>();
  final ScrollController _stepScrollController = ScrollController();

  List<custom.Step> get _steps => widget.viewModel.steps;

  void recenterMapAll() {
    _mapKey.currentState?.recenterMapAll();
  }

  void _onStepSelected(int index) {
    if (widget.viewModel.currentStepIndex == index) return;

    widget.viewModel.selectStep(index);
    final selectedStep = widget.viewModel.selectedStep;
    if (selectedStep != null) {
      _mapKey.currentState?.centerOnStep(selectedStep.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final categoryColor = vm.planCategoryColor ?? Colors.grey;

    return Stack(
      children: [
        // Carte
        MapView(
          key: _mapKey,
          viewModel: widget.viewModel,
          height: MediaQuery.of(context).size.height,
          onStepSelected: _onStepSelected,
        ),

        // Contrôles en haut
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: HeaderControls(
            categoryColor: categoryColor,
            onCenterMap: recenterMapAll,
            showBackButton: true,
            viewModel: widget.viewModel,
          ),
        ),

        // Carrousel
        if (_steps.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            right: 16,
            child: SizedBox(
              width: 110,
              height: 180,
              child: HeaderCarousel(
                scrollController: _stepScrollController,
                viewModel: widget.viewModel,
              ),
            ),
          ),

        // Carte d'info sur une étape
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
                viewModel: widget.viewModel,
              ),
            ),
          ),
      ],
    );
  }
}
