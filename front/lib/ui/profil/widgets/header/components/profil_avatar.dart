import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/providers/profile/profile_provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfilAvatar extends ConsumerStatefulWidget {
  final User userProfile;
  final bool isCurrentUser;

  const ProfilAvatar({
    super.key,
    required this.userProfile,
    required this.isCurrentUser,
  });
  @override
  ConsumerState<ProfilAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends ConsumerState<ProfilAvatar> {
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

      // Utiliser le provider pour l'état de chargement
      if (mounted) {
        setState(() {
          _uploading = true;
        });
      }

      final imageFile = File(pickedFile.path);

      if (!await imageFile.exists()) {
        throw Exception('Le fichier image n\'existe pas');
      }
      if (widget.userProfile.id.isEmpty) {
        throw Exception('ID utilisateur invalide');
      }

      // Utiliser le provider pour mettre à jour la photo de profil
      final profileNotifier = ref.read(profileProvider.notifier);
      final success = await profileNotifier.updateProfilePhoto(imageFile);

      if (!success) {
        throw Exception('Échec de la mise à jour de la photo de profil');
      }
      if (!mounted) {
        print(
            'Widget non monté après téléchargement, annulation des mises à jour d\'état');
        return;
      }
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = 85.0;
    final primaryColor = const Color(0xFF3425B5);

    // Utiliser le provider pour l'état de chargement
    final profileState = ref.watch(profileProvider);
    final isUploading = _uploading || profileState.isLoading;

    return Stack(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: primaryColor.withValues(alpha: 0.2), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(avatarSize / 2),
            child: isUploading
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
