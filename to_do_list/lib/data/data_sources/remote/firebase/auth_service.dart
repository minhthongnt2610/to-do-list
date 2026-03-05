import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService() {
    log('AuthService created');
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Lấy người dùng hiện tại
  User? get currentUser => _firebaseAuth.currentUser;

  /// Kiểm tra người dùng đã đăng nhập chưa
  bool isUserLoggedIn() {
    return currentUser != null;
  }

  bool isUserUpdatedProfile() {
    return (currentUser?.displayName?.isNotEmpty ?? false) &&
        (currentUser?.photoURL?.isNotEmpty ?? false);
  }
  //
  // /// Đăng ký với email và mật khẩu
  // Future<User?> createUser({
  //   required String email,
  //   required String password,
  // }) async {
  //   UserCredential userCredential =
  //       await _firebaseAuth.createUserWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );
  //   return userCredential.user;
  // }
  Future<User?> createUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("Register success: ${userCredential.user?.email}");
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}");
      print("Message: ${e.message}");
      return null;
    }
  }

  /// Đăng nhập với email và mật khẩu
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Gửi email xác nhận đặt lại mật khẩu
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Cập nhật thông tin người dùng
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await currentUser?.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }
}
