import 'package:flutter/material.dart';
import 'package:to_do_list/screens/all_tasks/all_tasks_screen.dart';
import 'package:to_do_list/screens/all_tasks/models/all_tasks_screen_arguments.dart';
import 'package:to_do_list/screens/home/home_screen.dart';
import 'package:to_do_list/screens/login/login_screen.dart';
import 'package:to_do_list/screens/new_task/models/new_task_screen_arguments.dart';
import 'package:to_do_list/screens/new_task/new_task_screen.dart';
import 'package:to_do_list/screens/profile/profile_screen.dart';
import 'package:to_do_list/screens/register/register_screen.dart';
import 'package:to_do_list/screens/reset_password/reset_password_screen.dart';
import 'package:to_do_list/screens/start/start_screen.dart';
import 'package:to_do_list/screens/update_profile/update_profile_screen.dart';

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
          case HomeScreen.routeName:
            return FadeInPageRoute(
              builder: (context) {
                return const HomeScreen();
              },
              settings: const RouteSettings(name: HomeScreen.routeName),
            );
          case NewTaskScreen.routeName:
            return MaterialPageRoute(
              builder: (context) {
                return NewTaskScreen(
                  arguments: settings.arguments as NewTaskScreenArguments,
                );
              },
              settings: const RouteSettings(name: NewTaskScreen.routeName),
            );
          case AllTasksScreen.routeName:
            return MaterialPageRoute(
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
            return MaterialPageRoute(
              builder: (context) {
                return const LoginScreen();
              },
              settings: const RouteSettings(name: LoginScreen.routeName),
            );
          case RegisterScreen.routeName:
            return MaterialPageRoute(
              builder: (context) {
                return const RegisterScreen();
              },
              settings: const RouteSettings(name: RegisterScreen.routeName),
            );
          case ProfileScreen.routeName:
            return MaterialPageRoute(
              builder: (context) {
                return const ProfileScreen();
              },
              settings: const RouteSettings(name: ProfileScreen.routeName),
            );
          case ResetPasswordScreen.routeName:
            return MaterialPageRoute(
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

class FadeInPageRoute<T> extends MaterialPageRoute<T> {
  FadeInPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return false;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Opacity(
      opacity: animation.value,
      child: child,
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}
