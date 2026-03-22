import 'package:flutter/material.dart';

import 'calendar_page.dart';
import 'plant_page.dart';
import 'profile_page.dart';
import '../utils/resource_manager.dart';
import '../utils/font_manager.dart';
import '../widgets/ai_chat_overlay.dart';
import '../widgets/leaf_button_group.dart';

/// 视图模式枚举
/// 匹配iOS项目的MainContainerViewController.ViewMode
enum ViewMode {
  calendar,
  plant,
  profile,
}

/// 主容器视图，使用顶部导航栏按钮切换视图
/// 匹配iOS项目的MainContainerViewController
class MainContainerView extends StatefulWidget {
  const MainContainerView({super.key});

  @override
  State<MainContainerView> createState() => _MainContainerViewState();
}

class _MainContainerViewState extends State<MainContainerView> {
  ViewMode _currentMode = ViewMode.calendar;
  
  // AI聊天框展开状态（用于通知CalendarPage调整布局）
  final ValueNotifier<bool> _aiChatExpandedNotifier = ValueNotifier<bool>(false);
  
  // 日历模式状态（用于叶子按钮）
  CalendarMode _calendarMode = CalendarMode.month;

  final _plantPage = const PlantPage();
  final _profilePage = const ProfilePage();

  Widget get _currentPage {
    switch (_currentMode) {
      case ViewMode.calendar:
        // CalendarPage需要接收aiChatExpandedNotifier，所以单独创建
        return CalendarPage(
          aiChatExpandedNotifier: _aiChatExpandedNotifier,
          initialMode: _calendarMode,
          onModeChanged: (mode) {
            // 当日历内部（例如点击周 / 月日期）切换模式时，同步到三叶草按钮
            setState(() {
              _calendarMode = mode;
            });
          },
        );
      case ViewMode.plant:
        return _plantPage;
      case ViewMode.profile:
        return _profilePage;
    }
  }
  
  @override
  void dispose() {
    _aiChatExpandedNotifier.dispose();
    super.dispose();
  }

  String get _appBarTitle {
    switch (_currentMode) {
      case ViewMode.calendar:
        return '我的安排';
      case ViewMode.plant:
        return '植物状态';
      case ViewMode.profile:
        return '我的';
    }
  }

  // 左侧按钮图标路径
  String get _leftButtonIconPath {
    switch (_currentMode) {
      case ViewMode.calendar:
        return ResourceManager.navigation.plant; // 显示植物图标，点击切换到植物
      case ViewMode.plant:
        return ResourceManager.navigation.calendar; // 显示日历图标，点击切换到日历
      case ViewMode.profile:
        return ResourceManager.navigation.calendar; // 显示日历图标，点击切换到日历
    }
  }

  // 右侧按钮图标路径
  String get _rightButtonIconPath {
    switch (_currentMode) {
      case ViewMode.calendar:
      case ViewMode.plant:
        return ResourceManager.navigation.profile; // 显示个人图标，点击切换到"我的"
      case ViewMode.profile:
        return ResourceManager.navigation.plant; // 显示植物图标，点击切换到植物
    }
  }

  void _onLeftButtonTap() {
    setState(() {
      switch (_currentMode) {
        case ViewMode.calendar:
          _currentMode = ViewMode.plant;
          break;
        case ViewMode.plant:
          _currentMode = ViewMode.calendar;
          break;
        case ViewMode.profile:
          _currentMode = ViewMode.calendar;
          break;
      }
    });
  }

