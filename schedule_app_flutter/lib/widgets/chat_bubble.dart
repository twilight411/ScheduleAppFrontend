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
      return Colors.grey[300]!.withOpacity(0.8);
    } else if (message.isOrchestrator) {
      // 主持人/系统消息：紫色调
      return Colors.deepPurple.withOpacity(0.15);
    } else if (message.spiritType != null) {
      return message.spiritType!.color.withOpacity(0.3);
    } else {
      return Colors.grey.withOpacity(0.2);
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
    final hasSpiritIcon = message.role == ChatRole.assistant &&
        message.spiritType != null &&
        !message.isOrchestrator;
    final hasSpeakerInfo =
        message.role == ChatRole.assistant && message.speakerName != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：精灵头像
          if (hasSpiritIcon)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: Image.asset(
                ResourceManager.getSpiritIcon(message.spiritType!),
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 精灵名称 / 主持人名称前缀
                  if (hasSpeakerInfo)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${message.speakerEmoji ?? ''} ${message.speakerName!}',
                        style: TextStyle(
                          color: message.isOrchestrator
                              ? Colors.deepPurple.shade700
                              : Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: isUser ? TextAlign.right : TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
