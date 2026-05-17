import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/primary_app_bar.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/firestore_service.dart';
import 'package:to_do_list/data/models/firebase/fb_task_model.dart';
import 'package:to_do_list/screens/home/widgets/task_item.dart';

import '../../common_widgets/confirmation_dialog.dart';
import '../../constants/app_colors.dart';
import '../../data/models/task_model.dart';
import '../new_task/models/new_task_screen_arguments.dart';
import '../new_task/new_task_screen.dart';
import 'models/all_tasks_screen_arguments.dart';

/// Màn hình hiển thị tất cả công việc
class AllTasksScreen extends StatefulWidget {
  static const routeName = '/all-tasks';

  const AllTasksScreen({
    required this.arguments,
    super.key,
  });

  final AllTasksScreenArguments arguments;

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  final _firestoreService = FirestoreService();

  final _authService = AuthService();

  /// Chế độ chọn nhiều task
  bool _isSelectionMode = false;

  /// Danh sách các task ID được chọn
  final Set<String> _selectedTaskIds = {};

  @override
  void initState() {
    super.initState();
  }

  /// Bật chế độ chọn nhiều task
  void _enterSelectionMode(String taskId) {
    setState(() {
      _isSelectionMode = true;
      _selectedTaskIds.add(taskId);
    });
  }

