/// 远程 AI 聊天一次调用的结果（含可选的新建日程）
class AIChatResult {
  const AIChatResult({
    required this.reply,
    this.createdTasks = const [],
  });

  final String reply;
  /// 与后端 `Task.toJson` / `Task.fromJson` 字段一致
  final List<Map<String, dynamic>> createdTasks;
}

// ======================================================================
//  协商 SSE 事件模型 — 对应后端 NegotiationEngine 的 6 种 SSE event
// ======================================================================

sealed class NegotiationEvent {
  const NegotiationEvent();

  /// 从 SSE event name + data JSON 解析
  factory NegotiationEvent.fromSse(String event, Map<String, dynamic> data) {
    switch (event) {
      case 'spirit_message':
        return NegotiationSpiritMessage(
          speaker: data['speaker'] ?? '',
          speakerName: data['speaker_name'] ?? '',
          speakerEmoji: data['speaker_emoji'] ?? '',
          content: data['content'] ?? '',
          type: data['type'] ?? 'claim',
          round: data['round'] ?? 0,
          stance: data['stance'] ?? '',
        );
      case 'orchestrator':
        return NegotiationOrchestrator(
          content: data['content'] ?? '',
          round: data['round'] ?? 0,
          conflictsDetected: data['conflicts_detected'] ?? 0,
        );
      case 'consensus':
        return NegotiationConsensus(
          reached: data['reached'] ?? false,
          round: data['round'] ?? 0,
          summary: data['summary'] ?? '',
          schedule: data['schedule'],
        );
      case 'need_user_input':
        return NegotiationNeedUserInput(
          negotiationId: data['negotiation_id'] ?? '',
          message: data['message'] ?? '',
          options: (data['options'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ?? [],
          roundsCompleted: data['rounds_completed'] ?? 0,
        );
      case 'error':
        return NegotiationError(
          message: data['message'] ?? '协商异常',
          fallback: data['fallback'] ?? false,
        );
      case 'done':
        return NegotiationDone(
          negotiationId: data['negotiation_id'] ?? '',
        );
      default:
        return NegotiationError(message: '未知事件: $event');
    }
  }
}

/// 精灵发言（诉求 claim 或 回应 response）
class NegotiationSpiritMessage extends NegotiationEvent {
  const NegotiationSpiritMessage({
    required this.speaker,
    required this.speakerName,
    required this.speakerEmoji,
    required this.content,
    required this.type,
    required this.round,
    required this.stance,
  });
  final String speaker;
  final String speakerName;
  final String speakerEmoji;
  final String content;
  final String type; // claim / response
  final int round;
  final String stance;
}

/// 主持人调停
class NegotiationOrchestrator extends NegotiationEvent {
  const NegotiationOrchestrator({
    required this.content,
    required this.round,
    required this.conflictsDetected,
  });
  final String content;
  final int round;
  final int conflictsDetected;
}

/// 共识达成
class NegotiationConsensus extends NegotiationEvent {
  const NegotiationConsensus({
    required this.reached,
    required this.round,
    required this.summary,
    this.schedule,
  });
  final bool reached;
  final int round;
  final String summary;
  final dynamic schedule;
}

/// 需要用户决策
class NegotiationNeedUserInput extends NegotiationEvent {
  const NegotiationNeedUserInput({
    required this.negotiationId,
    required this.message,
    required this.options,
    required this.roundsCompleted,
  });
  final String negotiationId;
  final String message;
  final List<Map<String, dynamic>> options;
  final int roundsCompleted;
}

/// 错误
class NegotiationError extends NegotiationEvent {
  const NegotiationError({
    required this.message,
    this.fallback = false,
  });
  final String message;
  final bool fallback;
}

/// 协商结束
class NegotiationDone extends NegotiationEvent {
  const NegotiationDone({required this.negotiationId});
  final String negotiationId;
}
