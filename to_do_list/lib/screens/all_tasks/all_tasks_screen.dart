import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/primary_app_bar.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/firestore_service.dart';
import 'package:to_do_list/data/models/firebase/fb_task_model.dart';
import 'package:to_do_list/screens/home/widgets/task_item.dart';

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

  @override
  void initState() {
    super.initState();
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
        return DefaultTabController(
          /// Số lượng tab
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.hex020206,
            appBar: PrimaryAppBar(
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
        );
      },
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
          taskModel: taskModel,
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
            _navigateToNewTaskScreen(taskModel: taskModel);
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