  void _onRightButtonTap() {
    setState(() {
      switch (_currentMode) {
        case ViewMode.calendar:
        case ViewMode.plant:
          _currentMode = ViewMode.profile;
          break;
        case ViewMode.profile:
          _currentMode = ViewMode.plant;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用透明背景，让背景图覆盖整个屏幕
      backgroundColor: Colors.transparent,
      // 让body延伸到AppBar后面，使背景图覆盖整个屏幕
      extendBodyBehindAppBar: true,
      // 自定义AppBar，背景透明，文字白色
      // iOS: navigationBarView从safeAreaLayoutGuide.topAnchor开始，高度60
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), // 使用默认高度，但会在SafeArea内
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 60, // iOS: navigationBarView.height = 60
            color: Colors.transparent, // iOS: navigationBarView.backgroundColor = .clear
            child: AppBar(
              title: Text(
                _appBarTitle,
                // 标题字体放大一些，让「我的 / 我的安排 / 植物状态」在60高的导航栏里更有“撑满”的感觉
                style: FontManager.customFontWithColor(
                  size: 22,
                  color: Colors.white,
                  weight: FontWeight.w600,
                ).copyWith(
                  height: 1.1, // 略微压紧行高，让文字在垂直方向更贴近导航栏上下边
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              centerTitle: true, // iOS: titleLabel.centerXAnchor = navigationBarView.centerXAnchor
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 60, // 设置工具栏高度为60
              // 左侧切换按钮：贴图高度撑满导航栏（60）
              leading: _AnimatedButton(
                onTap: _onLeftButtonTap,
                child: Image.asset(
                  _leftButtonIconPath,
                  width: 60,
                  height: 60,
                  // 不再强制加白色 tint，让贴图保持原始颜色
                  errorBuilder: (context, error, stackTrace) {
                    IconData fallbackIcon;
                    switch (_currentMode) {
                      case ViewMode.calendar:
                        fallbackIcon = Icons.local_florist;
                        break;
                      case ViewMode.plant:
                      case ViewMode.profile:
                        fallbackIcon = Icons.calendar_today;
                        break;
                    }
                    return Icon(
                      fallbackIcon,
                      size: 32,
                      color: Colors.white,
                    );
                  },
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                    child: _AnimatedButton(
                      onTap: _onRightButtonTap,
                      child: Image.asset(
                        _rightButtonIconPath,
                        width: 60,
                        height: 60,
                        // 不再强制加白色 tint，让贴图保持原始颜色
                        errorBuilder: (context, error, stackTrace) {
                          IconData fallbackIcon;
                          switch (_currentMode) {
                            case ViewMode.calendar:
                            case ViewMode.plant:
                              fallbackIcon = Icons.person;
                              break;
                            case ViewMode.profile:
                              fallbackIcon = Icons.local_florist;
                              break;
                          }
                          return Icon(
                            fallbackIcon,
                            size: 32,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
      // 背景图覆盖整个屏幕（包括状态栏和AppBar区域）
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ResourceManager.backgrounds.main),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // 内容区域（从导航栏下方开始）
            SafeArea(
              top: false, // 不使用顶部SafeArea，因为AppBar已经在SafeArea内
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 60, // 状态栏高度 + 导航栏高度60
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Container(
                    key: ValueKey<ViewMode>(_currentMode),
                    child: _currentPage,
                  ),
                ),
              ),
            ),
            // 叶子按钮组（只在日历页面显示，贴着整个屏幕的左边）
            // iOS: 叶子按钮直接添加到view上，不是添加到calendarContainerView上
            // iOS: calendarContainerView.topAnchor = view.safeAreaLayoutGuide.topAnchor + 10
            // iOS: monthLeafButton.topAnchor = calendarContainerView.topAnchor + 30
            // iOS: calendarContainerView.leadingAnchor = view.leadingAnchor + 20
            // iOS: leafButton.leadingAnchor = calendarContainerView.leadingAnchor - 25 = view.leadingAnchor - 5
            if (_currentMode == ViewMode.calendar)
              Positioned(
                left: -5, // 贴着整个屏幕的左边（20 - 25 = -5，让叶子稍微露出来一点）
                // iOS 对齐关系：
                // - navigationBarView.height = 60
                // - calendarContainerView.top = safeArea.top + 10
                // - monthLeafButton.top = calendarContainerView.top + 30
                // Flutter 里 CalendarPage 的内容区域是从「状态栏 + 60」开始，
                // 再向下 10 是日历容器顶部，再向下 30 是第一个叶子按钮顶部。
                top: MediaQuery.of(context).padding.top + 60 + 10 + 30,
                child: LeafButtonGroup(
                  initialMode: _calendarMode,
                  onModeChanged: (mode) {
                    setState(() {
                      _calendarMode = mode;
                    });
                  },
                ),
              ),
            // AI对话浮层（只在日历页面显示）
            if (_currentMode == ViewMode.calendar)
              AIChatOverlay(
                onExpandedChanged: (expanded) {
                  _aiChatExpandedNotifier.value = expanded;
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// 带动画效果的按钮组件
class _AnimatedButton extends StatefulWidget {
  const _AnimatedButton({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.scale(
        scale: _isPressed ? 0.9 : 1.0,
        child: Material(
          // 顶部导航按钮：完全透明背景，只保留贴图本身 + 点击缩放
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60, // 与导航栏高度一致
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
