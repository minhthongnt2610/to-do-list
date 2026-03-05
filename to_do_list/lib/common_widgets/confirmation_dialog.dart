import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/primary_button.dart';
import 'package:to_do_list/common_widgets/tertiary_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmButtonTitle,
    required this.cancelButtonTitle,
    required this.onConfirm,
    required this.onCancel,
  });

  final String title;

  final String content;

  final String confirmButtonTitle;

  final String cancelButtonTitle;

  final VoidCallback onConfirm;

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TertiaryButton(
                    title: cancelButtonTitle,
                    onTap: onCancel,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: PrimaryButton(
                    title: confirmButtonTitle,
                    onTap: onConfirm,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
