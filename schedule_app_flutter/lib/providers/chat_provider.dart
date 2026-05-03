import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ai_chat_result.dart';
import '../models/chat_message.dart';
import '../models/spirit_type.dart';
import '../repositories/ai_chat_repository.dart';
import '../repositories/local_ai_chat_repository.dart';
import '../repositories/remote_ai_chat_repository.dart';
import '../services/api_service.dart';
import 'task_provider.dart';

/// 聊天状态管理类
///
/// 对应 iOS 中 `EnhancedAIChatView` 的消息管理逻辑：
/// - `messages` 相当于 `chatBubbles`
/// - `isGroupChat` 对应 `isGroupChat`
/// - `selectedSpirit` 对应 `selectedSpirit`
class ChatProvider extends ChangeNotifier {
  /// AI 聊天数据源
  final AIChatRepository _repository;

  /// 非空时，AI 通过后端返回的 `createdTasks` 会写入本地安排（日历）
  final TaskProvider? taskProvider;

  /// 聊天消息列表
  final List<ChatMessage> messages = [];

  /// 是否群聊模式（true=群聊，false=私聊）
  bool isGroupChat = true;

  /// 当前私聊选中的精灵（群聊时为 null）
  SpiritType? selectedSpirit;

  /// 是否正在发送消息（用于防止重复发送）
  bool _isSending = false;

  /// 是否正在发送消息（供 UI 使用）
  bool get isSending => _isSending;

  /// 协商会话 ID（need_user_input 事件后设置）
  String? negotiationId;

  /// 协商决策选项
  List<Map<String, dynamic>> negotiationOptions = [];

  /// 是否需要用户决策
  bool get needsUserDecision => negotiationOptions.isNotEmpty && negotiationId != null;

  ChatProvider({
    AIChatRepository? repository,
    this.taskProvider,
  }) : _repository = repository ?? const LocalAIChatRepository() {
    // 初始化时可以添加一条欢迎消息（可选）
    // _addWelcomeMessage();
  }

  /// 添加消息到列表
  void addMessage(ChatMessage message) {
    messages.add(message);
    notifyListeners();
  }

  /// 发送用户消息
  ///
  /// 便捷方法，自动创建 role=user 的消息
  void sendUserMessage(String text) {
    final message = ChatMessage.user(text: text);
    addMessage(message);
  }

  /// 发送助手消息
  ///
  /// 便捷方法，自动创建 role=assistant 的消息
  /// [spiritType] 如果为 null，表示群聊回复；如果指定，表示特定精灵的回复
  void sendAssistantMessage(String text, SpiritType? spiritType) {
    final message = ChatMessage.assistant(
      text: text,
      spiritType: spiritType,
    );
    addMessage(message);
  }

  /// 发送消息并获取 AI 回复
  ///
  /// 这是主要的发送消息方法：
  /// - **私聊**：POST 单次请求，替换占位消息
  /// - **群聊**：SSE 流式协商，逐条添加精灵发言
  ///
  /// [text] 用户消息文本
  Future<void> sendMessage(String text) async {
    if (_isSending) return;
    if (text.trim().isEmpty) return;

    _isSending = true;
    sendUserMessage(text);

    if (isGroupChat) {
      await _sendNegotiation(text);
    } else {
      await _sendPrivateChat(text);
    }
  }

  /// 私聊：单次 POST 请求
  Future<void> _sendPrivateChat(String text) async {
    ChatMessage? loadingMessage;
    try {
      loadingMessage = ChatMessage.assistant(
        text: '正在思考...',
        spiritType: selectedSpirit,
      );
      addMessage(loadingMessage);

      final aiResult = await _repository.sendMessage(
        message: text,
        spiritType: selectedSpirit,
        isGroupChat: false,
      );

      messages.remove(loadingMessage);
      notifyListeners();

      // 先发 AI 回复
      sendAssistantMessage(aiResult.reply, selectedSpirit);

      // 如果 AI 自动创建了任务，追加一条确认消息
      if (aiResult.createdTasks.isNotEmpty) {
        for (final map in aiResult.createdTasks) {
          final title = map['title'] ?? '新任务';
          final scheduled = map['scheduled'] == true;
          final timeInfo = map['time_start'] != null
              ? ' (${map['date'] ?? ''} ${map['time_start']}-${map['time_end'] ?? ''})'
              : '';
          addMessage(ChatMessage.negotiation(
            text: '已创建任务「$title」$timeInfo${scheduled ? '，已排入日程' : ''}',
            speakerEmoji: '✅',
            speakerName: '任务助手',
          ));
        }
      }
    } catch (e) {
      if (loadingMessage != null) {
        messages.remove(loadingMessage);
        notifyListeners();
      }
      sendAssistantMessage('抱歉，我遇到了一些问题：$e', selectedSpirit);
    } finally {
      _isSending = false;
    }
  }

