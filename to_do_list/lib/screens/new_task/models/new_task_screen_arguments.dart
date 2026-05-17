import '../../../data/models/task_model.dart';

/// Khai báo thaam số cho màn hình NewTaskScreen
class NewTaskScreenArguments {
  /// Công việc cần chỉnh sửa
  /// - Nếu taskModel == null thì mang nghĩa là tạo công việc mới
  /// - Nếu taskModel != null thì mang nghĩa là chỉnh sửa công việc
  final TaskModel? taskModel;

  /// Nếu true, taskModel chỉ dùng để điền sẵn dữ liệu (tạo mới, không phải edit)
  final bool isPreFilled;

  const NewTaskScreenArguments({
    this.taskModel,
    this.isPreFilled = false,
  });
}
