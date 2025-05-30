import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/models/user_profile.dart';
import 'package:front/services/imgur_service.dart';
import 'package:front/services/user_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatefulWidget {
  final UserProfile userProfile;
  final Function(String) onUpdatePhoto;
  final Function onProfileUpdated;
  final bool isCurrentUser;

  const ProfileAvatar({
    Key? key,
    required this.userProfile,
    required this.onUpdatePhoto,
    required this.onProfileUpdated,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final UserService _userService = UserService();
  bool _uploading = false;

  Future<void> _pickAndUploadImage() async {
    HapticFeedback.lightImpact();

    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      if (!mounted) {
        print('Widget non monté, annulation de l\'opération');
        return;
      }

      setState(() {
        _uploading = true;
      });

      final imageFile = File(pickedFile.path);

      if (!await imageFile.exists()) {
        throw Exception('Le fichier image n\'existe pas');
      }

      final imgurResponse = await ImgurService().uploadImage(imageFile);

      final imageUrl = imgurResponse.link;
      if (imageUrl.isEmpty) {
        throw Exception('Le service Imgur n\'a pas retourné d\'URL valide');
      }

      if (widget.userProfile.id.isEmpty) {
        throw Exception('ID utilisateur invalide');
      }

      await _userService.updateUserPhoto(widget.userProfile.id, imageUrl);


      if (!mounted) {
        print('Widget non monté après téléchargement, annulation des mises à jour d\'état');
        return;
      }

      widget.onUpdatePhoto(imageUrl);
      widget.onProfileUpdated();
    } catch (e) {
      print('Erreur: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      } else {
        print('Widget non monté dans finally, setState ignoré');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = 85.0;
    final primaryColor = const Color(0xFF3425B5);

    return Stack(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor.withOpacity(0.2), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(avatarSize / 2),
            child: _uploading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 2,
                    ),
                  )
                : widget.userProfile.photoUrl != null &&
                        widget.userProfile.photoUrl!.isNotEmpty
                    ? Image.network(
                        widget.userProfile.photoUrl!,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: avatarSize * 0.5,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: avatarSize * 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
          ),
        ),

        if (widget.isCurrentUser)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}