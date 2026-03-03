import 'package:flutter/material.dart';

/// 带动画效果的按钮组件
/// 
/// 提供点击缩放动画反馈
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.onTap,
    required this.child,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  final VoidCallback onTap;
  final Widget child;
  final double scale;
  final Duration duration;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
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
      child: AnimatedScale(
        scale: _isPressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

/// 带动画效果的图标按钮
class AnimatedIconButton extends StatelessWidget {
  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.size = 24,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onPressed,
      child: IconButton(
        icon: icon,
        onPressed: null, // 由 AnimatedButton 处理
        tooltip: tooltip,
        color: color,
        iconSize: size,
      ),
    );
  }
}

/// 带动画效果的浮动操作按钮
class AnimatedFloatingActionButton extends StatelessWidget {
  const AnimatedFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onPressed,
      scale: 0.9,
      child: FloatingActionButton(
        onPressed: null, // 由 AnimatedButton 处理
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        tooltip: tooltip,
        child: child,
      ),
    );
  }
}
