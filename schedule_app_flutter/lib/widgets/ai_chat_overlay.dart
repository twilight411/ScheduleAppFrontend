import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/spirit_type.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../utils/resource_manager.dart';
import '../pages/wish_bottle_page.dart';
/// AI 对话浮层组件
///
/// 对应 iOS 的 EnhancedAIChatView：
/// - 容器从顶部40开始，到底部（containerView.topAnchor = topAnchor + 40）
/// - 小精灵容器中心Y对齐到容器顶部（spiritsContainerView.centerY = containerView.topAnchor）
/// - 展开按钮在容器顶部中央（expandButton.centerY = containerView.topAnchor + 40）
/// - 群聊/私聊按钮在容器顶部右侧（chatModeButton.centerY = containerView.topAnchor）
/// - 许愿瓶在容器底部左侧，只在展开时显示
/// - 输入框在许愿瓶右侧
class AIChatOverlay extends StatefulWidget {
  const AIChatOverlay({super.key, this.onExpandedChanged});

  /// 展开状态变化回调
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<AIChatOverlay> createState() => _AIChatOverlayState();
}

class _AIChatOverlayState extends State<AIChatOverlay> {
  late TextEditingController _textController;
  late ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();

    // 监听文本变化
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (_hasText != hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 切换展开/收起
  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    // 通知外部展开状态变化
    widget.onExpandedChanged?.call(_isExpanded);

    if (_isExpanded) {
      _scrollToBottom();
    }
  }

