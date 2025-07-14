import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../view_models/profile_viewmodel.dart';
import '../common/section_text_field.dart';
import 'components/settings_row.dart';

class ProfileSettings extends StatefulWidget {
  final ProfileViewModel viewModel;
  final Function(String, String) showInfoCard;
  final Function(String) showErrorCard;

  const ProfileSettings({
    super.key,
    required this.viewModel,
    required this.showInfoCard,
    required this.showErrorCard,
  });

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final List<String> _genderOptions = [
    'Homme',
    'Femme',
    'Non-binaire',
    'Préfère ne pas préciser'
  ];

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String? _calculateAge() {
    final birthDate = widget.viewModel.userProfile?.birthDate;
    if (birthDate == null) return null;
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age.toString();
  }

  Future<void> _updateProfilePhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        await widget.viewModel.updateProfilePhoto(File(pickedFile.path));
        widget.showInfoCard('Succès', 'Photo mise à jour');
      }
    } catch (e) {
      widget.showErrorCard('Erreur: $e');
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      await widget.viewModel.removeProfilePhoto();
      widget.showInfoCard('Succès', 'Photo supprimée');
    } catch (e) {
      widget.showErrorCard('Erreur: $e');
    }
  }

  Future<void> _showEditProfilePopup() async {
    final user = widget.viewModel.userProfile!;
    final usernameController = TextEditingController(text: user.username);
    final descriptionController =
        TextEditingController(text: user.description ?? '');
    var selectedGender = user.gender;
    var selectedBirthDate = user.birthDate;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('Modifier le profil',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SectionTextField(
                        title: 'Nom d\'utilisateur',
                        controller: usernameController,
                        labelText: 'Votre nom'),
                    const SizedBox(height: 20),
                    SectionTextField(
                        title: 'Description',
                        controller: descriptionController,
                        labelText: 'Description',
                        maxLines: 3),
                    const SizedBox(height: 20),
                    _buildDatePicker(selectedBirthDate, (picked) {
                      setStateDialog(() => selectedBirthDate = picked);
                    }),
                    const SizedBox(height: 20),
                    _buildGenderDropdown(selectedGender, (gender) {
                      setStateDialog(() => selectedGender = gender);
                    }),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        await widget.viewModel.updateProfile(
                          username: usernameController.text,
                          description: descriptionController.text,
                          birthDate: selectedBirthDate,
                          gender: selectedGender,
                        );
                        if (mounted && context.mounted) context.pop();
                        if (mounted) {
                          widget.showInfoCard('Succès', 'Profil mis à jour');
                        }
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDatePicker(DateTime? selected, Function(DateTime?) onSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selected ??
              DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 10),
            Text(selected != null ? _formatDate(selected) : 'Date de naissance',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(
      String? selectedGender, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: const InputDecoration(labelText: 'Genre'),
      items: _genderOptions
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.viewModel.userProfile!;
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Prendre une photo'),
                            onTap: () {
                              Navigator.pop(context);
                              _updateProfilePhoto(ImageSource.camera);
                            }),
                        ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Galerie'),
                            onTap: () {
                              Navigator.pop(context);
                              _updateProfilePhoto(ImageSource.gallery);
                            }),
                        if (user.photoUrl != null)
                          ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Supprimer'),
                              onTap: () {
                                Navigator.pop(context);
                                _removeProfilePhoto();
                              }),
                      ],
                    ),
                  );
                },
                child: widget.viewModel.isUploadingAvatar
                    ? const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
              ),
              TextButton(
                onPressed: () => _updateProfilePhoto(ImageSource.gallery),
                child: const Text('Modifier la photo'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InfoRow(title: 'Nom', value: user.username, icon: Icons.person_outline),
        if (user.description != null)
          InfoRow(
              title: 'Description',
              value: user.description!,
              icon: Icons.description_outlined),
        if (user.birthDate != null)
          InfoRow(
            title: 'Date de naissance',
            value: _formatDate(user.birthDate!),
            icon: Icons.cake_outlined,
            trailing:
                _calculateAge() != null ? Text('${_calculateAge()} ans') : null,
          ),
        if (user.gender != null)
          InfoRow(
              title: 'Genre', value: user.gender!, icon: Icons.people_outlined),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _showEditProfilePopup,
            icon: const Icon(Icons.edit),
            label: const Text('Modifier'),
          ),
        ),
      ],
    );
  }
}
