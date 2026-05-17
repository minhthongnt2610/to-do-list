import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/primary_button.dart';
import '../../constants/app_colors.dart';
import '../../data/data_sources/local/image_picker/image_picker_service.dart';
import '../../data/data_sources/remote/firebase/auth_service.dart';
import '../../data/data_sources/remote/firebase/storage_service.dart';
import '../../data/services/dialog_service.dart';
import '../../utilities/utilities.dart';
import '../new_task/widgets/input_field.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const routeName = '/update-profile';

  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  String? _avatarPath;

  String? _name;

  final _imagePickerService = ImagePickerService();
  final _dialogService = DialogService();
  final _storageService = StorageService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _hideKeyboard();
      },
      child: Scaffold(
        backgroundColor: AppColors.hex020206,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 128),
                  const Text(
                    'Update your profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                    'Please update your avatar and name to complete your registration and personalize your experience.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildAvatar()],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  InputField(
                    initialValue: _name,
                    keyboardType: TextInputType.emailAddress,
                    hintText: "Enter your name",
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  PrimaryButton(
                    onTap: () async {
                      await _updateProfile();
                    },
                    title: 'Update Profile',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
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
    setState(() {
      _avatarPath = imageFile.path;
    });
  }

  Widget _buildAvatar({
    double size = 128,
  }) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2 + 5,
          backgroundColor: AppColors.hexBA83DE,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(size / 2)),
            child: (_avatarPath?.isEmpty ?? true)
                ? _buildDefaultAvatar(size)
                : Image.file(File(_avatarPath!),
                    width: size, height: size, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar(size);
                  }),
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

  Widget _buildDefaultAvatar(double size) {
    return Icon(
      Icons.account_circle,
      size: size,
      color: AppColors.hexC59ADF,
    );
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  String? _checkCredentials({
    required String? name,
    required String? avatarPath,
  }) {
    if (name?.isEmpty ?? true) {
      return 'Name cannot be empty.';
    }
    if (avatarPath?.isEmpty ?? true) {
      return 'Avatar cannot be empty.';
    }

    return null;
  }

  Future<void> _updateProfile() async {
    log("Update profile >> Email: $_name, Avatar: $_avatarPath");
    final error = _checkCredentials(
      name: _name,
      avatarPath: _avatarPath,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      _dialogService.showErrorDialog(context: context, error: error);
    } else {
      _dialogService.showProgressDialog(context);
      try {
        final url = await _storageService.uploadFile(
          File(_avatarPath!),
          _authService.currentUser!.uid,
        );
        if (url != null) {
          await _authService.updateProfile(
            photoURL: url,
            displayName: _name,
          );
          // Reload user để cập nhật displayName/photoURL mới nhất
          await _authService.reloadUser();
          if (!mounted) {
            return;
          }

          _dialogService.hideProgressDialog(context);
          _hideKeyboard();
          // Về AuthRoot để tự chuyển sang MainScreen sau khi cập nhật profile
          Navigator.of(context).popUntil((route) => route.isFirst);
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
  }
}
