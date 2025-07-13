import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../domain/models/user/user.dart';

class ProfileAvatar extends StatefulWidget {
  final User userProfile;
  final Function(File) onPickPhoto;
  final bool isCurrentUser;

  const ProfileAvatar({
    super.key,
    required this.userProfile,
    required this.onPickPhoto,
    required this.isCurrentUser,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _uploading = false;

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      setState(() => _uploading = true);
      await widget.onPickPhoto(File(pickedFile.path));
      if (mounted) {
        setState(() => _uploading = false);
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
            border: Border.all(color: primaryColor.withAlpha(50), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
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
                : widget.userProfile.photoUrl?.isNotEmpty == true
                    ? Image.network(
                        widget.userProfile.photoUrl!,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.person,
                                size: avatarSize * 0.5,
                                color: Colors.grey[400]),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.person,
                            size: avatarSize * 0.5, color: Colors.grey[400]),
                      ),
          ),
        ),
        if (widget.isCurrentUser)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child:
                    const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
