import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/ui/details_plan/widgets/header/components/header_controls.dart';
import 'package:front/ui/details_plan/widgets/header/components/map_view.dart';
import 'package:front/domain/models/step/step.dart' as custom;
import 'package:front/ui/details_plan/widgets/header/components/step_info_card.dart';
import 'package:front/ui/details_plan/widgets/header/components/header_carousel.dart';
import 'package:front/providers/providers.dart';
import 'package:front/utils/result.dart';
import 'package:geolocator/geolocator.dart';

// Providers pour l'état du header
final headerStepsProvider =
    StateProvider.family<List<custom.Step>, List<String>>((ref, stepIds) => []);
final headerIsLoadingProvider =
    StateProvider.family<bool, String>((ref, headerId) => true);
final headerCurrentStepIndexProvider =
    StateProvider.family<int, String>((ref, headerId) => 0);
final headerShowStepInfoProvider =
    StateProvider.family<bool, String>((ref, headerId) => false);
final headerSelectedStepProvider =
    StateProvider.family<custom.Step?, String>((ref, headerId) => null);
final headerDistanceToStepProvider =
    StateProvider.family<double?, String>((ref, headerId) => null);

class DetailsHeader extends ConsumerStatefulWidget {
  final List<String> stepIds;
  final String category;
  final Color categoryColor;
  final String? planTitle;
  final String? planDescription;

  const DetailsHeader({
    super.key,
    required this.stepIds,
    required this.category,
    required this.categoryColor,
    this.planTitle,
    this.planDescription,
  });
  @override
  ConsumerState<DetailsHeader> createState() => _DetailsHeaderState();
}

class _DetailsHeaderState extends ConsumerState<DetailsHeader> {
  final PageController _stepPageController = PageController();
  late String _headerId;

  @override
  void initState() {
    super.initState();
    _headerId = widget.stepIds.join('-');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSteps();
    });
  }

  Future<void> _loadSteps() async {
    ref.read(headerIsLoadingProvider(_headerId).notifier).state = true;

    try {
      final loadedSteps = <custom.Step>[];
      final stepRepository = ref.read(stepRepositoryProvider);

      for (final stepId in widget.stepIds) {
        final stepResult = await stepRepository.getStepById(stepId);
        if (stepResult is Ok<custom.Step>) {
          loadedSteps.add(stepResult.value);
        }
      }

      if (mounted) {
        ref.read(headerStepsProvider(widget.stepIds).notifier).state =
            loadedSteps;
        ref.read(headerIsLoadingProvider(_headerId).notifier).state = false;
      }
    } catch (e) {
      print('Erreur lors du chargement des étapes: $e');
      if (mounted) {
        ref.read(headerIsLoadingProvider(_headerId).notifier).state = false;
      }
    }
  }

  Future<void> _calculateDistanceToStep(custom.Step step) async {
    if (step.position == null) return;

    try {
      final position = await Geolocator.getCurrentPosition();
      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        step.position!.latitude,
        step.position!.longitude,
      );

      ref.read(headerDistanceToStepProvider(_headerId).notifier).state =
          distanceInMeters / 1000;
    } catch (e) {
      print("Erreur lors du calcul de la distance: $e");
    }
  }

  void _onStepSelected(int index) {
    final steps = ref.read(headerStepsProvider(widget.stepIds));
    if (index < 0 || index >= steps.length) return;

    ref.read(headerCurrentStepIndexProvider(_headerId).notifier).state = index;
    ref.read(headerSelectedStepProvider(_headerId).notifier).state =
        steps[index];
    ref.read(headerShowStepInfoProvider(_headerId).notifier).state = true;
    ref.read(headerDistanceToStepProvider(_headerId).notifier).state = null;

    // Calculer la distance
    _calculateDistanceToStep(steps[index]);
  }

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    final steps = ref.watch(headerStepsProvider(widget.stepIds));
    final isLoading = ref.watch(headerIsLoadingProvider(_headerId));
    final currentStepIndex =
        ref.watch(headerCurrentStepIndexProvider(_headerId));
    final showStepInfo = ref.watch(headerShowStepInfoProvider(_headerId));
    final selectedStep = ref.watch(headerSelectedStepProvider(_headerId));
    final distanceToStep = ref.watch(headerDistanceToStepProvider(_headerId));

    return Stack(
      children: [
        // Carte principale
        MapView(
          stepIds: widget.stepIds,
          category: widget.category,
          categoryColor: widget.categoryColor,
          planTitle: widget.planTitle,
          planDescription: widget.planDescription,
          height: MediaQuery.of(context).size.height,
          onStepSelected: _onStepSelected,
        ),
        // Bouton de retour
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: HeaderControls(
            categoryColor: widget.categoryColor,
            onCenterMap: () {
              // Logique de recentrage via provider si nécessaire
            },
            steps: steps,
            planTitle: widget.planTitle,
            planDescription: widget.planDescription,
            showBackButton: true,
          ),
        ),

        // Carrousel d'étapes (à droite)
        if (!isLoading && steps.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            right: 16,
            child: SizedBox(
              width: 110,
              height: 180,
              child: HeaderCarousel(
                steps: steps,
                currentIndex: currentStepIndex,
                pageController: _stepPageController,
                onStepSelected: _onStepSelected,
                category: widget.category,
                categoryColor: widget.categoryColor,
              ),
            ),
          ),

        // Carte d'information de l'étape
        if (showStepInfo && selectedStep != null)
          Positioned(
            top: 0,
            bottom: 0,
            left: 16,
            right: 140,
            child: Align(
              alignment: Alignment(0, -0.7),
              child: StepInfoCard(
                step: selectedStep,
                distance: distanceToStep,
                color: widget.categoryColor,
                onClose: () => ref
                    .read(headerShowStepInfoProvider(_headerId).notifier)
                    .state = false,
              ),
            ),
          ),
      ],
    );
  }
}
