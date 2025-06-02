import 'package:flutter/material.dart';
import 'package:front/screens/details-plan/widgets/header/components/header_controls.dart';
import 'package:front/screens/details-plan/widgets/header/components/map_view.dart';
import 'package:front/models/step.dart' as custom;
import 'package:front/screens/details-plan/widgets/header/components/step_info_card.dart';
import 'package:front/screens/details-plan/widgets/header/components/header_carousel.dart';
import 'package:front/services/step_service.dart';
import 'package:geolocator/geolocator.dart';

class DetailsHeader extends StatefulWidget {
  final List<String> stepIds;
  final String category;
  final Color categoryColor;
  final String? planTitle;
  final String? planDescription;
  
  const DetailsHeader({
    Key? key,
    required this.stepIds,
    required this.category,
    required this.categoryColor,
    this.planTitle,
    this.planDescription,
  }) : super(key: key);

  @override
  DetailsHeaderState createState() => DetailsHeaderState();
}

class DetailsHeaderState extends State<DetailsHeader> {
  final GlobalKey<MapViewState> _mapKey = GlobalKey<MapViewState>();
  final PageController _stepPageController = PageController();
  final StepService _stepService = StepService();
  
  List<custom.Step> _steps = [];
  bool _isLoading = true;
  int _currentStepIndex = 0;
  bool _showStepInfo = false;
  custom.Step? _selectedStep;
  double? _distanceToStep;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    try {
      final loadedSteps = <custom.Step>[];
      for (final stepId in widget.stepIds) {
        final step = await _stepService.getStepById(stepId);
        if (step != null) {
          loadedSteps.add(step);
        }
      }
      
      if (mounted) {
        setState(() {
          _steps = loadedSteps;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des étapes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
      
      setState(() {
        _distanceToStep = distanceInMeters / 1000;
      });
    } catch (e) {
      print("Erreur lors du calcul de la distance: $e");
    }
  }

  void recenterMapAll() {
    _mapKey.currentState?.recenterMapAll();
  }

  void _onStepSelected(int index) {
    setState(() {
      _currentStepIndex = index;
      _selectedStep = _steps[index];
      _showStepInfo = true;
      _distanceToStep = null;
    });
    
    // Calculer la distance
    _calculateDistanceToStep(_steps[index]);
    
    // Centrer la carte sur l'étape sélectionnée
    _mapKey.currentState?.centerOnStep(_steps[index].id!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Carte principale
        MapView(
          key: _mapKey,
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
          onCenterMap: () => _mapKey.currentState?.recenterMapAll(),
          steps: _steps,
          planTitle: widget.planTitle,
          planDescription: widget.planDescription,
          showBackButton: true,
        ),
      ),
        
        // Carrousel d'étapes (à droite)
        if (!_isLoading && _steps.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            right: 16,
            child: SizedBox(
              width: 110, 
              height: 180,
              child: HeaderCarousel(
                steps: _steps,
                currentIndex: _currentStepIndex,
                pageController: _stepPageController,
                onStepSelected: _onStepSelected,
                category: widget.category,
                categoryColor: widget.categoryColor,
              ),
            ),
          ),
        
        // Carte d'information de l'étape
        if (_showStepInfo && _selectedStep != null)
          Positioned(
            top: 0,
            bottom: 0,
            left: 16,
            right: 140,
            child: Align(
              alignment: Alignment(0, -0.7),
              child: StepInfoCard(
                step: _selectedStep!,
                distance: _distanceToStep,
                color: widget.categoryColor,
                onClose: () => setState(() {
                  _showStepInfo = false;
                }),
              ),
            ),
          ),
      ],
    );
  }
}