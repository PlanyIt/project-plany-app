import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/card/image_picker_card.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/create_plan_view_model.dart';
import 'choose_location.dart';

class StepModal extends StatefulWidget {
  const StepModal({super.key, required this.viewModel});

  final CreatePlanViewModel viewModel;

  @override
  StepModalState createState() => StepModalState();
}

class StepModalState extends State<StepModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.9;

    return Container(
      height: maxHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with title and close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ajouter une étape',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Infos'),
              Tab(text: 'Détails'),
              Tab(text: 'Lieu'),
            ],
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoTab(),
                _buildDetailsTab(),
                _buildLocationTab(),
              ],
            ),
          ),

          // Bottom navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Lieu'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _chooseLocation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.viewModel.selectedLocationName ??
                          'Choisir un lieu',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _currentTab = _tabController.index;
      });
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _chooseLocation() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseLocation(
          onLocationSelected: (location, locationName) {
            widget.viewModel.selectedLocation = location;
            widget.viewModel.selectedLocationName = locationName;
            setState(() {});
          },
          initialLocation: widget.viewModel.selectedLocation,
        ),
      ),
    );
  }

  Widget _buildTextField<T>({
    required ValueNotifier<T> valueNotifier,
    required void Function(String) onChanged,
    required String hintText,
    required IconData prefixIcon,
    int maxLines = 1,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return ValueListenableBuilder<T>(
      valueListenable: valueNotifier,
      builder: (context, value, _) {
        final text = value.toString();
        final controller = TextEditingController(text: text)
          ..selection = TextSelection.collapsed(offset: text.length);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(prefixIcon, color: AppTheme.primaryColor),
              suffixText: suffixText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Nom de l\'étape'),
          const SizedBox(height: 12),
          _buildTextField(
            valueNotifier: widget.viewModel.stepTitle,
            onChanged: widget.viewModel.setStepTitle,
            hintText: 'Ex: Visite du musée, Déjeuner au restaurant...',
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Description'),
          const SizedBox(height: 12),
          _buildTextField(
            valueNotifier: widget.viewModel.stepDescription,
            onChanged: widget.viewModel.setStepDescription,
            hintText: 'Décrivez cette étape en détail...',
            prefixIcon: Icons.description,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Image'),
          const SizedBox(height: 12),
          ImagePickerCard(
            selectedImage: widget.viewModel.imageStep != null
                ? File(widget.viewModel.imageStep!.path)
                : null,
            onPickImage: () async {
              await widget.viewModel.pickStepImage();
              setState(() {});
            },
            onRemoveImage: () {
              widget.viewModel.removeStepImage();
              setState(() {});
            },
            primaryColor: AppTheme.primaryColor,
            height: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Durée estimée'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  valueNotifier: widget.viewModel.stepDuration,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      widget.viewModel.setStepDuration(parsed);
                    }
                  },
                  hintText: 'Durée',
                  prefixIcon: Icons.timer,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: widget.viewModel.selectedUnit,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  items: ['Heures', 'Minutes', 'Jours']
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      widget.viewModel.selectedUnit = value;
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Coût estimé'),
          const SizedBox(height: 12),
          _buildTextField(
            valueNotifier: widget.viewModel.stepCost,
            onChanged: widget.viewModel.setStepCost,
            hintText: 'Ex: 15',
            prefixIcon: Icons.euro,
            suffixText: '€',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final canProceed = _validateCurrentTab();
    final isEditMode = widget.viewModel.isEditingStep;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (_currentTab > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _tabController.animateTo(_currentTab - 1),
                child: const Text('Précédent'),
              ),
            ),
          if (_currentTab > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (_currentTab < 2) {
                        _tabController.animateTo(_currentTab + 1);
                      } else {
                        _saveStep();
                      }
                    }
                  : null,
              child: Text(_currentTab == 2
                  ? (isEditMode ? 'Mettre à jour' : 'Ajouter')
                  : 'Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentTab() {
    switch (_currentTab) {
      case 0:
        return widget.viewModel.stepTitle.value.trim().isNotEmpty &&
            widget.viewModel.stepDescription.value.trim().isNotEmpty &&
            widget.viewModel.imageStep != null;
      case 1:
        return widget.viewModel.stepDuration.value > 0 &&
            widget.viewModel.selectedUnit.isNotEmpty &&
            widget.viewModel.stepCost.value.trim().isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _saveStep() {
    if (widget.viewModel.stepTitle.value.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le titre de l'étape est obligatoire")),
      );
      return;
    }

    widget.viewModel.saveStep(
      title: widget.viewModel.stepTitle.value.trim(),
      description: widget.viewModel.stepDescription.value.trim(),
      image: widget.viewModel.imageStep != null
          ? File(widget.viewModel.imageStep!.path)
          : null,
      duration: widget.viewModel.stepDuration.value,
      cost: double.tryParse(widget.viewModel.stepCost.value.trim()),
    );

    Navigator.pop(context);
  }
}
