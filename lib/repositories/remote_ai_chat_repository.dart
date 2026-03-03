import '../models/spirit_type.dart';
import '../services/api_service.dart';
import 'ai_chat_repository.dart';

/// 远程 AI 聊天数据源实现
///
/// 调用后端接口，后端再调用 DeepSeek API。
/// 注意：API Key 存储在后端，前端永远不暴露。
/// 后端负责调用 DeepSeek API 并返回结果。
class RemoteAIChatRepository implements AIChatRepository {
  final ApiService _apiService;

  const RemoteAIChatRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService.instance;

  @override
  Future<String> sendMessage({
    required String message,
    SpiritType? spiritType,
    bool isGroupChat = false,
  }) async {
    try {
      // 构建请求体
      final requestBody = {
        'message': message,
        'spiritType': spiritType?.name,
        'isGroupChat': isGroupChat,
      };

      // 发送 POST 请求到后端接口
      // POST /api/ai/chat
      final response = await _apiService.post(
        endpoint: '/ai/chat',
        body: requestBody,
        // TODO: 如果需要认证，在这里添加 Authorization header
        // headers: {
        //   'Authorization': 'Bearer $token',
        // },
      );

      // 解析响应，返回 AI 回复文本
      // 根据后端返回的格式解析响应
      // 常见的响应格式：
      // { "response": "AI回复文本" } 或 { "message": "AI回复文本" } 或 { "data": { "text": "AI回复文本" } }
      if (response.containsKey('response')) {
        return response['response'] as String;
      } else if (response.containsKey('message')) {
        return response['message'] as String;
      } else if (response.containsKey('data')) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data?.containsKey('text') == true) {
          return data!['text'] as String;
        } else if (data?.containsKey('response') == true) {
          return data!['response'] as String;
        }
      }

      // 如果响应格式不符合预期，抛出异常
      throw Exception('响应格式异常：未找到 AI 回复文本字段');
    } on ApiException catch (e) {
      // 重新抛出 ApiException，让调用者处理
      throw Exception('发送消息失败：${e.message}');
    } catch (e) {
      // 处理其他异常
      throw Exception('发送消息失败：$e');
    }
  }
}
