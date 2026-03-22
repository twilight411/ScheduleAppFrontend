import '../models/ai_chat_result.dart';
import '../models/spirit_type.dart';
import '../services/api_service.dart';
import '../services/user_identity_service.dart';
import 'ai_chat_repository.dart';

/// 远程 AI 聊天数据源实现
///
/// 调用后端接口，后端再调用 DeepSeek API。
/// 注意：API Key 存储在后端，前端永远不暴露。
/// 后端负责调用 DeepSeek API 并返回结果。
class RemoteAIChatRepository implements AIChatRepository {
  final ApiService _apiService;

  RemoteAIChatRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService.instance;

  @override
  Future<AIChatResult> sendMessage({
    required String message,
    SpiritType? spiritType,
    bool isGroupChat = false,
  }) async {
    try {
      final userId = await UserIdentityService.instance.getCurrentUserId();
      final requestBody = {
        'message': message,
        'spiritType': spiritType?.name,
        'isGroupChat': isGroupChat,
        'userId': userId,
        'clientNowIso': DateTime.now().toIso8601String(),
      };

      // POST /api/ai/chat，携带 userId 供后端写入用量统计
      final response = await _apiService.post(
        endpoint: '/ai/chat',
        body: requestBody,
        headers: {'X-User-Id': userId},
      );

      String reply;
      if (response.containsKey('response')) {
        reply = response['response'] as String;
      } else if (response.containsKey('message')) {
        reply = response['message'] as String;
      } else if (response.containsKey('data')) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data?.containsKey('text') == true) {
          reply = data!['text'] as String;
        } else if (data?.containsKey('response') == true) {
          reply = data!['response'] as String;
        } else {
          throw Exception('响应格式异常：未找到 AI 回复文本字段');
        }
      } else {
        throw Exception('响应格式异常：未找到 AI 回复文本字段');
      }

      final rawCreated = response['createdTasks'];
      final List<Map<String, dynamic>> created = [];
      if (rawCreated is List) {
        for (final item in rawCreated) {
          if (item is Map<String, dynamic>) {
            created.add(item);
          } else if (item is Map) {
            created.add(Map<String, dynamic>.from(item));
          }
        }
      }

      return AIChatResult(reply: reply, createdTasks: created);
    } on ApiException catch (e) {
      // 重新抛出 ApiException，让调用者处理
      throw Exception('发送消息失败：${e.message}');
    } catch (e) {
      // 处理其他异常
      throw Exception('发送消息失败：$e');
    }
  }
}
