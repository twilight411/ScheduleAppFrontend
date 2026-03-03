import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/spirit_type.dart';
import '../utils/resource_manager.dart';

/// 聊天气泡组件
///
/// 对应 iOS 中的 `ChatBubbleView`：
/// - user: 右对齐，蓝色背景，白色文字
/// - assistant: 左对齐，根据 spiritType 显示不同颜色背景（无 spiritType 用灰色）
/// - 圆角矩形，自适应文本内容
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  /// 获取气泡背景颜色
  Color _getBackgroundColor() {
    if (message.role == ChatRole.user) {
      // 用户消息：浅灰色背景
      // iOS: 使用浅灰色，而不是蓝色
      return Colors.grey[300]!.withOpacity(0.8);
    } else {
      // 助手消息
      if (message.spiritType != null) {
        // 有精灵类型：使用精灵颜色，透明度 0.3
        return message.spiritType!.color.withOpacity(0.3);
      } else {
        // 无精灵类型（群聊）：灰色背景，透明度 0.2
        return Colors.grey.withOpacity(0.2);
      }
    }
  }

  /// 获取文字颜色
  Color _getTextColor() {
    if (message.role == ChatRole.user) {
      // 用户消息：深色文字（浅灰色背景上需要深色文字才能看清）
      return Colors.black87;
    } else {
      // 助手消息：深色文字
      return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final isUser = message.role == ChatRole.user;
    final hasSpiritIcon = message.role == ChatRole.assistant && message.spiritType != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：精灵头像（仅 assistant 且有 spiritType 时显示）
          // iOS中使用精灵贴图作为头像，而不是系统图标
          // 尺寸应该和许愿瓶一样大（44x44）
          if (hasSpiritIcon)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: Image.asset(
                ResourceManager.getSpiritIcon(message.spiritType!),
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // 如果图片加载失败，使用备用图标
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: message.spiritType!.color.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      message.spiritType!.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          // 气泡内容
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: isUser ? TextAlign.right : TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
