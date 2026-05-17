import 'package:flutter/material.dart';
import 'package:to_do_list/constants/app_colors.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField({
    required this.controller,
    required this.onSend,
    required this.isLoading,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.hex020206,
        border: Border(
          top: BorderSide(
            color: AppColors.hex181818.withOpacity(0.8),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.hex181818,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.hex4F4F4F.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Nhập yêu cầu lên kế hoạch...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: isLoading ? null : (_) => onSend(),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Send button
            GestureDetector(
              onTap: isLoading ? null : onSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isLoading
                      ? LinearGradient(
                          colors: [
                            AppColors.hex4F4F4F.withOpacity(0.5),
                            AppColors.hex4F4F4F.withOpacity(0.3),
                          ],
                        )
                      : const LinearGradient(
                          colors: [AppColors.hexBA83DE, AppColors.hexDE83B0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  boxShadow: isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.hexBA83DE.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  isLoading ? Icons.hourglass_top_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
