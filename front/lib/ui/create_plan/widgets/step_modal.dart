import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/ui/create_plan/widgets/choose_location.dart';
import 'package:front/theme/app_theme.dart';
import 'package:front/widgets/card/image_picker_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front/providers/plan/plan_ui_providers.dart';

class StepModal extends ConsumerWidget {
  const StepModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modalId = hashCode.toString();
    final currentTab = ref.watch(stepModalCurrentTabProvider(modalId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context, ref),
          _buildTabBar(context, ref, currentTab, modalId),
          Expanded(
            child: IndexedStack(
              index: currentTab,
              children: [
                _buildBasicInfoTab(context, ref),
                _buildDetailsTab(context, ref),
                _buildLocationTab(context, ref),
              ],
            ),
          ),
          _buildBottomNavigation(context, ref, currentTab, modalId),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ajouter une étape',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.black54, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
      BuildContext context, WidgetRef ref, int currentTab, String modalId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabBarItem(ref, modalId, currentTab, 0, Icons.info,
              Icons.info_outline, 'Infos'),
          _buildTabBarItem(ref, modalId, currentTab, 1, Icons.attach_money,
              Icons.attach_money_outlined, 'Détails'),
          _buildTabBarItem(ref, modalId, currentTab, 2, Icons.place,
              Icons.place_outlined, 'Lieu'),
        ],
      ),
    );
  }

  Widget _buildTabBarItem(WidgetRef ref, String modalId, int currentTab,
      int tabIndex, IconData activeIcon, IconData inactiveIcon, String title) {
    final isActive = currentTab == tabIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref
            .read(stepModalCurrentTabProvider(modalId).notifier)
            .state = tabIndex,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : inactiveIcon,
                size: 18,
                color: isActive ? AppTheme.primaryColor : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                  color: isActive ? AppTheme.primaryColor : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab(BuildContext context, WidgetRef ref) {
    final title = ref.watch(stepModalTitleProvider);
    final description = ref.watch(stepModalDescriptionProvider);
    final selectedImage = ref.watch(stepModalSelectedImageProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Nom de l\'étape'),
          const SizedBox(height: 12),
          _buildTextField(
            value: title,
            hintText: 'Ex: Visite du musée, Déjeuner au restaurant...',
            prefixIcon: Icons.title,
            onChanged: (value) =>
                ref.read(stepModalTitleProvider.notifier).state = value,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Description'),
          const SizedBox(height: 12),
          _buildTextField(
            value: description,
            hintText: 'Décrivez cette étape en détail...',
            prefixIcon: Icons.description,
            maxLines: 5,
            onChanged: (value) =>
                ref.read(stepModalDescriptionProvider.notifier).state = value,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Image'),
          const SizedBox(height: 12),
          ImagePickerCard(
            selectedImage: selectedImage,
            onPickImage: () async {
              await _pickStepImage(ref);
            },
            onRemoveImage: () {
              ref.read(stepModalSelectedImageProvider.notifier).state = null;
            },
            primaryColor: AppTheme.primaryColor,
            height: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(stepModalDurationProvider);
    final cost = ref.watch(stepModalCostProvider);
    final selectedUnit = ref.watch(stepModalSelectedUnitProvider);

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
                  value: duration,
                  hintText: 'Durée',
                  prefixIcon: Icons.timer,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => ref
                      .read(stepModalDurationProvider.notifier)
                      .state = value,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    items: ['Heures', 'Minutes', 'Jours']
                        .map<DropdownMenuItem<String>>((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        ref.read(stepModalSelectedUnitProvider.notifier).state =
                            newValue;
                      }
                    },
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Coût estimé'),
          const SizedBox(height: 12),
          _buildTextField(
            value: cost,
            hintText: 'Ex: 15',
            prefixIcon: Icons.euro,
            suffixText: '€',
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                ref.read(stepModalCostProvider.notifier).state = value,
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Pourquoi ajouter ces détails ?',
            description:
                'Indiquer la durée et le coût de chaque étape permet aux utilisateurs de mieux planifier leur temps et leur budget.',
            icon: Icons.info_outline,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab(BuildContext context, WidgetRef ref) {
    final selectedLocationName =
        ref.watch(stepModalSelectedLocationNameProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Localisation'),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez une localisation à cette étape pour que les utilisateurs puissent facilement s\'y rendre',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          if (selectedLocationName != null)
            _buildSelectedLocation(context, ref, selectedLocationName)
          else
            _buildLocationSelector(context, ref),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Astuce',
            description:
                'Ajoutez une localisation précise pour faciliter l\'orientation des utilisateurs qui suivront votre plan.',
            icon: Icons.lightbulb_outline,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedLocation(
      BuildContext context, WidgetRef ref, String locationName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.place,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Localisation sélectionnée',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locationName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  ref.read(stepModalSelectedLocationProvider.notifier).state =
                      null;
                  ref
                      .read(stepModalSelectedLocationNameProvider.notifier)
                      .state = null;
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Supprimer'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _chooseLocation(context, ref),
                icon: const Icon(Icons.edit_location_alt, size: 18),
                label: const Text('Modifier'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _chooseLocation(context, ref),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_location_alt,
                color: Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajouter une localisation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sélectionnez un lieu sur la carte',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
      BuildContext context, WidgetRef ref, int currentTab, String modalId) {
    bool canProceed = _validateCurrentTab(ref, currentTab);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentTab > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  ref
                      .read(stepModalCurrentTabProvider(modalId).notifier)
                      .state = currentTab - 1;
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Précédent',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ),
          if (currentTab > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (currentTab < 2) {
                        ref
                            .read(stepModalCurrentTabProvider(modalId).notifier)
                            .state = currentTab + 1;
                      } else {
                        _saveStep(context, ref);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentTab == 2 ? 'Ajouter' : 'Continuer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    currentTab == 2 ? Icons.check_circle : Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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

  Widget _buildTextField({
    required String value,
    required String hintText,
    required IconData prefixIcon,
    int maxLines = 1,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: TextEditingController(text: value)
          ..selection =
              TextSelection.fromPosition(TextPosition(offset: value.length)),
        onChanged: onChanged,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: AppTheme.primaryColor),
          suffixText: suffixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  bool _validateCurrentTab(WidgetRef ref, int currentTab) {
    switch (currentTab) {
      case 0:
        return ref.read(stepModalTitleProvider).isNotEmpty;
      case 1:
        return ref.read(stepModalDurationProvider).isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _saveStep(BuildContext context, WidgetRef ref) {
    final title = ref.read(stepModalTitleProvider);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre de l\'étape est obligatoire')),
      );
      return;
    }

    // Ici vous pouvez ajouter la logique pour sauvegarder l'étape
    // avec tous les données des providers

    // Reset des providers
    ref.read(stepModalTitleProvider.notifier).state = '';
    ref.read(stepModalDescriptionProvider.notifier).state = '';
    ref.read(stepModalDurationProvider.notifier).state = '';
    ref.read(stepModalCostProvider.notifier).state = '';
    ref.read(stepModalSelectedUnitProvider.notifier).state = 'Heures';
    ref.read(stepModalSelectedImageProvider.notifier).state = null;
    ref.read(stepModalSelectedLocationProvider.notifier).state = null;
    ref.read(stepModalSelectedLocationNameProvider.notifier).state = null;

    Navigator.pop(context);
  }

  Future<void> _pickStepImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      ref.read(stepModalSelectedImageProvider.notifier).state =
          File(pickedFile.path);
    }
  }

  void _chooseLocation(BuildContext context, WidgetRef ref) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseLocation(
          onLocationSelected: (location, locationName) {
            ref.read(stepModalSelectedLocationProvider.notifier).state =
                location;
            ref.read(stepModalSelectedLocationNameProvider.notifier).state =
                locationName;
          },
          initialLocation:
              ref.read(stepModalSelectedLocationProvider.notifier).state,
        ),
      ),
    );
  }
}
