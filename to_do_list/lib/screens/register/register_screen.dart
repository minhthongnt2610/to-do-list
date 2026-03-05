import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/primary_button.dart';
import 'package:to_do_list/common_widgets/tertiary_button.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';
import 'package:to_do_list/data/services/dialog_service.dart';

import '../../common_widgets/primary_app_bar.dart';
import '../../constants/app_colors.dart';
import '../../utilities/utilities.dart';
import '../home/home_screen.dart';
import '../login/login_screen.dart';
import '../new_task/widgets/input_field.dart';
import '../update_profile/update_profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _email = 'todolist@mailinator.com';

  String? _password = 'Todolist12345@';

  String? _confirmPassword = 'Todolist12345@';

  final _authService = AuthService();
  final _dialogService = DialogService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _hideKeyboard();
      },
      child: Scaffold(
        backgroundColor: AppColors.hex020206,
        appBar: PrimaryAppBar(
          title: '',
          onBack: () {
            Navigator.of(context).pop();
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 64,
                  ),
                  const Text(
                    'Hello! Register to get started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  InputField(
                    initialValue: _email,
                    hintText: "Enter your email",
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  InputField(
                    hintText: "Enter your password",
                    initialValue: _password,
                    maxLines: 1,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                    'Confirm Password',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  InputField(
                    hintText: "Enter your password",
                    initialValue: _confirmPassword,
                    maxLines: 1,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 64,
                  ),
                  PrimaryButton(
                    title: 'Register',
                    onTap: () async {
                      await _register();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  TertiaryButton(
                    title: 'Login',
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(
                        LoginScreen.routeName,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 1,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'OR',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Divider(
            height: 1,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Future<void> _register() async {
    log("Register >> Email: $_email, Password: $_password, Confirm Password: $_confirmPassword");
    final error = _checkCredentials(
      email: _email,
      password: _password,
      confirmPassword: _confirmPassword,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      _dialogService.showErrorDialog(context: context, error: error);
    } else {
      try {
        _dialogService.showProgressDialog(context);
        await _authService.createUser(
          email: _email!,
          password: _password!,
        );
        await _authService.signIn(
          email: _email!,
          password: _password!,
        );
        if (!mounted) {
          return;
        }
        _dialogService.hideProgressDialog(context);
        _hideKeyboard();
        if (_authService.isUserUpdatedProfile()) {
          await Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.routeName,
            (route) => false,
          );
        } else {
          await Navigator.of(context).pushNamedAndRemoveUntil(
            UpdateProfileScreen.routeName,
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (error) {
        if (!mounted) {
          return;
        }
        _dialogService.hideProgressDialog(context);
        _dialogService.showErrorDialog(
          context: context,
          error: Utilities.cleanErrorMessage(error.message),
        );
      }
    }
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  String? _checkCredentials({
    required String? email,
    required String? password,
    required String? confirmPassword,
  }) {
    if (email?.isEmpty ?? true) {
      return 'Email cannot be empty.';
    }
    if (!Utilities.isValidEmail(email!)) {
      return 'Invalid email format.';
    }
    if (password?.isEmpty ?? true) {
      return 'Password cannot be empty.';
    }
    if (!Utilities.isValidPassword(password!)) {
      return 'Invalid password format.';
    }

    if (confirmPassword?.isEmpty ?? true) {
      return 'Confirm password cannot be empty.';
    }

    if (password != confirmPassword) {
      return 'Password and confirm password do not match.';
    }

    return null;
  }
}
