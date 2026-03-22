import 'package:flutter/material.dart';
import '../utils/resource_manager.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_image.dart';

/// 个人主页
/// 
/// 对应 iOS 的 ProfileViewController
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 这里不再使用内部 Scaffold / SafeArea / 背景图，
    // 统一复用外层 MainContainerView 提供的背景和顶部偏移。
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // 用户信息卡片
          _buildUserInfoCard(),
          const SizedBox(height: 20),
          // 操作按钮
          _buildActionButtons(),
          const SizedBox(height: 15),
          // 菜单列表
          _buildMenuList(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // 头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                ResourceManager.navigation.profile,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 用户名
                Text(
                  '狮子',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // 用户ID
                Text(
                  'ID: 680309',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // 统计信息
                Row(
                  children: [
                    _buildStatItem('5', '帖子'),
                    const SizedBox(width: 20),
                    _buildStatItem('8', '粉丝'),
                    const SizedBox(width: 20),
                    _buildStatItem('9', '关注'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String number, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Row(
      children: [
        // 编辑主页按钮
        Expanded(
          child: _buildActionButton(
            text: '编辑主页',
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 10),
        // 分享主页按钮
        Expanded(
          child: _buildActionButton(
            text: '分享主页',
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 10),
        // 添加朋友按钮
        AnimatedButton(
          onTap: () {},
          child: Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.person_add,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return AnimatedButton(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建菜单列表
  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        // 社群分享（单独一个卡片）
        _buildMenuItem(
          context: context,
          icon: ResourceManager.profile.share,
          title: '社群分享',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('社群分享功能待实现')),
            );
          },
        ),
        const SizedBox(height: 15),
        // 订阅项（特殊背景）
        _buildSubscriptionItem(context),
        const SizedBox(height: 15),
        // 其他菜单项（在一个卡片中）
        _buildOtherMenuItems(context),
      ],
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      color: Colors.white.withOpacity(0.3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // 图标（iOS: 24x24，使用 contain 确保完整显示）
                FadeInAssetImage(
                  assetPath: icon,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain, // 使用 contain 而不是 cover，确保图标不被裁剪
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.settings,
                      size: 24,
                      color: Colors.grey[700],
                    );
                  },
                ),
                const SizedBox(width: 12),
                // 标题
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // 箭头
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建订阅项（特殊背景）
  Widget _buildSubscriptionItem(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ResourceManager.profile.subscriptionItemBg),
            fit: BoxFit.cover,
          ),
          // 如果图片加载失败，使用备用颜色
          color: const Color(0xFF336652).withOpacity(0.9),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('订阅功能待实现')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // 图标（使用星标图标作为订阅图标）
                  Icon(
                    Icons.star,
                    size: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  // 标题和副标题
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'balance tree plus',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '已到期，续费立享所有内容',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 箭头
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建其他菜单项
  Widget _buildOtherMenuItems(BuildContext context) {
    final menuItems = [
      (
        icon: ResourceManager.profile.personality,
        title: '更多性格测试',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('性格测试功能待实现')),
          );
        },
      ),
      (
        icon: ResourceManager.profile.decoration,
        title: '装扮空间',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('装扮空间功能待实现')),
          );
        },
      ),
      (
        icon: ResourceManager.profile.widget,
        title: '桌面小组件',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('桌面小组件功能待实现')),
          );
        },
      ),
      (
        icon: ResourceManager.profile.contact,
        title: '联系我们',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('联系我们功能待实现')),
          );
        },
      ),
      (
        icon: ResourceManager.profile.settings,
        title: '设置',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('设置功能待实现')),
          );
        },
      ),
      (
        icon: ResourceManager.profile.logout,
        title: '退出',
        onTap: () => _showLogoutDialog(context),
      ),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white.withOpacity(0.3),
      child: Column(
        children: [
          for (int i = 0; i < menuItems.length; i++) ...[
            _buildMenuItemInList(
              context: context,
              icon: menuItems[i].icon,
              title: menuItems[i].title,
              onTap: menuItems[i].onTap,
              isLast: i == menuItems.length - 1,
            ),
            if (i < menuItems.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
          ],
        ],
      ),
    );
  }

  /// 构建列表中的菜单项
  Widget _buildMenuItemInList({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // 图标（iOS: 24x24，使用 contain 确保完整显示）
              FadeInAssetImage(
                assetPath: icon,
                width: 24,
                height: 24,
                fit: BoxFit.contain, // 使用 contain 而不是 cover，确保图标不被裁剪
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.settings,
                    size: 24,
                    color: Colors.grey[700],
                  );
                },
              ),
              const SizedBox(width: 12),
              // 标题
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
              // 箭头
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示退出登录确认对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('退出登录功能待实现')),
                );
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
