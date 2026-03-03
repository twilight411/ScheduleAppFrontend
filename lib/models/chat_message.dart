import 'package:equatable/equatable.dart';

import 'spirit_type.dart';

/// 聊天消息角色枚举
enum ChatRole {
  user, // 用户消息
  assistant, // 助手消息（精灵回复）
}

/// 聊天消息数据模型
/// 对应 iOS 中的 ChatBubbleView 逻辑
class ChatMessage extends Equatable {
  /// 消息角色（用户或助手）
  final ChatRole role;

  /// 消息文本内容
  final String text;

  /// 精灵类型（当 role 是 assistant 时，可以指定是哪个精灵回复的，null 表示群聊回复）
  final SpiritType? spiritType;

  /// 消息时间戳
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.text,
    this.spiritType,
    required this.timestamp,
  });

  /// 创建用户消息的便捷构造函数
  factory ChatMessage.user({
    required String text,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      role: ChatRole.user,
      text: text,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// 创建助手消息的便捷构造函数
  factory ChatMessage.assistant({
    required String text,
    SpiritType? spiritType,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      role: ChatRole.assistant,
      text: text,
      spiritType: spiritType,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// 复制并修改部分字段
  ChatMessage copyWith({
    ChatRole? role,
    String? text,
    SpiritType? spiritType,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      text: text ?? this.text,
      spiritType: spiritType ?? this.spiritType,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'text': text,
      'spiritType': spiritType?.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// 从 JSON 创建实例
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: ChatRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => ChatRole.user,
      ),
      text: json['text'] as String? ?? '',
      spiritType: json['spiritType'] != null
          ? SpiritType.values.firstWhere(
              (e) => e.name == json['spiritType'],
              orElse: () => SpiritType.light,
            )
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  List<Object?> get props => [
        role,
        text,
        spiritType,
        timestamp,
      ];
}
