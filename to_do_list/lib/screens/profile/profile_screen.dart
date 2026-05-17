import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/avatar.dart';
import 'package:to_do_list/common_widgets/confirmation_dialog.dart';
import 'package:to_do_list/data/data_sources/local/image_picker/image_picker_service.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/storage_service.dart';
import 'package:to_do_list/data/services/dialog_service.dart';
import 'package:to_do_list/screens/change_password/change_password_screen.dart';
import 'package:to_do_list/utilities/utilities.dart';

import '../../constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  final _imagePickerService = ImagePickerService();
  final _dialogService = DialogService();
  final _storageService = StorageService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final user = _authService.currentUser;
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        backgroundColor: AppColors.hex020206,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.hex020206,
      appBar: AppBar(
        backgroundColor: AppColors.hex020206,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titleSpacing: 20,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildAvatar(),
              const SizedBox(height: 16),
              Text(
                _user?.displayName ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _user?.email ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Spacer(),

              // Nút đổi mật khẩu
              _buildMenuTile(
                icon: Icons.lock_reset_rounded,
                label: 'Change password',
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(ChangePasswordScreen.routeName);
                },
              ),

              const SizedBox(height: 12),

              // Đường kẻ phân cách
              Divider(
                color: Colors.white.withValues(alpha: 0.08),
                height: 1,
              ),

              const SizedBox(height: 12),

              // Nút đăng xuất
              _buildMenuTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: Colors.redAccent,
                onTap: () async {
                  final isConfirmed = await _showLogoutConfirmationDialog(
                    context: context,
                  );
                  if (isConfirmed ?? false) {
                    await _logout();
                  }
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget nút menu có icon, label và màu tùy chỉnh
  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.hexBA83DE,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.hex181818,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color:
                    color == Colors.redAccent ? Colors.redAccent : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.25),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    _dialogService.showProgressDialog(context);
    await AuthService().signOut();
    if (!mounted) {
      return;
    }
    _dialogService.hideProgressDialog(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _updateAvatar() async {
    final imageFile =
        await _imagePickerService.showImageSourceActionSheet(context);
    if (imageFile == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    _dialogService.showProgressDialog(context);
    try {
      final url = await _storageService.uploadFile(imageFile, _user!.uid);
      if (url != null) {
        await _authService.updateProfile(photoURL: url);
        final user = _authService.currentUser;
        setState(() {
          _user = user;
        });
        if (!mounted) {
          return;
        }
        _dialogService.hideProgressDialog(context);
      }
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      _dialogService.hideProgressDialog(context);
      _dialogService.showErrorDialog(
        context: context,
        error: Utilities.cleanErrorMessage(error.message),
      );
    }
  }

  Future<bool?> _showLogoutConfirmationDialog({
    required BuildContext context,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Logout',
          content: 'Are you sure you want to logout?',
          confirmButtonTitle: 'Logout',
          cancelButtonTitle: 'Cancel',
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
          onCancel: () {
            Navigator.of(context).pop(false);
          },
        );
      },
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 64,
          backgroundColor: AppColors.hexBA83DE,
          child: Avatar(
            user: _user!,
            size: 118,
          ),
        ),
        Positioned(
          bottom: 6,
          right: 6,
          child: GestureDetector(
            onTap: () async {
              await _updateAvatar();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.hexC59ADF,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
