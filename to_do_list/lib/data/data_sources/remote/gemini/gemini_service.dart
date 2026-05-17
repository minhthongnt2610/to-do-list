import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:to_do_list/data/models/suggested_task_model.dart';
import 'package:to_do_list/data/models/chat_message_model.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyCDSVArX-2mYFViUMBsBkMvmZJQFDCMhIA';

  static const String _systemPrompt = '''
Bạn là một trợ lý thông minh chuyên giúp người dùng lên kế hoạch công việc và quản lý thời gian hiệu quả.

Nhiệm vụ của bạn:
1. Lắng nghe yêu cầu của người dùng về công việc, dự án hoặc mục tiêu
2. Phân tích và đề xuất các task cụ thể, rõ ràng
3. Gợi ý mức độ ưu tiên (high, medium, low) và thời gian ước tính cho mỗi task
4. Đưa ra lời khuyên về cách sắp xếp công việc hiệu quả

Khi bạn đề xuất task, hãy sử dụng ĐÚNG format sau cho MỖI task:
[TASK]{"name":"Tên task", "description":"Mô tả chi tiết", "priority":"high/medium/low", "duration_minutes": 60}[/TASK]

Quy tắc:
- Luôn trả lời bằng tiếng Việt
- Mỗi task phải có name, description, priority và duration_minutes
- duration_minutes là số nguyên (phút)
- priority chỉ có 3 giá trị: "high", "medium", "low"
- Bạn có thể đề xuất nhiều task trong một tin nhắn
- Luôn giải thích lý do đề xuất trước khi liệt kê task
- Hãy thân thiện, nhiệt tình và chuyên nghiệp
''';

  late GenerativeModel _model;
  ChatSession? _chatSession;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );
  }

  /// Gửi tin nhắn và nhận phản hồi từ Gemini
  Future<ChatMessageModel> sendMessage(String message) async {
    _chatSession ??= _model.startChat();

    try {
      final response = await _chatSession!.sendMessage(
        Content.text(message),
      );

      final responseText =
          response.text ?? 'Xin lỗi, tôi không thể trả lời lúc này.';

      // Parse suggested tasks từ response
      final suggestedTasks = _parseSuggestedTasks(responseText);

      // Xóa tag [TASK]...[/TASK] khỏi message hiển thị
      final cleanMessage = _cleanMessage(responseText);

      return ChatMessageModel(
        message: cleanMessage,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedTasks: suggestedTasks.isNotEmpty ? suggestedTasks : null,
      );
    } catch (e) {
      String errorMessage;
      final errorStr = e.toString();

      if (errorStr.contains('quota') ||
          errorStr.contains('429') ||
          errorStr.contains('RESOURCE_EXHAUSTED')) {
        errorMessage =
            ' API đã hết lượt gọi miễn phí. Vui lòng thử lại sau vài phút hoặc kiểm tra quota tại: https://ai.google.dev/rate-limit';
        // Reset session để thử lại sau
        _chatSession = null;
      } else if (errorStr.contains('API_KEY') ||
          errorStr.contains('PERMISSION_DENIED')) {
        errorMessage = 'API key không hợp lệ. Vui lòng kiểm tra lại.';
      } else if (errorStr.contains('SocketException') ||
          errorStr.contains('network')) {
        errorMessage = 'Không có kết nối mạng. Vui lòng kiểm tra internet.';
      } else {
        errorMessage = 'Đã xảy ra lỗi: ${e.toString()}';
      }

      return ChatMessageModel(
        message: errorMessage,
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Parse các task đề xuất từ response của AI
  List<SuggestedTask> _parseSuggestedTasks(String response) {
    final List<SuggestedTask> tasks = [];
    final regex = RegExp(r'\[TASK\](.*?)\[/TASK\]', dotAll: true);
    final matches = regex.allMatches(response);

    for (final match in matches) {
      try {
        final jsonStr = match.group(1)!.trim();
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        tasks.add(SuggestedTask.fromJson(json));
      } catch (_) {
        // Bỏ qua task không parse được
      }
    }

    return tasks;
  }

  /// Xóa tag [TASK]...[/TASK] khỏi message để hiển thị
  String _cleanMessage(String message) {
    return message
        .replaceAll(RegExp(r'\[TASK\].*?\[/TASK\]', dotAll: true), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Reset chat session
  void resetChat() {
    _chatSession = null;
  }
}
