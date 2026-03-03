import 'package:flutter/material.dart';

/// 带动画效果的图片组件
/// 
/// 使用 FadeInImage 实现图片淡入效果
class AnimatedImage extends StatelessWidget {
  const AnimatedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.placeholder,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/images/placeholder.png', // 如果不存在，会使用默认占位符
        image: imagePath,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        imageErrorBuilder: errorBuilder ??
            (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                ),
              );
            },
        placeholderErrorBuilder: (context, error, stackTrace) {
          return placeholder ??
              Container(
                color: Colors.grey[100],
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[400]!,
                    ),
                  ),
                ),
              );
        },
      ),
    );
  }
}

/// 本地资源图片（带动画效果）
class AnimatedAssetImage extends StatelessWidget {
  const AnimatedAssetImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FadeInImage.assetNetwork(
        placeholder: imagePath, // 使用相同路径作为占位符，实现淡入效果
        image: imagePath,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        imageErrorBuilder: errorBuilder ??
            (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                ),
              );
            },
      ),
    );
  }
}

/// 简化的淡入图片组件（用于本地资源）
class FadeInAssetImage extends StatefulWidget {
  const FadeInAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  @override
  State<FadeInAssetImage> createState() => _FadeInAssetImageState();
}

class _FadeInAssetImageState extends State<FadeInAssetImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Image.asset(
          widget.assetPath,
          fit: widget.fit,
          errorBuilder: widget.errorBuilder ??
              (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                  ),
                );
              },
        ),
      ),
    );
  }
}
