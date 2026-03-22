import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/spirit_type.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../utils/resource_manager.dart';

/// AI 聊天页面
///
/// 对应 iOS 中的 `EnhancedAIChatView`：
/// - 支持群聊/私聊模式切换
/// - 支持精灵选择（私聊模式）
/// - 显示聊天消息列表
/// - 输入框和发送按钮
class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    this.initialMessage,
    this.initialSpiritType,
    this.initialIsGroupChat,
  });

  /// 初始消息（从愿望瓶等入口跳转时使用）
  final String? initialMessage;

  /// 初始精灵类型（私聊模式）
  final SpiritType? initialSpiritType;

  /// 初始是否为群聊模式
  final bool? initialIsGroupChat;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TextEditingController _textController;
  late ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    
    // 监听文本变化，更新按钮状态
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (_hasText != hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });

    // 初始化模式（如果有传入参数）
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = context.read<ChatProvider>();
      
      // 1. 先设置聊天模式
      if (widget.initialIsGroupChat != null) {
        if (chatProvider.isGroupChat != widget.initialIsGroupChat) {
          chatProvider.toggleChatMode();
        }
      }

      // 2. 如果是私聊模式，选择对应的精灵
      if (widget.initialSpiritType != null && !(widget.initialIsGroupChat ?? true)) {
        chatProvider.selectSpiritForPrivateChat(widget.initialSpiritType!);
      }

      // 3. 等待一小段时间，确保模式设置完成
      await Future.delayed(const Duration(milliseconds: 100));

      // 4. 如果有初始消息，自动发送
      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
        _textController.text = widget.initialMessage!;
        await _sendMessage();
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

  /// 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 发送消息
  ///
  /// 实现步骤：
  /// 1. 清空输入框
  /// 2. 添加用户消息（ChatProvider.sendUserMessage()）
  /// 3. 添加"正在思考..."占位消息（ChatProvider.sendAssistantMessage()）
  /// 4. 调用 ChatProvider.sendMessage()，它会：
  ///    - 调用 AIChatRepository.sendMessage()
  ///    - 传入 message, spiritType, isGroupChat
  /// 5. 等待响应
  /// 6. 移除占位消息，添加助手回复消息（ChatProvider 内部处理）
  /// 7. 滚动到底部
  /// 8. 错误处理：显示 SnackBar
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    
    // 如果输入为空，不发送
    if (text.isEmpty) {
      return;
    }

    final chatProvider = context.read<ChatProvider>();
    
    // 如果正在发送，防止重复发送
    if (chatProvider.isSending) {
      return;
    }

    try {
      // 1. 清空输入框
      _textController.clear();
      setState(() {
        _hasText = false;
      });
      
      // 2-7. 发送消息（ChatProvider 内部会处理：
      //      - 添加用户消息
      //      - 添加"正在思考..."占位消息
      //      - 调用 repository.sendMessage()
      //      - 移除占位消息
      //      - 添加助手回复消息）
      await chatProvider.sendMessage(text);
      
      // 8. 滚动到底部
      _scrollToBottom();
    } catch (e) {
      // 错误处理：显示 SnackBar
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

  /// 获取 AppBar 标题
  String _getAppBarTitle(ChatProvider chatProvider) {
    if (chatProvider.isGroupChat) {
      return 'AI 精灵群聊';
    } else if (chatProvider.selectedSpirit != null) {
      return '与 ${chatProvider.selectedSpirit!.displayName} 私聊';
    } else {
      return 'AI 私聊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            return IconButton(
              icon: Image.asset(
                chatProvider.isGroupChat 
                    ? ResourceManager.aiChat.groupChat 
                    : ResourceManager.aiChat.privateChat,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    chatProvider.isGroupChat ? Icons.group : Icons.person,
                  );
                },
              ),
              onPressed: () {
                chatProvider.toggleChatMode();
              },
              tooltip: chatProvider.isGroupChat ? '切换到私聊' : '切换到群聊',
            );
          },
        ),
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            return Text(_getAppBarTitle(chatProvider));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: '关闭',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ResourceManager.backgrounds.aiChat),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            // 监听消息变化，自动滚动到底部
            final messageCount = chatProvider.messages.length;
            if (messageCount > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }

            return Column(
              children: [
              // 精灵选择器（私聊模式）
              if (!chatProvider.isGroupChat)
                _buildSpiritSelector(chatProvider),
              
              // 聊天消息列表
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          return ChatBubble(message: message);
                        },
                      ),
              ),
              
              // 输入区域
              _buildInputArea(chatProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建精灵选择器（私聊模式）
  Widget _buildSpiritSelector(ChatProvider chatProvider) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: SpiritType.values.length,
        itemBuilder: (context, index) {
          final spirit = SpiritType.values[index];
          final isSelected = chatProvider.selectedSpirit == spirit;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                chatProvider.selectSpiritForPrivateChat(spirit);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? spirit.color.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? spirit.color : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Image.asset(
                  ResourceManager.getSpiritIcon(spirit),
                  width: 30,
                  height: 30,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      spirit.icon,
                      color: isSelected ? spirit.color : Colors.grey,
                      size: 30,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '开始和 AI 精灵聊天吧～',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建输入区域
  Widget _buildInputArea(ChatProvider chatProvider) {
    final isSending = chatProvider.isSending;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 愿望瓶按钮（可选）
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: () {
                // TODO: 跳转到愿望瓶页面
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('愿望瓶功能待实现')),
                );
              },
              tooltip: '愿望瓶',
            ),
            
            // 输入框
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(ResourceManager.aiChat.inputBoxBg),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: !isSending, // 发送时禁用输入框
                  decoration: InputDecoration(
                    hintText: '和小精灵们聊聊...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: isSending ? null : (_) => _sendMessage(),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 发送按钮（显示加载状态或发送图标）
            if (isSending)
              // 加载状态：显示加载图标
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              )
            else
              // 正常状态：显示发送按钮
              IconButton(
                icon: const Icon(Icons.send),
                color: _hasText 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey,
                onPressed: _hasText ? _sendMessage : null,
                tooltip: '发送',
              ),
          ],
        ),
      ),
    );
  }
}
