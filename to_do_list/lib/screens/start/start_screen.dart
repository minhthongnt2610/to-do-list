import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/primary_button.dart';
import 'package:to_do_list/common_widgets/tertiary_button.dart';
import 'package:to_do_list/screens/login/login_screen.dart';

import '../../constants/app_colors.dart';
import '../register/register_screen.dart';

class StartScreen extends StatefulWidget {
  static const routeName = '/start';

  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hex020206,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 128),
              const Text(
                'Welcome to Simple ToDo List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                'Please login to your account or register\nnew account to continue',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                title: 'Login',
                onTap: () {
                  Navigator.of(context).pushNamed(LoginScreen.routeName);
                },
              ),
              const SizedBox(height: 24),
              TertiaryButton(
                title: 'Register',
                onTap: () {
                  Navigator.of(context).pushNamed(RegisterScreen.routeName);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
