import '../models/ai_chat_result.dart';
import '../models/spirit_type.dart';
import '../services/api_service.dart';
import 'ai_chat_repository.dart';

export '../models/ai_chat_result.dart' show NegotiationEvent;

/// 远程 AI 聊天数据源实现
///
/// 私聊：POST /api/v1/ai/spirits/{spirit_code}/chat
/// 群聊：POST /api/v1/ai/negotiate
class RemoteAIChatRepository implements AIChatRepository {
  final ApiService _apiService;

  /// 按精灵缓存 session_id，保持上下文连续
  final Map<String, String> _sessionIds = {};

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
      final Map<String, dynamic> response;

      if (!isGroupChat && spiritType != null) {
        response = await _sendPrivateChat(message, spiritType);
      } else {
        response = await _sendNegotiate(message);
      }

      // 后端响应: {"success":true, "data": {"message":"...", "session_id":"...", ...}, "message":null}
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final reply = data['message'] as String? ?? '（无回复）';

      // 解析任务建议 — 如果检测到，自动调用 /tasks/from-chat 创建任务
      final List<Map<String, dynamic>> created = [];
      final suggestion = data['task_suggestion'];
      if (suggestion is Map<String, dynamic> && suggestion['detected'] == true) {
        final taskFromChat = await _createTaskFromSuggestion(suggestion);
        if (taskFromChat != null) {
          created.add(taskFromChat);
        }
      }

      return AIChatResult(reply: reply, createdTasks: created);
    } on ApiException catch (e) {
      throw Exception('发送消息失败：${e.message}');
    } catch (e) {
      throw Exception('发送消息失败：$e');
    }
  }

  /// 私聊：POST /api/v1/ai/spirits/{spirit_code}/chat
  Future<Map<String, dynamic>> _sendPrivateChat(
    String message,
    SpiritType spiritType,
  ) async {
    final code = spiritType.name;
    final body = <String, dynamic>{
      'message': message,
      'session_id': _sessionIds[code],
    };

    final response = await _apiService.post(
      endpoint: '/ai/spirits/$code/chat',
      body: body,
    );

    // 从 data 层提取 session_id 缓存
    final data = response['data'] as Map<String, dynamic>?;
    final sid = data?['session_id'] as String?;
    if (sid != null) {
      _sessionIds[code] = sid;
    }

    return response;
  }

  /// 群聊/协商：POST /api/v1/ai/negotiate
  Future<Map<String, dynamic>> _sendNegotiate(String message) async {
    final body = <String, dynamic>{
      'message': message,
    };

    return _apiService.post(
      endpoint: '/ai/negotiate',
      body: body,
    );
  }

  /// 从聊天建议创建任务 — POST /api/v1/tasks/from-chat
  Future<Map<String, dynamic>?> _createTaskFromSuggestion(
    Map<String, dynamic> suggestion,
  ) async {
    try {
      final body = <String, dynamic>{
        'suggestion_id': suggestion['suggestion_id'] ?? '',
        'title': suggestion['title'] ?? '',
        'spirit': suggestion['spirit'] ?? 'light',
      };

      // 可选字段
      if (suggestion['date'] != null) body['date'] = suggestion['date'];
      if (suggestion['time_start'] != null) {
        body['time_start'] = suggestion['time_start'];
      }
      if (suggestion['time_end'] != null) {
        body['time_end'] = suggestion['time_end'];
      }
      if (suggestion['duration_minutes'] != null) {
        body['duration_minutes'] = suggestion['duration_minutes'];
      }

      final resp = await _apiService.post(
        endpoint: '/tasks/from-chat',
        body: body,
      );

      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        // 合并 suggestion 的展示字段到响应中
        return {
          ...Map<String, dynamic>.from(data),
          'title': suggestion['title'],
          'date': suggestion['date'],
          'time_start': suggestion['time_start'],
          'time_end': suggestion['time_end'],
        };
      }
    } catch (_) {
      // 创建失败不阻塞聊天，静默忽略
    }
    return null;
  }

  /// 解析自然语言输入 — POST /ai/parse
  Future<Map<String, dynamic>> parseInput({
    required String userInput,
  }) async {
    return _apiService.post(
      endpoint: '/ai/parse',
      body: {'user_input': userInput},
    );
  }

  /// 精灵拆解任务 — POST /ai/spirits/decompose
  Future<Map<String, dynamic>> decomposeTask({
    required String taskId,
  }) async {
    return _apiService.post(
      endpoint: '/ai/spirits/decompose',
      body: {'task_id': taskId},
    );
  }

  /// 查询协商状态 — GET /ai/negotiate/status/{negotiationId}
  Future<Map<String, dynamic>> getNegotiationStatus(
      String negotiationId) async {
    return _apiService.get(
      endpoint: '/ai/negotiate/status/$negotiationId',
    );
  }

  /// 发起精灵协商 — SSE 流式返回事件
  ///
  /// 后端自动选取 pending/in_progress 的任务参与协商。
  /// [triggerReason] 可选的触发原因描述。
  Stream<NegotiationEvent> negotiate({
    String? triggerReason,
  }) {
    final body = <String, dynamic>{
      'task_ids': <String>[],
      if (triggerReason != null) 'trigger_reason': triggerReason,
    };

    return _apiService.postStream(
      endpoint: '/ai/negotiate',
      body: body,
    );
  }
}
