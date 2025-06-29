import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/ui/profil/widgets/settings/components/settings_row.dart';
import 'package:front/widgets/section/section_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:front/providers/providers.dart';

class ProfileSettings extends ConsumerStatefulWidget {
  final User initialUserProfile;
  final Function onProfileUpdated;
  final Function(String, String) showInfoCard;
  final Function(String) showErrorCard;

  const ProfileSettings({
    super.key,
    required this.initialUserProfile,
    required this.onProfileUpdated,
    required this.showInfoCard,
    required this.showErrorCard,
  });
  @override
  ConsumerState<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends ConsumerState<ProfileSettings> {
  late User _userProfile;
  Key _photoKey = UniqueKey();

  final List<String> _genderOptions = [
    'Homme',
    'Femme',
    'Non-binaire',
    'Préfère ne pas préciser'
  ];
  @override
  void initState() {
    super.initState();
    _userProfile = widget.initialUserProfile;
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  String? _calculateAge() {
    if (_userProfile.birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - _userProfile.birthDate!.year;
    if (now.month < _userProfile.birthDate!.month ||
        (now.month == _userProfile.birthDate!.month &&
            now.day < _userProfile.birthDate!.day)) {
      age--;
    }
    return age.toString();
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Photo de profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF3425B5)),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _updateProfilePhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF3425B5)),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _updateProfilePhoto(ImageSource.gallery);
              },
            ),
            if (_userProfile.photoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer la photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfilePhoto(ImageSource source) async {
    try {
      final picked =
          await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (picked == null) return;

      // TODO: Implémenter la mise à jour de la photo avec les providers
      // final updated = await ref.read(userRepositoryProvider).updateProfilePhoto(_userProfile.id, File(picked.path));

      // Simulation temporaire
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onProfileUpdated();
      widget.showInfoCard('Succès', 'Photo mise à jour');
    } catch (e) {
      widget.showErrorCard('Erreur: $e');
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      // TODO: Implémenter la suppression de la photo avec les providers
      // final updated = await ref.read(userRepositoryProvider).removeProfilePhoto(_userProfile.id);

      // Simulation temporaire
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _photoKey = UniqueKey();
        _userProfile = _userProfile.copyWith(photoUrl: null);
      });

      widget.onProfileUpdated();
      widget.showInfoCard('Succès', 'Votre photo de profil a été supprimée.');
    } catch (e) {
      widget.showErrorCard('Erreur lors de la suppression de la photo: $e');
    }
  }

  Future<void> _showEditProfilePopup() async {
    final usernameController =
        TextEditingController(text: _userProfile.username);
    final descriptionController =
        TextEditingController(text: _userProfile.description ?? '');
    String? selectedGender = _userProfile.gender;
    DateTime? selectedBirthDate = _userProfile.birthDate;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Modifier votre profil',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3425B5))),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SectionTextField(
                      title: 'Nom d\'utilisateur',
                      controller: usernameController,
                      labelText: 'Entrez votre nom d\'utilisateur',
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Ce champ est requis'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    SectionTextField(
                      title: 'Description',
                      controller: descriptionController,
                      labelText: 'Décrivez-vous...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10, left: 8),
                          child: Text(
                            'Date de naissance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedBirthDate ??
                                  DateTime.now()
                                      .subtract(const Duration(days: 365 * 18)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: const Color(0xFF3425B5),
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF3425B5),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                selectedBirthDate = picked;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedBirthDate != null
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(selectedBirthDate!)
                                        : 'Sélectionnez votre date de naissance',
                                    style: TextStyle(
                                      color: selectedBirthDate != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                if (selectedBirthDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      setStateDialog(() {
                                        selectedBirthDate = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10, left: 8),
                          child: Text(
                            'Genre',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: InputDecorationTheme(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedGender,
                                  icon: const Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Color(0xFF3425B5),
                                    size: 20,
                                  ),
                                  hint: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      'Sélectionnez votre genre',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 3,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      selectedGender = value;
                                    });
                                  },
                                  items: _genderOptions
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              value == 'Homme'
                                                  ? Icons.man
                                                  : value == 'Femme'
                                                      ? Icons.woman
                                                      : value == 'Non-binaire'
                                                          ? Icons.people_alt
                                                          : Icons.person,
                                              size: 18,
                                              color: const Color(0xFF3425B5),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(value),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: const Text('Annuler'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              // TODO: Implémenter la mise à jour du profil avec les providers
                              // final updated = await ref.read(userRepositoryProvider).updateUserProfile(
                              //   _userProfile.id,
                              //   {
                              //     'username': usernameController.text,
                              //     'description': descriptionController.text,
                              //     'birthDate': selectedBirthDate?.toIso8601String(),
                              //     'gender': selectedGender,
                              //   },
                              // );

                              // Simulation temporaire
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              setState(() {
                                _userProfile = _userProfile.copyWith(
                                  username: usernameController.text,
                                  description: descriptionController.text,
                                  birthDate: selectedBirthDate,
                                  gender: selectedGender,
                                );
                              });
                              widget.onProfileUpdated();
                              widget.showInfoCard('Succès',
                                  'Votre profil a été mis à jour avec succès!');

                              if (context.mounted) {
                                GoRouter.of(context).pop();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3425B5),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Enregistrer'),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showPhotoOptions,
          child: Stack(
            children: [
              CircleAvatar(
                key: _photoKey,
                radius: 45,
                backgroundColor: Colors.grey[300],
                backgroundImage: _userProfile.photoUrl != null
                    ? NetworkImage(
                        '${_userProfile.photoUrl!}?v=${DateTime.now().millisecondsSinceEpoch}')
                    : null,
                child: _userProfile.photoUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3425B5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 16, color: Colors.white),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _updateProfilePhoto(ImageSource.gallery),
          child: const Text(
            'Modifier la photo',
            style: TextStyle(
              color: Color(0xFF3425B5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        InfoRow(
            title: 'Nom d\'utilisateur',
            value: _userProfile.username,
            icon: Icons.person_outline),
        if (_userProfile.description != null)
          InfoRow(
              title: 'Description',
              value: _userProfile.description!,
              icon: Icons.description_outlined),
        if (_userProfile.birthDate != null)
          InfoRow(
            title: 'Date de naissance',
            value: _formatDate(_userProfile.birthDate!),
            icon: Icons.cake_outlined,
            trailing: _calculateAge() != null
                ? Chip(
                    label: Text('${_calculateAge()} ans'),
                    backgroundColor:
                        const Color(0xFF3425B5).withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: Color(0xFF3425B5)),
                  )
                : null,
          ),
        if (_userProfile.gender != null)
          InfoRow(
              title: 'Genre',
              value: _userProfile.gender!,
              icon: Icons.people_outlined),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _showEditProfilePopup,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3425B5),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le profil'),
          ),
        ),
      ],
    );
  }
}
