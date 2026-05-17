import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/primary_app_bar.dart';
import 'package:to_do_list/common_widgets/primary_button.dart';
import 'package:to_do_list/common_widgets/tertiary_button.dart';
import 'package:to_do_list/data/services/dialog_service.dart';
import 'package:to_do_list/screens/register/register_screen.dart';
import 'package:to_do_list/screens/reset_password/reset_password_screen.dart';
import 'package:to_do_list/utilities/utilities.dart';

import '../../constants/app_colors.dart';
import '../../data/data_sources/remote/firebase/auth_service.dart';
import '../new_task/widgets/input_field.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _email = '';

  String? _password = '';

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
                    'Welcome back! Glad\nto see you, Again!',
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
                    keyboardType: TextInputType.emailAddress,
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
                    height: 16,
                  ),
                  GestureDetector(
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppColors.hexBA83DE,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ResetPasswordScreen.routeName,
                      );
                    },
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  PrimaryButton(
                    title: 'Login',
                    onTap: () async {
                      await _login();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  TertiaryButton(
                    title: 'Register',
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(
                        RegisterScreen.routeName,
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

  Future<void> _login() async {
    log("Login >> Email: $_email, Password: $_password");
    final error = _checkCredentials(
      email: _email,
      password: _password,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      _dialogService.showErrorDialog(context: context, error: error);
    } else {
      try {
        _dialogService.showProgressDialog(context);
        await _authService.signIn(
          email: _email!,
          password: _password!,
        );
        if (!mounted) {
          return;
        }
        _dialogService.hideProgressDialog(context);
        _hideKeyboard();
        // Về AuthRoot (route đầu) để quản lý session thống nhất
        Navigator.of(context).popUntil((route) => route.isFirst);
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

    return null;
  }
}
