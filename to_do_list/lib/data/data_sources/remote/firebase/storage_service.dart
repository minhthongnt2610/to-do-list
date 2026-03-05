import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Tải ảnh lên Firebase Storage
  Future<String?> uploadFile(File file, String userId) async {
    /// Tải file lên Firebase Storage
    final fileExtension = file.path.split('.').last;
    final fileName = '$userId.$fileExtension';
    final ref = _storage.ref('avatar/$fileName');
    await ref.putFile(file);

    ///
    String downloadUrl = await ref.getDownloadURL();
    log("File uploaded successfully. Download URL: $downloadUrl");

    /// Trả về URL
    return downloadUrl;
  }
}
