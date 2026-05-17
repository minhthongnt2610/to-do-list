import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/primary_app_bar.dart';
import 'package:to_do_list/constants/app_colors.dart';
import 'package:to_do_list/data/data_sources/remote/gemini/gemini_service.dart';
import 'package:to_do_list/data/models/chat_message_model.dart';
import 'package:to_do_list/data/models/suggested_task_model.dart';
import 'package:to_do_list/data/models/task_model.dart';
import 'package:to_do_list/data/models/task_priority.dart';
import 'package:to_do_list/data/models/task_status.dart';
import 'package:to_do_list/screens/chat/widgets/chat_bubble.dart';
import 'package:to_do_list/screens/chat/widgets/chat_input_field.dart';
import 'package:to_do_list/screens/chat/widgets/suggested_task_card.dart';
import 'package:to_do_list/screens/chat/widgets/typing_indicator.dart';
import 'package:to_do_list/screens/new_task/models/new_task_screen_arguments.dart';
import 'package:to_do_list/screens/new_task/new_task_screen.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _geminiService = GeminiService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessageModel> _messages = [];
  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    // Welcome message
    _messages.add(
      ChatMessageModel(
        message:
            'Xin chào ${_user?.displayName ?? _user?.email}!  Tôi là trợ lý AI giúp bạn lên kế hoạch công việc.\n\n'
            'Hãy cho tôi biết bạn muốn làm gì, ví dụ:\n'
            '• "Tôi cần lên kế hoạch học thi cuối kỳ"\n'
            '• "Giúp tôi sắp xếp công việc dọn nhà"\n'
            '• "Tôi muốn bắt đầu dự án app mới"\n\n'
            'Tôi sẽ đề xuất các task cụ thể để bạn thêm vào To-Do List!',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _textController.clear();

    // Add user message
    setState(() {
      _messages.add(ChatMessageModel(
        message: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    // Get AI response
    final response = await _geminiService.sendMessage(text);

    setState(() {
      _messages.add(response);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  TaskPriority _mapPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  Future<void> _addTaskToTodoList(SuggestedTask suggestedTask) async {
    final now = DateTime.now();
    final startTime = TimeOfDay.fromDateTime(now);
    final endMinutes = now.minute + suggestedTask.durationMinutes;
    final endTime = TimeOfDay(
      hour: startTime.hour + (endMinutes ~/ 60),
      minute: endMinutes % 60,
    );

    final taskModel = TaskModel(
      id: null,
      name: suggestedTask.name,
      description: suggestedTask.description,
      startTime: startTime,
      endTime: endTime,
      date: now,
      priority: _mapPriority(suggestedTask.priority),
      status: TaskStatus.incomplete,
      createdAt: now,
      updatedAt: null,
    );

    // Navigate to NewTaskScreen with pre-filled data
    final result = await Navigator.of(context).pushNamed(
      NewTaskScreen.routeName,
      arguments:
          NewTaskScreenArguments(taskModel: taskModel, isPreFilled: true),
    ) as bool?;

    if (result == true && mounted) {
      setState(() {
        _messages.add(ChatMessageModel(
          message: '✅ Đã thêm task "${suggestedTask.name}" vào To-Do List!',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.hex020206,
        appBar: PrimaryAppBar(
          title: 'AI Planner',
          onBack: () => Navigator.of(context).pop(),
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // Typing indicator
                  if (index == _messages.length && _isLoading) {
                    return const TypingIndicator();
                  }

                  final message = _messages[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chat bubble
                      ChatBubble(
                        message: message.message,
                        isUser: message.isUser,
                      ),

                      // Suggested task cards
                      if (message.suggestedTasks != null)
                        ...message.suggestedTasks!.map(
                          (task) => SuggestedTaskCard(
                            task: task,
                            onAddToTodoList: () => _addTaskToTodoList(task),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Input field
            ChatInputField(
              controller: _textController,
              onSend: _sendMessage,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
