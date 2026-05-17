import 'package:flutter/material.dart';
import 'package:to_do_list/constants/app_colors.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';
import 'package:to_do_list/screens/main/main_screen.dart';
import 'package:to_do_list/screens/start/start_screen.dart';
import 'package:to_do_list/screens/update_profile/update_profile_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final user = await _authService.waitForInitialUser();

    if (user != null) {
      try {
        await _authService.reloadUser();
      } catch (_) {
        // Tiếp tục với dữ liệu user đã cache nếu reload thất bại
      }
    }

    if (!mounted) return;

    if (user == null) {
      // Chưa đăng nhập → về màn hình Start
      Navigator.of(context).pushReplacementNamed(StartScreen.routeName);
    } else {
      final isUpdatedProfile = _authService.isUserUpdatedProfile();
      if (isUpdatedProfile) {
        Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
      } else {
        Navigator.of(context)
            .pushReplacementNamed(UpdateProfileScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.hex020206,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.hexBA83DE,
        ),
      ),
    );
  }
}
