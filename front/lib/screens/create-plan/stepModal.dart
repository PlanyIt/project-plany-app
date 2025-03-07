import 'dart:io';
import 'package:flutter/material.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:front/screens/create-plan/chooseLocation.dart';
import 'package:front/widgets/button/primary_button.dart';
import 'package:front/widgets/button/select_button.dart';
import 'package:provider/provider.dart';

class StepModal extends StatefulWidget {
  const StepModal({super.key});

  @override
  StepModalState createState() => StepModalState();
}

class StepModalState extends State<StepModal> {
  void _chooseLocation(CreatePlanProvider provider) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseLocation(
          onLocationSelected: (location, locationName) {
            provider.selectedLocation = location;
            provider.selectedLocationName = locationName;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreatePlanProvider>(context);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header with drag handle
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ajouter une étape',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Name section
                  _buildSectionTitle("Nom de l'étape"),
                  TextField(
                    controller: provider.titleStepController,
                    decoration: _getInputDecoration("Titre de l'étape"),
                  ),

                  const SizedBox(height: 24),

                  // Description section
                  _buildSectionTitle('Description'),
                  TextField(
                    controller: provider.descriptionStepController,
                    maxLines: 4,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: _getInputDecoration('Description détaillée'),
                  ),

                  const SizedBox(height: 24),

                  // Duration section
                  _buildSectionTitle('Durée estimée'),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: provider.durationStepController,
                          keyboardType: TextInputType.number,
                          decoration: _getInputDecoration('Durée'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: DropdownButtonFormField<String>(
                          value: provider.selectedUnit,
                          decoration: _getInputDecoration('Unité'),
                          items: ['Heures', 'Minutes', 'Secondes']
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
                          iconEnabledColor: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Cost section
                  _buildSectionTitle('Coût estimé'),
                  TextField(
                    controller: provider.costStepController,
                    keyboardType: TextInputType.number,
                    decoration: _getInputDecoration('Coût en €'),
                  ),

                  const SizedBox(height: 24),

                  // Image section
                  _buildSectionTitle('Image'),
                  _buildImagePicker(primaryColor, provider),

                  const SizedBox(height: 24),

                  // Location section
                  _buildSectionTitle('Localisation'),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SelectButton(
                      text: "Choisir une localisation",
                      onPressed: () => _chooseLocation(provider),
                      leadingIcon: Icons.place_outlined,
                      trailingIcon: Icons.arrow_forward_ios,
                    ),
                  ),

                  if (provider.selectedLocationName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.selectedLocationName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Fixed bottom action button
          Container(
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, 24 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: PrimaryButton(
              onPressed: () {
                provider.addStepCard(
                  provider.titleStepController.text,
                  provider.descriptionStepController.text,
                  provider.imageStep != null
                      ? File(provider.imageStep!.path)
                      : null,
                  provider.durationStepController.text,
                  double.tryParse(provider.costStepController.text),
                );
                Navigator.pop(context);
              },
              text: "Ajouter cette étape",
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImagePicker(Color primaryColor, CreatePlanProvider provider) {
    if (provider.imageStep == null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: InkWell(
          onTap: provider.pickStepImage,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  "Ajouter une image",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(provider.imageStep!.path),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withOpacity(0.6),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: provider.removeStepImage,
                    tooltip: "Supprimer l'image",
                    iconSize: 22,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withOpacity(0.6),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: provider.pickStepImage,
                    tooltip: "Modifier l'image",
                    iconSize: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
