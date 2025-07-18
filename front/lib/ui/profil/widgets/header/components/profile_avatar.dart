import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../view_models/profile_viewmodel.dart';

class ProfileAvatar extends StatelessWidget {
  final ProfileViewModel viewModel;
  final bool isCurrentUser;

  const ProfileAvatar({
    super.key,
    required this.viewModel,
    required this.isCurrentUser,
  });

  Future<void> _pickImage(BuildContext context) async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      await viewModel.updateProfilePhoto(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = viewModel.userProfile!;
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
            child: viewModel.isUploadingAvatar
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  )
                : userProfile.photoUrl?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: userProfile.photoUrl!,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.person,
                              size: avatarSize * 0.5, color: Colors.grey[400]),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.person,
                            size: avatarSize * 0.5, color: Colors.grey[400]),
                      ),
          ),
        ),
        if (isCurrentUser)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _pickImage(context),
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
