import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/data_sources/remote/firebase/auth_service.dart';
import 'data/data_sources/remote/firebase/notification_service.dart';
import 'my_app.dart';

/// Hàm main chạy ứng dụng
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Đợi native layer khôi phục auth trước khi vẽ UI (quan trọng trên Android)
  await Future.wait([
    FirebaseAuth.instance.authStateChanges().first,
    FirebaseAuth.instance.idTokenChanges().first,
  ]);
  await AuthService().syncLocalSession();

  /// Khởi tạo Notification Service (FCM + Local Notifications)
  await NotificationService.instance.initialize();

  /// runApp nhận vào một widget và chạy ứng dụng
  runApp(
    ProviderScope(
      child:  MyApp(),
    ), 
  );
}