  /// 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// 发送消息
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.isSending) return;

    try {
      _textController.clear();
      setState(() {
        _hasText = false;
      });

      await chatProvider.sendMessage(text);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送消息失败：$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        // 监听消息变化，自动滚动到底部
        final messageCount = chatProvider.messages.length;
        if (messageCount > 0 && _isExpanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }

        // iOS: aiChatView从底部开始，高度120（收起）或400（展开）
        // iOS: containerView.topAnchor = topAnchor + 40（相对于aiChatView的顶部）
        // 所以containerView从aiChatView顶部+40开始，到aiChatView底部结束
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            height: _isExpanded ? 400 : 120, // iOS: aiChatHeightConstraint = 120/400
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 主容器（带背景图）
                // 参考 iOS：背景图本身已经扣好，有自然的不规则上边缘，直接显示即可
                // 使用 BoxFit.cover 并固定顶部对齐，确保高度变化时顶部边缘保持一致
                // 添加顶部圆角裁剪，匹配 iOS 版本的 cornerRadius = 30
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ResourceManager.backgrounds.aiChat),
                          fit: BoxFit.cover, // 使用 cover 保持宽高比，避免拉伸
                          alignment: Alignment.topCenter, // 固定顶部对齐，确保顶部边缘一致
                        ),
                      ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                          // 聊天消息列表（展开时显示）
                          if (_isExpanded)
                            Positioned(
                              top: 70,
                              left: 15,
                              right: 15,
                              bottom: 60,
                              child: chatProvider.messages.isEmpty
                                ? const Center(
                                    child: Text(
                                      '开始和 AI 精灵聊天吧～',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    itemCount: chatProvider.messages.length,
                                    itemBuilder: (context, index) {
                                      final message =
                                          chatProvider.messages[index];
                                      return ChatBubble(message: message);
                                    },
                                  ),
                            ),

                          // 许愿瓶按钮（只在展开时显示，输入框左侧）
                          if (_isExpanded)
                            Positioned(
                              left: 15,
                              bottom: 10,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const WishBottlePage(),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Image.asset(
                                    ResourceManager.calendar.wishBottle,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.auto_awesome,
                                        size: 32,
                                        color: Colors.purple,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          // 输入区域（收起和展开时都显示，但收起时位置不同）
                          Positioned(
                            // 收起时：输入框居中显示，没有许愿瓶
                            // 展开时：许愿瓶宽度44 + 左边距15 + 间距10 = 69
                            left: _isExpanded ? 69 : 15,
                            right: 15,
                            bottom: 10,
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                  child: TextField(
                                    controller: _textController,
                                    focusNode: _focusNode,
                                    enabled: !chatProvider.isSending,
                                    decoration: InputDecoration(
                                      hintText: _isExpanded
                                          ? '和小精灵们聊聊...'
                                          : '发消息,AI生成回答',
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 12,
                                      ),
                                    ),
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: chatProvider.isSending
                                        ? null
                                        : (_) => _sendMessage(),
                                  ),
                                  ),
                                  if (chatProvider.isSending)
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: _hasText
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                    ),
                                    onPressed:
                                        _hasText ? _sendMessage : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
                // 展开/收起按钮（中间的小箭头，控制聊天框高度）
                Positioned(
                  left: 0,
                  right: 0,
                  top: 50,
                  child: Center(
                    child: GestureDetector(
                      onTap: _toggleExpand,
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          _isExpanded
                              ? ResourceManager.aiChat.arrowDown
                              : ResourceManager.aiChat.arrowUp,
                          width: 30,
                          height: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              size: 24,
                              color: Colors.grey[700],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // 群聊/私聊切换按钮（夹子，在容器顶部右侧）
                // 参考 iOS：chatModeButton.centerYAnchor = containerView.topAnchor
                // 夹子本身就是一张贴图，不需要额外的圆形高亮底
                Positioned(
                  right: 12,
                  top: -32, // 夹子高度64的一半，让中心对齐到top: 0
                  child: GestureDetector(
                    onTap: () {
                      chatProvider.toggleChatMode();
                    },
                    child: SizedBox(
                      width: 80, // 比小精灵（72）略大一点
                      height: 80,
                      child: Center(
                        child: Image.asset(
                          chatProvider.isGroupChat
                              ? ResourceManager.aiChat.groupChat
                              : ResourceManager.aiChat.privateChat,
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              chatProvider.isGroupChat
                                  ? Icons.group
                                  : Icons.person,
                              size: 40,
                              color: Colors.grey[700],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // 小精灵容器（放在最上层，中心对齐到背景图顶部）
                // iOS: spiritsContainerView.centerYAnchor = containerView.topAnchor
                // iOS: spiritsContainerView 添加到 self，并通过 bringSubviewToFront 确保在最上层
                // 小精灵的上半身露在背景图弧线之上，下半身被背景图遮挡
                // 使用 IgnorePointer 让背景图区域可以接收点击事件，但精灵仍然显示在最上层
                Positioned(
                  left: 0,
                  right: 0,
                  // 精灵中心对齐到背景图顶部（上半身露在弧线之上，下半身被聊天背景盖住）
                  top: -36, // 精灵高度72的一半，让中心对齐到top: 0
                  height: 80,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ...SpiritType.values.asMap().entries.map((entry) {
                        final index = entry.key;
                        final spirit = entry.value;
                        final isSelected =
                            !chatProvider.isGroupChat &&
                            chatProvider.selectedSpirit == spirit;

                        final xPos = 15.0 + index * 55.0;

                        return Positioned(
                          left: xPos,
                          top: 36, // 从中心位置开始，36是精灵高度72的一半
                          child: GestureDetector(
                            onTap: () {
                              // 点击任意精灵：
                              // - 如果当前已经选中这个精灵：清空选择，恢复「不过滤任务」& 所有精灵高亮（群聊状态）
                              // - 如果当前未选中这个精灵：选中该精灵，其他精灵变暗，仅保留该精灵对应的任务
                              if (chatProvider.selectedSpirit == spirit) {
                                chatProvider.clearSelection();
                              } else {
                                chatProvider.selectSpiritForPrivateChat(spirit);
                              }
                            },
                            onLongPress: () {
                              // TODO: 显示精灵卡片
                            },
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: AnimatedScale(
                                scale: isSelected ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: AnimatedOpacity(
                                  opacity: isSelected || chatProvider.isGroupChat
                                      ? 1.0
                                      : 0.6,
                                  duration: const Duration(milliseconds: 300),
                                  child: Image.asset(
                                    ResourceManager.getSpiritIcon(spirit),
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Icon(
                                        spirit.icon,
                                        size: 48,
                                        color: spirit.color,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
