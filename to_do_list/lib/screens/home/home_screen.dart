import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/data/models/firebase/fb_task_model.dart';
import 'package:to_do_list/data/models/task_model.dart';
import 'package:to_do_list/data/models/task_status.dart';
import 'package:to_do_list/data/services/excel_export_service.dart';
import 'package:to_do_list/screens/all_tasks/all_tasks_screen.dart';
import 'package:to_do_list/screens/home/widgets/header_item.dart';
import 'package:to_do_list/screens/home/widgets/home_app_bar.dart';
import 'package:to_do_list/screens/home/widgets/progress_item.dart';
import 'package:to_do_list/screens/home/widgets/search_field.dart';
import 'package:to_do_list/screens/home/widgets/task_item.dart';
import '../../common_widgets/confirmation_dialog.dart';
import '../../constants/app_colors.dart';
import '../../data/data_sources/remote/firebase/auth_service.dart';
import '../../data/data_sources/remote/firebase/firestore_service.dart';
import '../../data/data_sources/remote/firebase/notification_service.dart';
import '../all_tasks/models/all_tasks_screen_arguments.dart';
import '../new_task/models/new_task_screen_arguments.dart';
import '../new_task/new_task_screen.dart';


class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  
  const HomeScreen({super.key});

  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  User? _user;

  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _notificationService = NotificationService.instance;
  final _excelExportService = ExcelExportService();

  /// Chế độ chọn nhiều task
  bool _isSelectionMode = false;
  bool _isExporting = false;

  /// Danh sách các task ID được chọn
  final Set<String> _selectedTaskIds = {};

  /// Danh sách tất cả tasks từ Firestore (dùng cho xuất Excel)
  List<TaskModel> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _initUser();

    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        log('User is currently signed out!');
      } else {
        final user = _authService.currentUser;
        if (!mounted) return;
        setState(() {
          _user = user;
        });
      }
    });
  }

  Future<void> _initUser() async {
    _user = _authService.currentUser;
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

  /// Chọn tất cả task
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
          content:
              'Are you sure you want to delete $count selected task${count > 1 ? 's' : ''}?',
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
      stream: _firestoreService.getTasks(_user!.uid),
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

        final tasks = snapshot.data
            ?.map((fbTaskModel) => fbTaskModel.toTaskModel())
            .toList();
        if (tasks == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Cập nhật danh sách tasks cho xuất Excel
        _allTasks = tasks;

        // Đồng bộ scheduled notifications mỗi khi task data thay đổi
        _notificationService.rescheduleAllReminders(tasks);

        
        final todayTasks = tasks.where((task) {
          
          return DateUtils.isSameDay(
            task.date,
            DateTime.now(),
          );
        }).toList();

        
        final tomorrowTasks = tasks.where((task) {
          
          return DateUtils.isSameDay(
            task.date,
            DateTime.now().add(
              const Duration(days: 1),
            ),
          );
        }).toList();

        
        final numberOfCompletedTodayTask = todayTasks.where((task) {
          
          return task.status == TaskStatus.complete;
        }).length;

        /// Tất cả task hiển thị trên màn hình (today + tomorrow)
        final allVisibleTasks = [...todayTasks, ...tomorrowTasks];

        
        return PopScope(
          canPop: !_isSelectionMode,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _isSelectionMode) {
              _exitSelectionMode();
            }
          },
          child: GestureDetector(
            onTap: () {
              
              FocusScope.of(context).unfocus();
            },

          
          child: Scaffold(
            
            backgroundColor: AppColors.hex020206,

            
            appBar: _isSelectionMode
                ? _buildSelectionAppBar(allVisibleTasks)
                : HomeAppBar(
                    onSearchChanged: (value) {
                      log("Search text changed: $value");
                    },
                    user: _user!,
                    onExportExcel: _isExporting ? null : _exportToExcel,
                    isExporting: _isExporting,
                  ),

            
            body: SafeArea(
              child: SingleChildScrollView(
                
                child: Column(
                  
                  children: [
                    /// Ẩn search và progress khi ở chế độ chọn nhiều
                    if (!_isSelectionMode) ...[
                      Padding(
                        
                        padding: const EdgeInsets.symmetric(
                          
                          vertical: 12,

                          
                          horizontal: 20,
                        ),

                        
                        child: SearchField(
                          
                          hintText: "Search Task Here",

                          
                          onChanged: (value) {
                            
                            log("Search text changed: $value");
                          },
                        ),
                      ),

                      
                      HeaderItem(
                        title: 'Progress',
                        onSeeAllTap: () {
                          _navigateToAllTasksScreen();
                        },
                      ),

                      
                      ProgressItem(
                        
                        numberOfCompletedTask: numberOfCompletedTodayTask,

                        
                        numberOfTasks: todayTasks.length,
                      ),
                    ],

                    
                    HeaderItem(
                      title: "Today's Task",
                      onSeeAllTap: () {
                        _navigateToAllTasksScreen();
                      },
                    ),

                    
                    _buildTaskListWidget(todayTasks),

                    
                    HeaderItem(
                      title: "Tomorrow's Task",
                      onSeeAllTap: () {
                        _navigateToAllTasksScreen();
                      },
                    ),

                    
                    _buildTaskListWidget(tomorrowTasks),

                    
                    const SizedBox(
                      
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),

            floatingActionButton: null,
            ),
          ),
        );
      },
    );
  }

  /// AppBar khi ở chế độ chọn nhiều task
  PreferredSizeWidget _buildSelectionAppBar(List<TaskModel> allVisibleTasks) {
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
            if (_selectedTaskIds.length == allVisibleTasks.length) {
              _deselectAll();
            } else {
              _selectAll(allVisibleTasks);
            }
          },
          child: Text(
            _selectedTaskIds.length == allVisibleTasks.length
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

  
  Future<void> _navigateToAllTasksScreen() async {
    
    
    await Navigator.of(context).pushNamed(
      
      AllTasksScreen.routeName,

      
      arguments: const AllTasksScreenArguments(),
    );
  }

  
  
  
  Future<void> _navigateToNewTaskScreen({TaskModel? taskModel}) async {
    
    
    final result = await Navigator.of(context).pushNamed(
      
      NewTaskScreen.routeName,

      
      arguments: NewTaskScreenArguments(
        taskModel: taskModel,
      ),
    ) as bool?;

    
    if (result != true) {
      return;
    }
  }

  Widget _buildTaskListWidget(List<TaskModel> taskModels) {
    if (taskModels.isEmpty) {
      return Container(
        width: double.infinity,

        
        margin: const EdgeInsets.symmetric(
          
          horizontal: 20,
        ),

        
        padding: const EdgeInsets.symmetric(
          
          horizontal: 20,

          
          vertical: 32,
        ),

        
        decoration: BoxDecoration(
          
          borderRadius: BorderRadius.circular(8),

          
          color: AppColors.hex181818,
        ),

        
        child: Text(
          'You have no task to complete.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView.builder(
        
        padding: EdgeInsets.zero,

        
        physics: const NeverScrollableScrollPhysics(),

        
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
                userId: _user!.uid,
                taskModel: fbTaskModel,
              );
            },
            onTap: () {
              if (_isSelectionMode) {
                if (taskModel.id != null) {
                  _toggleTaskSelection(taskModel.id!);
                }
              } else {
                _navigateToNewTaskScreen(
                  taskModel: taskModel,
                );
              }
            },
          );
        },

        
        itemCount: taskModels.length,

        
        shrinkWrap: true,
      );
    }
  }

  /// Xuất tất cả task ra file Excel
  Future<void> _exportToExcel() async {
    if (_allTasks.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có task nào để xuất!'),
          backgroundColor: AppColors.hex181818,
        ),
      );
      return;
    }
    setState(() => _isExporting = true);
    try {
      await _excelExportService.exportTasksToExcel(_allTasks);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xuất Excel: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
