import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:to_do_list/data/services/dialog_service.dart';
import 'dart:io';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final DialogService _dialogService = DialogService();

  /// Chọn hình ảnh từ thư viện
  Future<File?> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  /// Chụp ảnh từ camera
  Future<File?> _takeImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  /// Hiển thị action sheet chọn hình ảnh
  Future<File?> showImageSourceActionSheet(BuildContext context) async {
    final imageSource = await showCupertinoModalPopup<ImageSource?>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Choose image source'),
        message:
            const Text('Pick an image from your gallery or take a new photo'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context, ImageSource.gallery);
            },
            child: const Text('Choose from Gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context, ImageSource.camera);
            },
            child: const Text('Take a Photo'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
    if (imageSource == ImageSource.gallery) {
      try {
        final file = await _pickImageFromGallery();
        return file;
      } catch (e) {
        if (!context.mounted) {
          return null;
        }
        await _dialogService.showErrorDialog(
          context: context,
          error:
              "Photo access is required to select an image. Please enable access in settings.",
        );
        return null;
      }
    } else if (imageSource == ImageSource.camera) {
      try {
        final file = await _takeImageFromCamera();
        return file;
      } catch (e) {
        if (!context.mounted) {
          return null;
        }
        await _dialogService.showErrorDialog(
          context: context,
          error:
              "Camera access is required to take a photo. Please enable access in settings.",
        );
        return null;
      }
    } else {
      return null;
    }
  }
}
