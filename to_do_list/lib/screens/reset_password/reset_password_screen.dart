import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/data/services/dialog_service.dart';
import 'package:to_do_list/screens/login/login_screen.dart';

import '../../common_widgets/info_dialog.dart';
import '../../common_widgets/primary_app_bar.dart';
import '../../common_widgets/primary_button.dart';
import '../../constants/app_colors.dart';
import '../../data/data_sources/remote/firebase/auth_service.dart';
import '../../utilities/utilities.dart';
import '../new_task/widgets/input_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const routeName = '/reset-password';

  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String? _email = '';

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
                  const SizedBox(height: 128),
                  const Text(
                    'Forgot your password?',
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
                    'Please enter your email address. You will receive a link to create a new password via email.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
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
                    height: 64,
                  ),
                  PrimaryButton(
                    title: 'Reset Password',
                    onTap: () async {
                      await _resetPassword();
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

  Future<void> _resetPassword() async {
    log("Reset password >> Email: $_email");
    final error = _checkCredentials(
      email: _email,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      _dialogService.showErrorDialog(context: context, error: error);
    } else {
      try {
        _dialogService.showProgressDialog(context);
        await _authService.sendPasswordResetEmail(
          email: _email!,
        );
        if (!mounted) {
          return;
        }
        _dialogService.hideProgressDialog(context);
        _hideKeyboard();
        _showResetPasswordInfoDialog(
          context: context,
        );
      } on FirebaseAuthException catch (error) {
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
  }) {
    if (email?.isEmpty ?? true) {
      return 'Email cannot be empty.';
    }
    if (!Utilities.isValidEmail(email!)) {
      return 'Invalid email format.';
    }

    return null;
  }

  void _showResetPasswordInfoDialog({
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return InfoDialog(
          title: "Reset Password",
          content:
              'Please check your email to reset your password. Then login again. Thank you!',
          confirmButtonTitle: "OK",
          onConfirm: () {
            Navigator.of(context).popUntil((route) {
              return route.settings.name == LoginScreen.routeName;
            });
          },
        );
      },
    );
  }
}
