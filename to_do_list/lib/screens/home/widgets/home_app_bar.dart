import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common_widgets/avatar.dart';
import '../../../constants/app_colors.dart';


class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  const HomeAppBar({
    required this.onSearchChanged,
    required this.user,
    this.onExportExcel,
    this.isExporting = false,
    super.key,
  });

  final ValueChanged<String> onSearchChanged;
  final User user;
  /// Callback xuất Excel, null nếu đang xuất
  final VoidCallback? onExportExcel;
  /// Trạng thái đang xuất Excel
  final bool isExporting;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.hex020206,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      scrolledUnderElevation: 0,
      title: Text(
        greet(),
        maxLines: 2,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      titleSpacing: 20,
      actions: [
        // Nút xuất Excel
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Tooltip(
            message: 'Xuất Excel',
            child: isExporting
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.hexBA83DE,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: onExportExcel,
                    icon: const Icon(
                      Icons.file_download_outlined,
                      color: AppColors.hexBA83DE,
                      size: 24,
                    ),
                  ),
          ),
        ),
        // Avatar người dùng (chỉ hiển thị, không navigate vì Profile đã ở bottom nav)
        GestureDetector(
          child: Avatar(
            user: user,
            size: 45,
          ),
          onTap: () {},
        ),
        const SizedBox(width: 20),
      ],
      centerTitle: false,
    );
  }

  String greet() {
    var hour = DateTime.now().hour;
    var name = user.displayName ?? 'Anonymous';
    var greeting = '';
    if (hour < 12) {
      greeting = 'Good morning ☀️';
    } else if (hour < 18) {
      greeting = 'Good afternoon 🌤️';
    } else {
      greeting = 'Good evening 🌃';
    }
    return '$greeting,\n$name 🖐️';
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
