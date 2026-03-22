import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/spirit_type.dart';
import '../models/task.dart';
import '../repositories/ai_chat_repository.dart';
import '../repositories/local_ai_chat_repository.dart';
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
  /// 这是主要的发送消息方法，会：
  /// 1. 先添加用户消息到列表
  /// 2. 添加一条"正在思考..."的占位助手消息
  /// 3. 调用 repository 获取 AI 回复
  /// 4. 移除占位消息，添加真正的助手消息
  /// 5. 处理错误情况
  ///
  /// [text] 用户消息文本
  Future<void> sendMessage(String text) async {
    // 防止重复发送
    if (_isSending) {
      return;
    }

    // 如果消息为空，直接返回
    if (text.trim().isEmpty) {
      return;
    }

    ChatMessage? loadingMessage;

    try {
      _isSending = true;

      // 1. 先添加用户消息到列表
      sendUserMessage(text);

      // 2. 添加一条"正在思考..."的占位助手消息
      loadingMessage = ChatMessage.assistant(
        text: '正在思考...',
        spiritType: isGroupChat ? null : selectedSpirit,
      );
      addMessage(loadingMessage);

      // 3. 调用 repository 获取 AI 回复
      // 根据当前模式决定参数：
      // - 群聊模式：isGroupChat=true, spiritType=null
      // - 私聊模式：isGroupChat=false, spiritType=selectedSpirit
      final aiResult = await _repository.sendMessage(
        message: text,
        spiritType: isGroupChat ? null : selectedSpirit,
        isGroupChat: isGroupChat,
      );

      // 4. 移除占位消息
      messages.remove(loadingMessage);
      notifyListeners();

      // 5. 将 AI 创建的日程写入本地安排界面
      final tp = taskProvider;
      if (tp != null && aiResult.createdTasks.isNotEmpty) {
        for (final map in aiResult.createdTasks) {
          try {
            tp.addTask(Task.fromJson(map));
          } catch (_) {
            // 单条解析失败不影响聊天展示
          }
        }
      }

      // 6. 添加真正的助手消息到列表
      sendAssistantMessage(
        aiResult.reply,
        isGroupChat ? null : selectedSpirit,
      );
    } catch (e) {
      // 6. 处理错误情况：移除占位消息，添加错误提示消息
      final lm = loadingMessage;
      if (lm != null) {
        messages.remove(lm);
        notifyListeners();
      }
      sendAssistantMessage(
        '抱歉，我遇到了一些问题：$e',
        isGroupChat ? null : selectedSpirit,
      );
    } finally {
      _isSending = false;
    }
  }

  /// 切换群聊/私聊模式
  ///
  /// 对应 iOS 中的 `toggleChatMode()` 方法
  void toggleChatMode() {
    isGroupChat = !isGroupChat;

    if (isGroupChat) {
      // 切换到群聊模式：清空选中的精灵
      selectedSpirit = null;
      // 可选：添加一条系统提示消息
      // sendAssistantMessage("已切换到群聊模式", null);
    } else {
      // 切换到私聊模式
      // 可选：添加一条系统提示消息
      // sendAssistantMessage("已切换到私聊模式，请选择一个精灵", null);
    }

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
