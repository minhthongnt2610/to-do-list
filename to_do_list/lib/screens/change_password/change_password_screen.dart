import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/info_dialog.dart';
import 'package:to_do_list/common_widgets/primary_app_bar.dart';
import 'package:to_do_list/common_widgets/primary_button.dart';
import 'package:to_do_list/constants/app_colors.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';
import 'package:to_do_list/data/services/dialog_service.dart';
import 'package:to_do_list/screens/new_task/widgets/input_field.dart';
import 'package:to_do_list/screens/start/start_screen.dart';
import 'package:to_do_list/utilities/utilities.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const routeName = '/change-password';

  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String? _currentPassword;
  String? _newPassword;
  String? _confirmPassword;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final _authService = AuthService();
  final _dialogService = DialogService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideKeyboard,
      child: Scaffold(
        backgroundColor: AppColors.hex020206,
        appBar: PrimaryAppBar(
          title: 'Change Password',
          onBack: () => Navigator.of(context).pop(),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon minh họa
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.hexBA83DE, AppColors.hexDE83B0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.hexBA83DE.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Create new password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your current password to verify, then set a new password.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 40),

                // Mật khẩu hiện tại
                _buildLabel('Current password'),
                const SizedBox(height: 8),
                _buildPasswordField(
                  hint: 'Enter current password',
                  obscure: _obscureCurrent,
                  onChanged: (v) => setState(() => _currentPassword = v),
                  onToggle: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),

                const SizedBox(height: 24),

                // Mật khẩu mới
                _buildLabel('New password'),
                const SizedBox(height: 8),
                _buildPasswordField(
                  hint: 'Enter new password',
                  obscure: _obscureNew,
                  onChanged: (v) => setState(() => _newPassword = v),
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),

                const SizedBox(height: 24),

                // Xác nhận mật khẩu mới
                _buildLabel('Confirm new password'),
                const SizedBox(height: 8),
                _buildPasswordField(
                  hint: 'Confirm new password',
                  obscure: _obscureConfirm,
                  onChanged: (v) => setState(() => _confirmPassword = v),
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),

                // Gợi ý độ mạnh mật khẩu
                const SizedBox(height: 12),
                _buildPasswordHint(),

                const SizedBox(height: 40),

                PrimaryButton(
                  title: 'Update password',
                  onTap: _changePassword,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Label cho input field
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Password input với nút toggle hiển thị
  Widget _buildPasswordField({
    required String hint,
    required bool obscure,
    required ValueChanged<String> onChanged,
    required VoidCallback onToggle,
  }) {
    return Stack(
      children: [
        InputField(
          hintText: hint,
          initialValue: null,
          maxLines: 1,
          obscureText: obscure,
          onChanged: onChanged,
        ),
        Positioned(
          right: 4,
          top: 0,
          bottom: 0,
          child: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      ],
    );
  }

  /// Gợi ý yêu cầu mật khẩu
  Widget _buildPasswordHint() {
    final password = _newPassword ?? '';
    final checks = [
      _HintItem('At least 8 characters', password.length >= 8),
      _HintItem('Contains uppercase letter (A-Z)', password.contains(RegExp(r'[A-Z]'))),
      _HintItem('Contains number (0-9)', password.contains(RegExp(r'[0-9]'))),
      _HintItem(
          'Contains special character', password.contains(RegExp(r'[!@#\$%^&*]'))),
    ];

    if (password.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.hex181818,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.hexBA83DE.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: checks
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      item.passed
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: item.passed
                          ? const Color(0xFF4CAF50)
                          : Colors.white.withValues(alpha: 0.35),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: item.passed
                            ? const Color(0xFF4CAF50)
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _changePassword() async {
    final error = _validate();
    if (error != null) {
      _dialogService.showErrorDialog(context: context, error: error);
      return;
    }

    _hideKeyboard();
    _dialogService.showProgressDialog(context);

    try {
      await _authService.changePassword(
        currentPassword: _currentPassword!,
        newPassword: _newPassword!,
      );

      if (!mounted) return;
      _dialogService.hideProgressDialog(context);
      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _dialogService.hideProgressDialog(context);

      final msg = _mapFirebaseError(e.code);
      _dialogService.showErrorDialog(context: context, error: msg);
    } catch (e) {
      if (!mounted) return;
      _dialogService.hideProgressDialog(context);
      _dialogService.showErrorDialog(
        context: context,
        error: 'An error occurred. Please try again.',
      );
    }
  }

  String? _validate() {
    if (_currentPassword?.isEmpty ?? true) {
      return 'Please enter current password.';
    }
    if (_newPassword?.isEmpty ?? true) {
      return 'Please enter new password.';
    }
    if (!Utilities.isValidPassword(_newPassword!)) {
      return 'New password must be at least 8 characters long, including uppercase, number and special character.';
    }
    if (_newPassword == _currentPassword) {
      return 'New password must not be the same as current password.';
    }
    if (_confirmPassword != _newPassword) {
      return 'Confirm password does not match.';
    }
    return null;
  }

  /// Map Firebase error code sang thông báo tiếng Việt
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect. Please try again.';
      case 'weak-password':
        return 'New password is too weak. Please choose a stronger password.';
      case 'requires-recent-login':
        return 'Your login session has expired. Please log out and log in again.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => InfoDialog(
        title: 'Password changed! 🎉',
        content:
            'Your password has been changed successfully.\nPlease log in again with your new password.',
        confirmButtonTitle: 'Log in again',
        onConfirm: () async {
          Navigator.of(context).pop(); // đóng dialog
          // Sign out và về màn hình Start
          await _authService.signOut();
          if (!mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

/// Model dữ liệu cho mỗi hint item
class _HintItem {
  const _HintItem(this.label, this.passed);
  final String label;
  final bool passed;
}
