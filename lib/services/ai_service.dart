import '../models/spirit_type.dart';
import 'spirit_prompts.dart';

/// AI 服务类
///
/// 统一管理 AI 相关的逻辑，包括获取 system prompt。
/// 这个服务主要用于：
/// 1. 提供统一的接口获取 system prompt
/// 2. 保持 Flutter 版本和 iOS 版本的 AI 回复风格一致
/// 3. 供后端开发参考（后端需要根据这些 prompt 构造 system prompt）
///
/// 注意：前端不会直接调用 DeepSeek API，而是通过后端接口。
/// 后端需要根据 spiritType 和 isGroupChat 参数，使用对应的 system prompt。
class AIService {
  AIService._internal();

  static final AIService _instance = AIService._internal();

  /// 单例实例
  static AIService get instance => _instance;

  /// 获取系统提示词
  ///
  /// [spiritType] 精灵类型，null 表示群聊模式
  /// [isGroupChat] 是否为群聊模式
  ///
  /// 返回对应的 system prompt 文本
  ///
  /// 这个方法会调用 SpiritPrompts.getSystemPrompt() 来获取提示词。
  /// 后端应该使用相同的逻辑来构造 system prompt，以保持回复风格一致。
  String getSystemPrompt(SpiritType? spiritType, bool isGroupChat) {
    return SpiritPrompts.getSystemPrompt(spiritType, isGroupChat);
  }
}
