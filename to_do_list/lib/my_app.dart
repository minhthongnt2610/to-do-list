import 'package:flutter/material.dart';
import 'package:to_do_list/screens/all_tasks/all_tasks_screen.dart';
import 'package:to_do_list/screens/all_tasks/models/all_tasks_screen_arguments.dart';
import 'package:to_do_list/screens/change_password/change_password_screen.dart';
import 'package:to_do_list/screens/home/home_screen.dart';
import 'package:to_do_list/screens/login/login_screen.dart';
import 'package:to_do_list/screens/main/main_screen.dart';
import 'package:to_do_list/screens/new_task/models/new_task_screen_arguments.dart';
import 'package:to_do_list/screens/new_task/new_task_screen.dart';
import 'package:to_do_list/screens/profile/profile_screen.dart';
import 'package:to_do_list/screens/register/register_screen.dart';
import 'package:to_do_list/screens/reset_password/reset_password_screen.dart';
import 'package:to_do_list/screens/splash/splash_screen.dart';
import 'package:to_do_list/screens/start/start_screen.dart';
import 'package:to_do_list/screens/chat/chat_screen.dart';
import 'package:to_do_list/screens/update_profile/update_profile_screen.dart';
import 'package:to_do_list/widgets/auth_root.dart';

import 'data/data_sources/remote/firebase/auth_service.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final isUserLoggedIn = _authService.isUserLoggedIn();
    final isUserUpdatedProfile = _authService.isUserUpdatedProfile();

    final initialRoute = isUserLoggedIn
        ? isUserUpdatedProfile
        ? HomeScreen.routeName
        : UpdateProfileScreen.routeName
        : StartScreen.routeName;
    return MaterialApp(
      title: 'To-Do List',
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SplashScreen.routeName:
            return FadeInPageRoute(
              builder: (context) {
                return const SplashScreen();
              },
              settings: const RouteSettings(name: SplashScreen.routeName),
            );
          case MainScreen.routeName:
            return FadeInPageRoute(
              builder: (context) {
                return const MainScreen();
              },
              settings: const RouteSettings(name: MainScreen.routeName),
            );
          case HomeScreen.routeName:
            return FadeInPageRoute(
              builder: (context) {
                return const HomeScreen();
              },
              settings: const RouteSettings(name: HomeScreen.routeName),
            );
          case NewTaskScreen.routeName:
            return SlideUpPageRoute(
              builder: (context) {
                return NewTaskScreen(
                  arguments: settings.arguments as NewTaskScreenArguments,
                );
              },
              settings: const RouteSettings(name: NewTaskScreen.routeName),
            );
          case AllTasksScreen.routeName:
            return SlidePageRoute(
              builder: (context) {
                return AllTasksScreen(
                  arguments: settings.arguments as AllTasksScreenArguments,
                );
              },
              settings: const RouteSettings(name: AllTasksScreen.routeName),
            );
          case StartScreen.routeName:
            return FadeInPageRoute(
              builder: (context) {
                return const StartScreen();
              },
              settings: const RouteSettings(name: StartScreen.routeName),
            );
          case LoginScreen.routeName:
            return SlidePageRoute(
              builder: (context) {
                return const LoginScreen();
              },
              settings: const RouteSettings(name: LoginScreen.routeName),
            );
          case RegisterScreen.routeName:
            return SlidePageRoute(
              builder: (context) {
                return const RegisterScreen();
              },
              settings: const RouteSettings(name: RegisterScreen.routeName),
            );
          case ProfileScreen.routeName:
            return SlidePageRoute(
              builder: (context) {
                return const ProfileScreen();
              },
              settings: const RouteSettings(name: ProfileScreen.routeName),
            );
          case ResetPasswordScreen.routeName:
            return SlidePageRoute(
              builder: (context) {
                return const ResetPasswordScreen();
              },
              settings:
                  const RouteSettings(name: ResetPasswordScreen.routeName),
            );
          case UpdateProfileScreen.routeName:
            return FadeInPageRoute(
              builder: (context) {
                return const UpdateProfileScreen();
              },
              settings:
                  const RouteSettings(name: UpdateProfileScreen.routeName),
            );
          case ChatScreen.routeName:
            return SlideUpPageRoute(
              builder: (context) {
                return const ChatScreen();
              },
              settings: const RouteSettings(name: ChatScreen.routeName),
            );
          case ChangePasswordScreen.routeName:
            return SlidePageRoute(
              builder: (context) {
                return const ChangePasswordScreen();
              },
              settings:
                  const RouteSettings(name: ChangePasswordScreen.routeName),
            );
          default:
            return null;
        }
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
    );
  }
}

/// Hiệu ứng chuyển trang fade in (dùng cho trang khởi tạo)
class FadeInPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  FadeInPageRoute({
    required this.builder,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        );
}

/// Hiệu ứng chuyển trang trượt ngang (dùng cho các trang con)
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  SlidePageRoute({
    required this.builder,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.5, end: 1.0)
                    .animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// Hiệu ứng chuyển trang trượt từ dưới lên (dùng cho tạo task, chat)
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  SlideUpPageRoute({
    required this.builder,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0)
                    .animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}
