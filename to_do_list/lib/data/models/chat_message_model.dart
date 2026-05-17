import 'package:to_do_list/data/models/suggested_task_model.dart';

class ChatMessageModel {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<SuggestedTask>? suggestedTasks;

  const ChatMessageModel({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.suggestedTasks,
  });

  @override
  String toString() {
    return 'ChatMessageModel(message: $message, isUser: $isUser, timestamp: $timestamp, suggestedTasks: $suggestedTasks)';
  }
}
