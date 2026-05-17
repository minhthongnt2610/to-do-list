import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/constants/app_colors.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';
import 'package:to_do_list/screens/main/main_screen.dart';
import 'package:to_do_list/screens/start/start_screen.dart';
import 'package:to_do_list/screens/update_profile/update_profile_screen.dart';

/// Màn gốc: chờ Firebase khôi phục session, rồi lắng nghe auth realtime.
class AuthRoot extends StatefulWidget {
  const AuthRoot({super.key});

  @override
  State<AuthRoot> createState() => _AuthRootState();
}

class _AuthRootState extends State<AuthRoot> {
  final _authService = AuthService();
  bool _ready = false;
  User? _resolvedUser;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _resolvedUser = await _authService.waitForInitialUser();
    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: AppColors.hex020206,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.hexBA83DE,
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      // userChanges bao gồm đăng nhập/đăng xuất và cập nhật profile
      stream: _authService.userChanges(),
      initialData: _resolvedUser,
      builder: (context, snapshot) {
        final user = snapshot.data ?? _authService.currentUser;

        if (user == null) {
          return const StartScreen();
        }

        if (!_authService.isUserUpdatedProfile()) {
          return const UpdateProfileScreen();
        }

        return const MainScreen();
      },
    );
  }
}
