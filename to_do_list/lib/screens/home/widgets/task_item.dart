import 'package:flutter/material.dart';
import 'package:to_do_list/data/models/task_priority.dart';
import 'package:to_do_list/data/models/task_status.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_icons.dart';
import '../../../data/models/task_model.dart';

/// Widget hiển thị một công việc trong danh sách
/// Hỗ trợ chế độ chọn nhiều task (selection mode)
class TaskItem extends StatelessWidget {
  const TaskItem({
    required this.taskModel,
    required this.onStatusChanged,
    required this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    super.key,
  });

  final TaskModel taskModel;
  final ValueChanged<TaskStatus> onStatusChanged;
  final VoidCallback onTap;

  /// Chế độ chọn nhiều task
  final bool isSelectionMode;

  /// Task có đang được chọn không
  final bool isSelected;

  /// Callback khi nhấn giữ task
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.translucent,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? AppColors.hexDE83B0.withValues(alpha: 0.08)
                : AppColors.hex181818,
            border: Border.all(
              color: isSelected
                  ? AppColors.hexDE83B0.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              /// Phần bên trái: Priority bar hoặc Checkbox
              _buildLeading(),

              /// Nội dung task
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isSelectionMode ? 0 : 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        taskModel.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Image.asset(
                            AppIcons.calendar,
                            width: 15,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            taskModel.displayDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// Phần bên phải: Nút trạng thái hoặc badge priority
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget phần bên trái: chuyển đổi mượt giữa priority bar và checkbox
  Widget _buildLeading() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axis: Axis.horizontal,
            child: child,
          ),
        );
      },
      child: isSelectionMode
          ? _buildCheckbox()
          : _buildPriorityBar(),
    );
  }

  /// Thanh màu hiển thị priority
  Widget _buildPriorityBar() {
    return Container(
      key: const ValueKey('priority_bar'),
      width: 15,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        color: taskModel.priority.color,
      ),
    );
  }

  /// Checkbox tròn khi ở chế độ chọn nhiều
  Widget _buildCheckbox() {
    return Container(
      key: const ValueKey('checkbox'),
      width: 50,
      height: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.hexDE83B0 : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? AppColors.hexDE83B0
                  : Colors.white.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isSelected ? 1.0 : 0.0,
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget phần bên phải: nút trạng thái hoặc badge priority nhỏ
  Widget _buildTrailing() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: isSelectionMode
          ? _buildPriorityBadge()
          : _buildStatusButton(),
    );
  }

  /// Nút thay đổi trạng thái complete/incomplete
  Widget _buildStatusButton() {
    return GestureDetector(
      key: const ValueKey('status_button'),
      onTap: () {
        if (taskModel.status == TaskStatus.complete) {
          onStatusChanged.call(TaskStatus.incomplete);
        } else {
          onStatusChanged.call(TaskStatus.complete);
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          taskModel.status.icon,
          width: 26,
          height: 26,
        ),
      ),
    );
  }

  /// Badge nhỏ hiển thị priority khi ở chế độ chọn nhiều
  Widget _buildPriorityBadge() {
    return Padding(
      key: const ValueKey('priority_badge'),
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: taskModel.priority.color,
        ),
      ),
    );
  }
}
