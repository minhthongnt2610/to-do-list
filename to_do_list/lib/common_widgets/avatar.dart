import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    required this.user,
    required this.size,
    super.key,
  });

  final User user;

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(size / 2)),
      child: (user.photoURL?.isEmpty ?? true)
          ? _buildDefaultAvatar()
          : Image.network(user.photoURL!,
              width: size, height: size, fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return _buildDefaultAvatar();
            }, errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar();
            }),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.account_circle,
      size: size,
      color: AppColors.hexC59ADF,
    );
  }
}
