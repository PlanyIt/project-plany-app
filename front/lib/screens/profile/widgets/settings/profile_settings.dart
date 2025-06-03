import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front/domain/models/user_profile.dart';
import 'package:front/services/user_service.dart';
import 'package:front/services/imgur_service.dart';
import 'package:front/screens/profile/widgets/settings/components/settings_row.dart';
import 'package:front/widgets/section/section_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' as paintingBinding;

class ProfileSettings extends StatefulWidget {
  final UserProfile userProfile;
  final Function onProfileUpdated;
  final Function(String, String) showInfoCard;
  final Function(String) showErrorCard;

  const ProfileSettings({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
    required this.showInfoCard,
    required this.showErrorCard,
  });

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final UserService _userService = UserService();
  Key _photoKey = UniqueKey();

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
    if (widget.userProfile.birthDate == null) return null;

    final today = DateTime.now();
    int age = today.year - widget.userProfile.birthDate!.year;

    if (today.month < widget.userProfile.birthDate!.month ||
        (today.month == widget.userProfile.birthDate!.month &&
            today.day < widget.userProfile.birthDate!.day)) {
      age--;
    }

    return age.toString();
  }

  Future<void> _showEditProfilePopup() async {
    final TextEditingController usernameController = TextEditingController(
      text: widget.userProfile.username,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: widget.userProfile.description ?? '',
    );

    String? selectedGender = widget.userProfile.gender;
    DateTime? selectedBirthDate = widget.userProfile.birthDate;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Modifier votre profil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3425B5),
                          ),
                        ),
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
                    ),
                    const SizedBox(height: 24),
                    SectionTextField(
                      title: 'Description',
                      controller: descriptionController,
                      labelText: 'Décrivez-vous en quelques mots...',
                      maxLines: 3,
                    ),
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
                                color: Colors.grey.withOpacity(0.1),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3425B5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              DateTime? birthDateToSend;
                              if (selectedBirthDate != null) {
                                birthDateToSend = DateTime.utc(
                                  selectedBirthDate!.year,
                                  selectedBirthDate!.month,
                                  selectedBirthDate!.day,
                                  12,
                                  0,
                                  0,
                                );
                              }

                              final Map<String, dynamic> data = {
                                'username': usernameController.text,
                                'description': descriptionController.text,
                                'birthDate': birthDateToSend?.toIso8601String(),
                                'gender': selectedGender,
                              };

                              Navigator.pop(context);
                              setState(() {});

                              try {
                                final updatedProfile =
                                    await _userService.updateUserProfile(
                                  widget.userProfile.id,
                                  data,
                                );

                                setState(() {
                                  widget.userProfile.username =
                                      updatedProfile.username;
                                  widget.userProfile.description =
                                      updatedProfile.description;
                                  widget.userProfile.birthDate =
                                      updatedProfile.birthDate;
                                  widget.userProfile.gender =
                                      updatedProfile.gender;
                                });

                                widget.onProfileUpdated();
                                widget.showInfoCard('Succès',
                                    'Votre profil a été mis à jour avec succès!');
                              } catch (e) {
                                setState(() {});
                                widget.showErrorCard('Erreur: $e');
                              }
                            }
                          },
                          child: const Text('Enregistrer'),
                        ),
                      ],
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

  Future<void> _updateProfilePhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final imgurResponse = await ImgurService().uploadImage(imageFile);

        final imageUrl = imgurResponse?.link;
        if (imageUrl != null) {
          final updatedProfile = await _userService.updateUserProfile(
            widget.userProfile.id,
            {'photoUrl': imageUrl},
          );

          if (updatedProfile != null) {
            setState(() {
              widget.userProfile.photoUrl = imageUrl;
            });

            widget.onProfileUpdated();
            widget.showInfoCard('Succès', 'Photo mise à jour');
          }
        }
      }
    } catch (e) {
      widget.showErrorCard('Erreur: $e');
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      final updatedProfile = await _userService.updateUserProfile(
        widget.userProfile.id,
        {'photoUrl': null},
      );

      if (updatedProfile != null) {
        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            await currentUser.updatePhotoURL(null);
            await currentUser.reload();
          }
        } catch (e) {
          print('Erreur lors de la suppression de la photo Firebase: $e');
        }

        final prefs = await SharedPreferences.getInstance();

        await prefs.remove('user_photo_url');
        await prefs.remove('${widget.userProfile.id}_photo');

        paintingBinding.imageCache.clear();
        paintingBinding.imageCache.clearLiveImages();

        final newPhotoKey = UniqueKey();

        setState(() {
          widget.userProfile.photoUrl = null;
          _photoKey = newPhotoKey;
        });

        widget.onProfileUpdated();

        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {});
          }
        });

        widget.showInfoCard('Succès', 'Votre photo de profil a été supprimée.');
      }
    } catch (e) {
      widget.showErrorCard('Erreur lors de la suppression de la photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Photo de profil',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            leading: const Icon(Icons.camera_alt,
                                color: Color(0xFF3425B5)),
                            title: const Text('Prendre une photo'),
                            onTap: () {
                              Navigator.pop(context);
                              _updateProfilePhoto(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library,
                                color: Color(0xFF3425B5)),
                            title: const Text('Choisir depuis la galerie'),
                            onTap: () {
                              Navigator.pop(context);
                              _updateProfilePhoto(ImageSource.gallery);
                            },
                          ),
                          if (widget.userProfile.photoUrl != null)
                            ListTile(
                              leading:
                                  const Icon(Icons.delete, color: Colors.red),
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
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      key: _photoKey,
                      radius: 45,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: widget.userProfile.photoUrl != null
                          ? NetworkImage(
                              '${widget.userProfile.photoUrl!}?v=${DateTime.now().millisecondsSinceEpoch}')
                          : null,
                      child: widget.userProfile.photoUrl == null
                          ? Icon(Icons.person,
                              size: 40, color: Colors.grey[600])
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
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  _updateProfilePhoto(ImageSource.gallery);
                },
                child: const Text(
                  'Modifier la photo',
                  style: TextStyle(
                    color: Color(0xFF3425B5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InfoRow(
          title: 'Nom d\'utilisateur',
          value: widget.userProfile.username,
          icon: Icons.person_outline,
        ),
        if (widget.userProfile.description != null)
          InfoRow(
            title: 'Description',
            value: widget.userProfile.description!,
            icon: Icons.description_outlined,
            multiline: true,
          ),
        if (widget.userProfile.birthDate != null)
          InfoRow(
            title: 'Date de naissance',
            value: _formatDate(widget.userProfile.birthDate!),
            icon: Icons.cake_outlined,
            trailing: _calculateAge() != null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3425B5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_calculateAge()} ans',
                      style: const TextStyle(
                        color: Color(0xFF3425B5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : null,
          ),
        if (widget.userProfile.gender != null)
          InfoRow(
            title: 'Genre',
            value: widget.userProfile.gender!,
            icon: Icons.people_outlined,
          ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
              onPressed: _showEditProfilePopup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3425B5),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              label: const Text('Modifier le profil'),
            ),
          ),
        ),
      ],
    );
  }
}