  /// 群聊：SSE 流式协商
  Future<void> _sendNegotiation(String text) async {
    // 清除上一轮协商状态
    negotiationId = null;
    negotiationOptions = [];
    notifyListeners();

    // 添加 loading 消息
    final loadingMessage = ChatMessage.negotiation(
      text: '正在发起精灵协商...',
      speakerName: '系统',
      isOrchestrator: true,
    );
    addMessage(loadingMessage);

    final repo = _repository;
    if (repo is! RemoteAIChatRepository) {
      // 本地模式降级
      messages.remove(loadingMessage);
      sendAssistantMessage('群聊模式需要连接后端服务', null);
      _isSending = false;
      return;
    }

    try {
      print('[Chat] Starting negotiation...');
      final stream = repo.negotiate(triggerReason: text);

      // 加 120 秒超时（多轮 LLM 协商耗时较长）
      final timedStream = stream.timeout(
        const Duration(seconds: 120),
        onTimeout: (sink) {
          sink.addError(TimeoutException('协商超时，请重试'));
          sink.close();
        },
      );

      await for (final event in timedStream) {
        print('[Chat] Got event: ${event.runtimeType}');
        // 移除 loading 消息（首次收到事件时）
        if (messages.contains(loadingMessage)) {
          messages.remove(loadingMessage);
        }

        switch (event) {
          case NegotiationSpiritMessage():
            addMessage(ChatMessage.negotiation(
              text: event.content,
              speakerEmoji: event.speakerEmoji,
              speakerName: '${event.speakerName} · 第${event.round}轮',
              spiritType: _spiritCodeToType(event.speaker),
            ));

          case NegotiationOrchestrator():
            addMessage(ChatMessage.negotiation(
              text: event.content,
              speakerEmoji: '🎯',
              speakerName: '主持人 · 第${event.round}轮',
              isOrchestrator: true,
            ));

          case NegotiationConsensus():
            addMessage(ChatMessage.negotiation(
              text: '✅ ${event.summary}',
              speakerEmoji: '🤝',
              speakerName: '协商共识',
              isOrchestrator: true,
            ));

          case NegotiationNeedUserInput():
            negotiationId = event.negotiationId;
            negotiationOptions = event.options;
            addMessage(ChatMessage.negotiation(
              text: event.message,
              speakerEmoji: '🤔',
              speakerName: '需要你来决定',
              isOrchestrator: true,
            ));
            notifyListeners();

          case NegotiationError():
            addMessage(ChatMessage.negotiation(
              text: '⚠ ${event.message}',
              speakerEmoji: '⚠',
              speakerName: '系统',
              isOrchestrator: true,
            ));

          case NegotiationDone():
            break;
        }
      }
    } on TimeoutException catch (_) {
      if (messages.contains(loadingMessage)) {
        messages.remove(loadingMessage);
      }
      addMessage(ChatMessage.negotiation(
        text: '协商超时，请检查网络后重试',
        speakerEmoji: '⚠',
        speakerName: '系统',
        isOrchestrator: true,
      ));
    } catch (e) {
      if (messages.contains(loadingMessage)) {
        messages.remove(loadingMessage);
      }
      addMessage(ChatMessage.negotiation(
        text: '协商出错：$e',
        speakerEmoji: '⚠',
        speakerName: '系统',
        isOrchestrator: true,
      ));
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// 用户选择协商方案
  Future<void> resolveNegotiation(int optionIndex) async {
    if (negotiationId == null || _isSending) return;

    _isSending = true;
    notifyListeners();

    try {
      final resp = await ApiService.instance.post(
        endpoint: '/ai/negotiate/resolve',
        body: {
          'negotiation_id': negotiationId,
          'decision': 'option_$optionIndex',
        },
      );

      final data = resp['data'] as Map<String, dynamic>?;
      final summary = data?['summary'] ?? '已选择方案';
      addMessage(ChatMessage.negotiation(
        text: '✅ $summary',
        speakerEmoji: '✅',
        speakerName: '协商结果',
        isOrchestrator: true,
      ));
    } catch (e) {
      addMessage(ChatMessage.negotiation(
        text: '提交决策失败：$e',
        speakerEmoji: '⚠',
        speakerName: '系统',
        isOrchestrator: true,
      ));
    } finally {
      // 清除协商状态
      negotiationId = null;
      negotiationOptions = [];
      _isSending = false;
      notifyListeners();
    }
  }

  /// 精灵代码 → SpiritType 枚举
  static SpiritType? _spiritCodeToType(String code) {
    for (final st in SpiritType.values) {
      if (st.name == code) return st;
    }
    return null;
  }

  /// 切换群聊/私聊模式
  ///
  /// 对应 iOS 中的 `toggleChatMode()` 方法
  void toggleChatMode() {
    isGroupChat = !isGroupChat;

    if (isGroupChat) {
      selectedSpirit = null;
    }

    // 切换模式时清除协商状态
    negotiationId = null;
    negotiationOptions = [];

    notifyListeners();
  }

  /// 在私聊模式下选择一个精灵
  ///
  /// 对应 iOS 中的 `selectSpiritForPrivateChat(_:)` 方法
  void selectSpiritForPrivateChat(SpiritType spirit) {
    // 如果当前是群聊模式，先切换到私聊模式
    if (isGroupChat) {
      isGroupChat = false;
    }

    selectedSpirit = spirit;

    // 可选：添加一条欢迎消息
    // sendAssistantMessage("你好！我是${spirit.displayName}", spirit);

    notifyListeners();
  }

  /// 清空所有消息
  void clearMessages() {
    messages.clear();
    notifyListeners();
  }

  /// 清空精灵选择（切回群聊模式）
  ///
  /// 将 isGroupChat 设为 true，selectedSpirit 设为 null
  void clearSelection() {
    isGroupChat = true;
    selectedSpirit = null;
    notifyListeners();
  }

}