  /// Tắt chế độ chọn nhiều task
  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTaskIds.clear();
    });
  }

  /// Chọn / bỏ chọn một task
  void _toggleTaskSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
        if (_selectedTaskIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  /// Chọn tất cả task trong danh sách hiện tại
  void _selectAll(List<TaskModel> tasks) {
    setState(() {
      _selectedTaskIds.clear();
      for (final task in tasks) {
        if (task.id != null) {
          _selectedTaskIds.add(task.id!);
        }
      }
    });
  }

  /// Bỏ chọn tất cả
  void _deselectAll() {
    setState(() {
      _selectedTaskIds.clear();
    });
  }

  /// Xóa nhiều task đã chọn
  Future<void> _deleteSelectedTasks() async {
    if (_selectedTaskIds.isEmpty) return;

    final isConfirmed = await _showDeleteConfirmationDialog(
      context: context,
      count: _selectedTaskIds.length,
    );

    if (isConfirmed != true) return;

    await _firestoreService.deleteTasks(
      userId: _authService.currentUser!.uid,
      taskIds: _selectedTaskIds.toList(),
    );

    _exitSelectionMode();
  }

  /// Hiển thị dialog xác nhận xóa nhiều task
  Future<bool?> _showDeleteConfirmationDialog({
    required BuildContext context,
    required int count,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Delete Tasks',
          content: 'Are you sure you want to delete $count selected task${count > 1 ? 's' : ''}?',
          confirmButtonTitle: 'Delete',
          cancelButtonTitle: 'Cancel',
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
          onCancel: () {
            Navigator.of(context).pop(false);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestoreService.getTasks(_authService.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        final allTasks = snapshot.data
            ?.map((fbTaskModel) => fbTaskModel.toTaskModel())
            .toList();

        if (allTasks == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        /// Danh sách công việc trong ngày sử dụng hàm where để lọc các công việc trong ngày
        final todayTasks = allTasks.where((task) {
          /// So sánh ngày của công việc với ngày hiện tại
          return DateUtils.isSameDay(
            task.date,
            DateTime.now(),
          );
        }).toList();

        /// Danh sách công việc trong ngày mai sử dụng hàm where để lọc các công việc trong ngày mai
        final tomorrowTasks = allTasks.where((task) {
          /// So sánh ngày của công việc với ngày mai
          return DateUtils.isSameDay(
            task.date,
            DateTime.now().add(
              const Duration(days: 1),
            ),
          );
        }).toList();

        /// DefaultTabController là một widget dùng để tạo ra một TabController mặc định cho TabBar và TabBarView
        return PopScope(
          canPop: !_isSelectionMode,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _isSelectionMode) {
              _exitSelectionMode();
            }
          },
          child: DefaultTabController(
            /// Số lượng tab
            length: 3,
            child: Scaffold(
            backgroundColor: AppColors.hex020206,
            appBar: _isSelectionMode
                ? _buildSelectionAppBar(allTasks, todayTasks, tomorrowTasks)
                : PrimaryAppBar(
                    title: 'All Tasks',
                    onBack: () {
                      Navigator.of(context).pop();
                    },
                  ),
            body: Column(
              children: [
                /// TabBar là một widget dùng để hiển thị các tab
                const TabBar(
                  /// Màu của tab được chọn
                  indicatorColor: AppColors.hexDE83B0,

                  /// Độ dày của tab được chọn
                  indicatorWeight: 2,

                  /// Kích thước của tab được chọn
                  indicatorSize: TabBarIndicatorSize.tab,

                  /// Màu chữ của tab
                  labelColor: AppColors.hexDE83B0,

                  /// Kiểu chữ của tab
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),

                  /// Danh sách các tab
                  tabs: [
                    Tab(text: 'All'),
                    Tab(text: 'Today'),
                    Tab(text: 'Tomorrow'),
                  ],
                ),
                Expanded(
                  /// TabBarView là một widget dùng để hiển thị nội dung của các tab
                  child: TabBarView(
                    children: [
                      /// Hiển thị tất cả công việc
                      _buildTabBarContentView(taskModels: allTasks),

                      /// Hiển thị công việc trong ngày
                      _buildTabBarContentView(taskModels: todayTasks),

                      /// Hiển thị công việc trong ngày mai
                      _buildTabBarContentView(taskModels: tomorrowTasks),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  /// AppBar khi ở chế độ chọn nhiều task
  PreferredSizeWidget _buildSelectionAppBar(
    List<TaskModel> allTasks,
    List<TaskModel> todayTasks,
    List<TaskModel> tomorrowTasks,
  ) {
    /// Lấy danh sách task hiện tại theo tab đang hiển thị
    /// (Sử dụng DefaultTabController.of để lấy tab hiện tại)
    return AppBar(
      backgroundColor: AppColors.hex181818,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: _exitSelectionMode,
      ),
      title: Text(
        '${_selectedTaskIds.length} selected',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        /// Nút chọn tất cả
        TextButton(
          onPressed: () {
            /// Chọn tất cả task (dùng allTasks vì đơn giản)
            if (_selectedTaskIds.length == allTasks.length) {
              _deselectAll();
            } else {
              _selectAll(allTasks);
            }
          },
          child: Text(
            _selectedTaskIds.length == allTasks.length
                ? 'Deselect All'
                : 'Select All',
            style: const TextStyle(
              color: AppColors.hexBA83DE,
              fontSize: 14,
            ),
          ),
        ),

        /// Nút xóa nhiều task
        IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.redAccent,
          ),
          onPressed: _selectedTaskIds.isEmpty ? null : _deleteSelectedTasks,
        ),
      ],
    );
  }

  /// Hàm build chứa nội dung của TabBarView
  Widget _buildTabBarContentView({
    required List<TaskModel> taskModels,
  }) {
    if (taskModels.isEmpty) {
      return Center(
        child: Text(
          'You have no task to complete.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, index) {
        final taskModel = taskModels[index];
        return TaskItem(
          key: ValueKey(taskModel.id),
          taskModel: taskModel,
          isSelectionMode: _isSelectionMode,
          isSelected: taskModel.id != null &&
              _selectedTaskIds.contains(taskModel.id),
          onLongPress: () {
            if (!_isSelectionMode && taskModel.id != null) {
              _enterSelectionMode(taskModel.id!);
            }
          },
          onStatusChanged: (taskStatus) async {
            final fbTaskModel = taskModel
                .copyWith(
                  status: taskStatus,
                )
                .toFbTaskModel();
            await _firestoreService.updateTask(
              taskModel: fbTaskModel,
              userId: _authService.currentUser!.uid,
            );
          },
          onTap: () {
            if (_isSelectionMode) {
              if (taskModel.id != null) {
                _toggleTaskSelection(taskModel.id!);
              }
            } else {
              _navigateToNewTaskScreen(taskModel: taskModel);
            }
          },
        );
      },
      itemCount: taskModels.length,
    );
  }

  /// Điều hướng đến màn hình tạo công việc mới
  /// - Nếu taskModel == null thì mang nghĩa là tạo công việc mới
  /// - Nếu taskModel != null thì mang nghĩa là chỉnh sửa công việc
  Future<void> _navigateToNewTaskScreen({TaskModel? taskModel}) async {
    /// Sử dụng hàm pushNamed để điều hướng tới
    /// màn hình tạo công việc mới
    final result = await Navigator.of(context).pushNamed(
      /// Đường dẫn của màn hình tạo công việc mới
      NewTaskScreen.routeName,

      /// Tham số truuyền vào màn hình tạo công việc mới
      arguments: NewTaskScreenArguments(
        taskModel: taskModel,
      ),
    ) as bool?;

    /// Nếu không có công việc mới
    if (result != true) {
      return;
    }
  }
}
