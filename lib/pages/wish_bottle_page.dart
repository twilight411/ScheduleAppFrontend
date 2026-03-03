import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/spirit_type.dart';
import '../models/wish.dart';
import '../pages/add_task_page.dart';
import '../pages/chat_page.dart';
import '../providers/wish_provider.dart';
import '../widgets/wish_item.dart';

/// 愿望瓶主界面
///
/// 参考 iOS 的 WishBottleViewController：
/// - 顶部为取消 / 标题 / 新增
/// - 中间为操作按钮（发送给 AI、手动转换为日程）
/// - 下方为愿望列表与空状态
/// - 底部为「+ 新增愿望」按钮
class WishBottlePage extends StatefulWidget {
  const WishBottlePage({super.key});

  @override
  State<WishBottlePage> createState() => _WishBottlePageState();
}

class _WishBottlePageState extends State<WishBottlePage> {
  @override
  Widget build(BuildContext context) {
    final wishProvider = context.watch<WishProvider>();
    final wishes = wishProvider.wishes;
    final selectedWish = wishProvider.getSelectedWish();
    final hasSelectedWish = selectedWish != null;

    final Color enabledColor =
        selectedWish?.spirit.color ?? Theme.of(context).colorScheme.primary;
    const Color disabledColor = Colors.grey;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '取消',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        centerTitle: true,
        title: const Text(
          '愿望瓶',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 跳转到 AddWishPage（创建后在这里补充）
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (_) => const AddWishPage()),
              // );
            },
            child: const Text(
              '新增',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部操作按钮区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // 发送给 AI
                  Expanded(
                    child: ElevatedButton(
                      onPressed: hasSelectedWish
                          ? () => _showChatModeDialog(context, selectedWish!)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            hasSelectedWish ? enabledColor : disabledColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('发送给 AI'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 手动转换为日程
                  Expanded(
                    child: OutlinedButton(
                      onPressed: hasSelectedWish
                          ? () async {
                              final wish = context
                                  .read<WishProvider>()
                                  .getSelectedWish();
                              final selectedIndex =
                                  context.read<WishProvider>().selectedWishIndex;
                              if (wish == null || selectedIndex == null) {
                                return;
                              }

                              final result = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => AddTaskPage(
                                    prefilledTitle: wish.title,
                                    prefilledDescription: wish.content,
                                    prefilledCategory: wish.spirit,
                                  ),
                                ),
                              );

                              if (result == true && mounted) {
                                final wishProvider =
                                    context.read<WishProvider>();
                                // 删除对应愿望并清空选中状态
                                wishProvider.removeWish(selectedIndex);
                                wishProvider.clearSelection();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '愿望「${wish.title}」已成功转换为日程',
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: hasSelectedWish ? enabledColor : disabledColor,
                        ),
                        foregroundColor:
                            hasSelectedWish ? enabledColor : disabledColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('手动转换为日程'),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // 中间愿望列表区域
            Expanded(
              child: wishes.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无愿望\n点击下方按钮添加你的第一个愿望',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Row(
                            children: [
                              const Text(
                                '暂存待办',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${wishes.length}条',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 0,
                              right: 0,
                              bottom: 80,
                            ),
                            itemCount: wishes.length,
                            itemBuilder: (context, index) {
                              final wish = wishes[index];
                              final isSelected =
                                  wishProvider.selectedWishIndex == index;
                              return _AnimatedListItem(
                                index: index,
                                child: WishItem(
                                  wish: wish,
                                  isSelected: isSelected,
                                  onCheckboxTapped: () {
                                    context
                                        .read<WishProvider>()
                                        .toggleWishSelection(index);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),

      // 底部 + 新增愿望 按钮
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: 跳转到 AddWishPage（创建后在这里补充）
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (_) => const AddWishPage()),
              // );
            },
            icon: const Icon(Icons.add),
            label: const Text('+ 新增愿望'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 显示聊天模式选择对话框
  ///
  /// 参考 iOS 代码中的 sendToAITapped 方法
  void _showChatModeDialog(BuildContext context, Wish wish) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择对话模式',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(height: 1),
            
            // 群聊模式选项
            ListTile(
              leading: const Icon(Icons.group, color: Colors.blue),
              title: const Text('群聊模式（所有精灵参与）'),
              subtitle: const Text('五个精灵一起为你出谋划策'),
              onTap: () {
                Navigator.pop(context);
                _sendWishToAI(context, wish, isGroupChat: true);
              },
            ),
            
            // 私聊模式选项
            ListTile(
              leading: Icon(
                wish.spirit.icon,
                color: wish.spirit.color,
              ),
              title: Text('私聊模式（${wish.spirit.displayName}）'),
              subtitle: Text('与 ${wish.spirit.displayName} 单独交流'),
              onTap: () {
                Navigator.pop(context);
                _sendWishToAI(context, wish, isGroupChat: false);
              },
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 发送愿望到 AI
  ///
  /// 参考 iOS 代码中的 sendWishToAI 方法
  void _sendWishToAI(BuildContext context, Wish wish, {required bool isGroupChat}) {
    // 构建消息
    final message = '我有一个愿望：${wish.title}\n\n详细说明：${wish.content}\n\n请帮我分析如何实现这个愿望。';

    // 跳转到 ChatPage，传入参数
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          initialMessage: message,
          initialSpiritType: isGroupChat ? null : wish.spirit,
          initialIsGroupChat: isGroupChat,
        ),
      ),
    );
  }
}

/// 带动画效果的列表项
class _AnimatedListItem extends StatelessWidget {
  const _AnimatedListItem({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

