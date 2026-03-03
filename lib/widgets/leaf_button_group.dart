import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/resource_manager.dart';
import '../utils/font_manager.dart';

/// 叶子按钮组（日/周/月切换）
///
/// 参考 iOS 实现：
/// - 三个独立的按钮，垂直排列
/// - 每个按钮 50x50 像素
/// - 按钮间距 5px
/// - 按钮相对于容器 left = -25（容器 left padding = 20，所以按钮相对于屏幕 left = -5）
/// - 第一个按钮（月）top = 容器 top + 30
/// - 后续按钮 top = 前一个按钮 bottom + 5
enum CalendarMode { day, week, month }

class LeafButtonGroup extends StatefulWidget {
  const LeafButtonGroup({
    super.key,
    required this.onModeChanged,
    this.initialMode = CalendarMode.month,
  });

  final Function(CalendarMode) onModeChanged;
  final CalendarMode initialMode;

  @override
  State<LeafButtonGroup> createState() => _LeafButtonGroupState();
}

class _LeafButtonGroupState extends State<LeafButtonGroup> {
  late CalendarMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

  @override
  void didUpdateWidget(covariant LeafButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部传入的 initialMode 变化时（例如从月/周跳转到日视图），
    // 同步更新当前选中态，让叶子按钮的高亮状态跟随实际日历模式。
    if (oldWidget.initialMode != widget.initialMode) {
      setState(() {
        _selectedMode = widget.initialMode;
      });
    }
  }

  void _selectMode(CalendarMode mode) {
    if (_selectedMode != mode) {
      setState(() {
        _selectedMode = mode;
      });
      widget.onModeChanged(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    // iOS: 三个按钮垂直排列，每个按钮独立
    // 月（第一个，top = 容器 top + 30）
    // 周（第二个，top = 月 bottom + 5）
    // 日（第三个，top = 周 bottom + 5）
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 月按钮（第一个）
        _LeafButton(
          text: '月',
          mode: CalendarMode.month,
          isSelected: _selectedMode == CalendarMode.month,
          leafImage: ResourceManager.calendar.leafMonth,
          selectedImage: ResourceManager.calendar.leafSelected,
          onTap: () => _selectMode(CalendarMode.month),
        ),
        const SizedBox(height: 5), // iOS: 按钮间距 5px
        // 周按钮（第二个）
        _LeafButton(
          text: '周',
          mode: CalendarMode.week,
          isSelected: _selectedMode == CalendarMode.week,
          leafImage: ResourceManager.calendar.leafWeek,
          selectedImage: ResourceManager.calendar.leafSelected,
          onTap: () => _selectMode(CalendarMode.week),
        ),
        const SizedBox(height: 5), // iOS: 按钮间距 5px
        // 日按钮（第三个）
        _LeafButton(
          text: '日',
          mode: CalendarMode.day,
          isSelected: _selectedMode == CalendarMode.day,
          leafImage: ResourceManager.calendar.leafDay,
          selectedImage: ResourceManager.calendar.leafSelected,
          onTap: () => _selectMode(CalendarMode.day),
        ),
      ],
    );
  }
}

/// 单个叶子按钮
class _LeafButton extends StatefulWidget {
  const _LeafButton({
    required this.text,
    required this.mode,
    required this.isSelected,
    required this.leafImage,
    required this.selectedImage,
    required this.onTap,
  });

  final String text;
  final CalendarMode mode;
  final bool isSelected;
  final String leafImage;
  final String selectedImage;
  final VoidCallback onTap;

  @override
  State<_LeafButton> createState() => _LeafButtonState();
}

class _LeafButtonState extends State<_LeafButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Scale 动画：选中 1.3，未选中 1.0
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Opacity 动画：选中 1.0，未选中 0.6
    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // 初始化状态
    if (widget.isSelected) {
      _controller.value = 1.0;
    } else {
      _controller.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(_LeafButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // iOS: 按钮大小 50x50
    // 使用 child 参数缓存静态内容，避免重复渲染
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _scaleAnimation.value;
        final opacity = _opacityAnimation.value;

        return GestureDetector(
          behavior: HitTestBehavior.opaque, // 确保整个区域都可以点击
          onTap: () {
            debugPrint('Leaf button tapped: ${widget.text}, mode: ${widget.mode}');
            widget.onTap();
          },
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: SizedBox(
                width: 50, // iOS: 50x50
                height: 50,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 叶子图片
                    Positioned.fill(
                      child: Image.asset(
                        widget.isSelected
                            ? widget.selectedImage
                            : widget.leafImage,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                widget.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // 文字层
                    Center(
                      child: Text(
                        widget.text,
                        style: FontManager.customFontWithColor(
                          size: 14,
                          color: Colors.white,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      // 缓存静态内容，避免每次动画更新时都重新构建
      child: const SizedBox.shrink(), // 这里不需要缓存，因为所有内容都是动态的
    );
  }
}
