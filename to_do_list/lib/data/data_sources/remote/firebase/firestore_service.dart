import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/data/models/firebase/fb_task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// Thêm một công việc mới
  Future<void> addTask({
    required String userId,
    required FbTaskModel taskModel,
  }) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add(taskModel.toJson());
  }

  /// Cập nhật thông tin công việc
  Future<void> updateTask({
    required String userId,
    required FbTaskModel taskModel,
  }) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskModel.id)
        .update(taskModel.toJson());
  }

  /// Xóa công việc
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  /// Lấy danh sách tất cả công việc của một người dùng
  Stream<List<FbTaskModel>> getTasks(String userId) {
    return _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FbTaskModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
