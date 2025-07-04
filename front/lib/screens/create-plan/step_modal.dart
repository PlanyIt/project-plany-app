import 'dart:io';
import 'package:flutter/material.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:front/screens/create-plan/choose_location.dart';
import 'package:front/ui/core/themes/app_theme.dart';
import 'package:front/ui/core/ui/card/image_picker_card.dart';
import 'package:provider/provider.dart';

class StepModal extends StatefulWidget {
  const StepModal({super.key});

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

  void _chooseLocation(CreatePlanProvider provider) async {
    // Ne pas utiliser le MapController ici, mais plutôt passer directement à l'écran de sélection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseLocation(
          onLocationSelected: (location, locationName) {
            provider.selectedLocation = location;
            provider.selectedLocationName = locationName;
          },
          initialLocation: provider.selectedLocation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreatePlanProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(provider), // Modifier pour passer le provider
          _buildTabBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                if (_tabController.index != index) {
                  _tabController.animateTo(index);
                }
              },
              children: [
                _buildBasicInfoTab(provider),
                _buildDetailsTab(provider),
                _buildLocationTab(provider),
              ],
            ),
          ),
          _buildBottomNavigation(provider),
        ],
      ),
    );
  }

  Widget _buildHeader(CreatePlanProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            provider.isEditingStep ? 'Modifier une étape' : 'Ajouter une étape',
            style: const TextStyle(
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
            onPressed: () {
              // Annuler l'édition si nécessaire
              if (provider.isEditingStep) {
                provider.cancelEditingStep();
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        padding: EdgeInsets.zero,
        splashBorderRadius: BorderRadius.circular(14),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_currentTab == 0 ? Icons.info : Icons.info_outline,
                    size: 18),
                const SizedBox(width: 8),
                const Text('Infos'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    _currentTab == 1
                        ? Icons.attach_money
                        : Icons.attach_money_outlined,
                    size: 18),
                const SizedBox(width: 8),
                const Text('Détails'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_currentTab == 2 ? Icons.place : Icons.place_outlined,
                    size: 18),
                const SizedBox(width: 8),
                const Text('Lieu'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab(CreatePlanProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Nom de l\'étape'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: provider.titleStepController,
            hintText: 'Ex: Visite du musée, Déjeuner au restaurant...',
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Description'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: provider.descriptionStepController,
            hintText: 'Décrivez cette étape en détail...',
            prefixIcon: Icons.description,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Image'),
          const SizedBox(height: 12),
          ImagePickerCard(
            selectedImage: provider.imageStep != null
                ? File(provider.imageStep!.path)
                : null,
            onPickImage: provider.pickStepImage,
            onRemoveImage: provider.removeStepImage,
            primaryColor: AppTheme.primaryColor,
            height: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(CreatePlanProvider provider) {
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
                  controller: provider.durationStepController,
                  hintText: 'Durée',
                  prefixIcon: Icons.timer,
                  keyboardType: TextInputType.number,
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
                    value: provider.selectedUnit,
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
                        provider.selectedUnit = newValue;
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
            controller: provider.costStepController,
            hintText: 'Ex: 15',
            prefixIcon: Icons.euro,
            suffixText: '€',
            keyboardType: TextInputType.number,
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

  Widget _buildLocationTab(CreatePlanProvider provider) {
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
          if (provider.selectedLocationName != null)
            _buildSelectedLocation(provider)
          else
            _buildLocationSelector(provider),
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

  Widget _buildSelectedLocation(CreatePlanProvider provider) {
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
                      provider.selectedLocationName!,
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
                  provider.selectedLocation = null;
                  provider.selectedLocationName = null;
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Supprimer'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _chooseLocation(provider),
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

  Widget _buildLocationSelector(CreatePlanProvider provider) {
    return InkWell(
      onTap: () => _chooseLocation(provider),
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
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    int maxLines = 1,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
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
        controller: controller,
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
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(CreatePlanProvider provider) {
    bool canProceed = _validateCurrentTab(provider);
    final isEditMode = provider.isEditingStep;

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
          if (_currentTab > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  _tabController.animateTo(_currentTab - 1);
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
          if (_currentTab > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (_currentTab < 2) {
                        _tabController.animateTo(_currentTab + 1);
                      } else {
                        _saveStep(provider);
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
                    _currentTab == 2
                        ? (isEditMode
                            ? 'Mettre à jour l\'étape'
                            : 'Ajouter l\'étape')
                        : 'Continuer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentTab == 2 ? Icons.check_circle : Icons.arrow_forward,
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

  bool _validateCurrentTab(CreatePlanProvider provider) {
    switch (_currentTab) {
      case 0:
        return provider.titleStepController.text.isNotEmpty;
      case 1:
        return provider.durationStepController.text.isNotEmpty;
      case 2:
        return true; // La localisation est optionnelle
      default:
        return false;
    }
  }

  // Remplacer la méthode _addStep par _saveStep
  void _saveStep(CreatePlanProvider provider) {
    // Validation finale
    if (provider.titleStepController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre de l\'étape est obligatoire')),
      );
      return;
    }

    // Sauvegarder l'étape (ajouter ou mettre à jour)
    provider.saveStep(
      provider.titleStepController.text,
      provider.descriptionStepController.text,
      provider.imageStep != null ? File(provider.imageStep!.path) : null,
      provider.durationStepController.text,
      double.tryParse(provider.costStepController.text),
    );

    // Fermer la modale
    Navigator.pop(context);
  }
}
