import '../../../data/models/task_model.dart';

/// Khai báo thaam số cho màn hình NewTaskScreen
class NewTaskScreenArguments {
  /// Công việc cần chỉnh sửa
  /// - Nếu taskModel == null thì mang nghĩa là tạo công việc mới
  /// - Nếu taskModel != null thì mang nghĩa là chỉnh sửa công việc
  final TaskModel? taskModel;

  const NewTaskScreenArguments({
    this.taskModel,
  });
}
