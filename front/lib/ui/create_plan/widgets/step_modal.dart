import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'image_picker_card.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/create_step_viewmodel.dart';
import 'choose_location.dart';

class StepModal extends StatefulWidget {
  const StepModal({
    super.key,
    required this.viewModel,
    required this.onSave,
  });

  final CreateStepViewModel viewModel;
  final void Function(StepData stepData, int? index) onSave;

  @override
  StepModalState createState() => StepModalState();
}

class StepModalState extends State<StepModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _currentTab = _tabController.index);
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.9;

    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Container(
        height: maxHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Infos'),
                Tab(text: 'Détails'),
                Tab(text: 'Lieu')
              ],
            ),
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
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return Consumer<CreateStepViewModel>(
      builder: (context, vm, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Nom de l\'étape'),
            const SizedBox(height: 12),
            _buildTextField(
              valueNotifier: vm.title,
              onChanged: vm.setTitle,
              hintText: 'Ex: Visite du musée...',
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Description'),
            const SizedBox(height: 12),
            _buildTextField(
              valueNotifier: vm.description,
              onChanged: vm.setDescription,
              hintText: 'Décrivez cette étape...',
              prefixIcon: Icons.description,
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Image'),
            const SizedBox(height: 12),
            ImagePickerCard(
              selectedImage: vm.image != null ? File(vm.image!.path) : null,
              onPickImage: () async => await vm.pickImage(),
              onRemoveImage: () => vm.removeImage(),
              primaryColor: AppTheme.primaryColor,
              height: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Consumer<CreateStepViewModel>(
      builder: (context, vm, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                    valueNotifier: vm.duration,
                    onChanged: (val) => vm.setDuration(int.tryParse(val) ?? 0),
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
                    value: vm.durationUnit.value,
                    onChanged: (val) => vm.setDurationUnit(val ?? 'Heures'),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    items: ['Heures', 'Minutes', 'Jours']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Coût estimé'),
            const SizedBox(height: 12),
            _buildTextField(
              valueNotifier: vm.cost,
              onChanged: vm.setCost,
              hintText: 'Ex: 15',
              prefixIcon: Icons.euro,
              suffixText: '€',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTab() {
    return Consumer<CreateStepViewModel>(
      builder: (context, vm, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Lieu'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChooseLocation(
                    onLocationSelected: (loc, name) {
                      vm.setLocation(loc, name);
                    },
                    initialLocation: vm.location,
                  ),
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                        vm.locationName ?? 'Choisir un lieu',
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
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isLast = _currentTab == 2;
    return Consumer<CreateStepViewModel>(
      builder: (context, vm, _) => Container(
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
                onPressed: _validateCurrentTab(vm)
                    ? () => isLast
                        ? _saveStep(vm)
                        : _tabController.animateTo(_currentTab + 1)
                    : null,
                child: Text(isLast
                    ? (vm.isEditing ? 'Mettre à jour' : 'Ajouter')
                    : 'Continuer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateCurrentTab(CreateStepViewModel vm) {
    switch (_currentTab) {
      case 0:
        return vm.title.value.trim().isNotEmpty &&
            vm.description.value.trim().isNotEmpty &&
            vm.image != null;
      case 1:
        return vm.duration.value > 0 &&
            vm.durationUnit.value.isNotEmpty &&
            vm.cost.value.isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _saveStep(CreateStepViewModel vm) {
    final step = vm.buildStepData();
    if (step == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires."),
        ),
      );
      return;
    }

    widget.onSave(step, vm.isEditing ? vm.editingIndex : null);
    Navigator.pop(context);
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
}
