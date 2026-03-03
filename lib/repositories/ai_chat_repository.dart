import '../models/spirit_type.dart';

/// AI 聊天数据源抽象接口
///
/// 用于抽象后端接口，避免前端直接调用 DeepSeek API（API Key 会暴露）。
/// 前端应该调用后端接口，后端再调用 DeepSeek API。
abstract class AIChatRepository {
  /// 发送消息到 AI
  ///
  /// [message] 用户消息内容
  /// [spiritType] 指定精灵（私聊模式），null 表示群聊模式
  /// [isGroupChat] 群聊/私聊模式（true=群聊，false=私聊）
  ///
  /// 返回 AI 的回复文本
  Future<String> sendMessage({
    required String message,
    SpiritType? spiritType,
    bool isGroupChat = false,
  });
}
