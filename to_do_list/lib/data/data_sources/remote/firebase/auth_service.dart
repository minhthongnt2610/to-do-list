import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/data/data_sources/local/auth_session_storage.dart';

class AuthService {
  AuthService() {
    log('AuthService created');
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AuthSessionStorage _sessionStorage = AuthSessionStorage();

  /// Lấy người dùng hiện tại
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream trạng thái đăng nhập (dùng để lắng nghe thay đổi auth)
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// Stream thay đổi thông tin user (profile, token refresh, ...)
  Stream<User?> userChanges() => _firebaseAuth.userChanges();

  /// Đợi Firebase Auth khôi phục session từ bộ nhớ cục bộ (cold start).
  ///
  /// Lần emit đầu của [authStateChanges] đôi khi là `null` dù user vẫn đăng nhập;
  /// cần kiểm tra lại [currentUser] và chờ thêm emit tiếp theo nếu cần.
  Future<User?> waitForInitialUser() async {
    final hasLocalSession = await _sessionStorage.hasLoggedInUser();
    // Luôn chờ tối thiểu 8s trên cold start — Android máy thật hay restore chậm
    final restoreTimeout = hasLocalSession
        ? const Duration(seconds: 15)
        : const Duration(seconds: 8);

    await Future.wait([
      _firebaseAuth.authStateChanges().first,
      _firebaseAuth.idTokenChanges().first,
    ]);

    final deadline = DateTime.now().add(restoreTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _sessionStorage.saveLoggedInUser(user.uid);
        return user;
      }

      try {
        User? streamUser;
        try {
          streamUser = await _firebaseAuth
              .idTokenChanges()
              .firstWhere((u) => u != null)
              .timeout(const Duration(milliseconds: 200));
        } on TimeoutException {
          streamUser = await _firebaseAuth
              .authStateChanges()
              .firstWhere((u) => u != null)
              .timeout(const Duration(milliseconds: 200));
        }
        final resolved = _firebaseAuth.currentUser ?? streamUser;
        if (resolved != null) {
          await _sessionStorage.saveLoggedInUser(resolved.uid);
          return resolved;
        }
      } on TimeoutException {
        // Chưa restore xong, tiếp tục poll
      }
    }

    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _sessionStorage.saveLoggedInUser(user.uid);
      return user;
    }

    // Chỉ xóa cache local khi trước đó đã lưu session mà Firebase không restore được
    if (hasLocalSession) {
      await _sessionStorage.clear();
    }
    return null;
  }

  /// Đồng bộ cache local nếu Firebase đang có user (gọi sau khi đăng nhập / mở app).
  Future<void> syncLocalSession() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _sessionStorage.saveLoggedInUser(user.uid);
    }
  }

  Future<void> _persistSession(User? user) async {
    if (user != null) {
      await _sessionStorage.saveLoggedInUser(user.uid);
    }
  }

  /// Reload thông tin user từ Firebase (cần sau khi updateProfile)
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

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
      await _persistSession(userCredential.user);
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
    await _persistSession(userCredential.user);
    return userCredential.user;
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _sessionStorage.clear();
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

  /// Đổi mật khẩu (yêu cầu xác thực lại bằng mật khẩu hiện tại)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No authenticated user found.',
      );
    }

    // Re-authenticate với mật khẩu hiện tại
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Sau khi xác thực thành công, đổi mật khẩu mới
    await user.updatePassword(newPassword);
  }
}

