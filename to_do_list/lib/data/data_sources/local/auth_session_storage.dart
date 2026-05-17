import 'package:shared_preferences/shared_preferences.dart';

/// Lưu cục bộ UID đã đăng nhập để nhận biết session cần khôi phục (Android cold start).
class AuthSessionStorage {
  static const _keyLoggedInUid = 'logged_in_uid';

  Future<void> saveLoggedInUser(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLoggedInUid, uid);
  }

  Future<String?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedInUid);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedInUid);
  }

  Future<bool> hasLoggedInUser() async {
    return await getLoggedInUserId() != null;
  }
}
