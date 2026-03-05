import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/avatar.dart';
import 'package:to_do_list/common_widgets/confirmation_dialog.dart';
import 'package:to_do_list/common_widgets/primary_app_bar.dart';
import 'package:to_do_list/data/data_sources/local/image_picker/image_picker_service.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/storage_service.dart';
import 'package:to_do_list/data/services/dialog_service.dart';
import 'package:to_do_list/screens/start/start_screen.dart';
import 'package:to_do_list/utilities/utilities.dart';

import '../../common_widgets/primary_button.dart';
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
    _user = _authService.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hex020206,
      appBar: PrimaryAppBar(
        title: 'Profile',
        onBack: () {
          Navigator.of(context).pop();
        },
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
              PrimaryButton(
                onTap: () async {
                  final isConfirmed = await _showLogoutConfirmationDialog(
                    context: context,
                  );
                  if (isConfirmed ?? false) {
                    await _logout();
                  }
                },
                title: 'Logout',
              ),
              const SizedBox(height: 24),
            ],
          ),
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
    Navigator.of(context).pushNamedAndRemoveUntil(
      StartScreen.routeName,
      (route) => false,
    );
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
