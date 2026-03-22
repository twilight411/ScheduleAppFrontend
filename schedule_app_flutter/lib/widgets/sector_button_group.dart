import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 扇形按钮组（半圆形，分成3片）
/// 
/// 特性：
/// - 半圆形布局，左边贴着屏幕左边
/// - 3个扇形按钮，每个占60度（180度 / 3）
/// - 点击时选中的扇形会放大弹出
enum SectorType { first, second, third }

class SectorButtonGroup extends StatefulWidget {
  const SectorButtonGroup({
    super.key,
    required this.onSectorChanged,
    this.initialSector = SectorType.second,
    this.radius = 120.0,
    this.colors = const [
      Color(0xFF4CAF50), // 绿色
      Color(0xFF2196F3), // 蓝色
      Color(0xFFFF9800), // 橙色
    ],
    this.labels = const ['日', '周', '月'],
  });

  final Function(SectorType) onSectorChanged;
  final SectorType initialSector;
  final double radius; // 扇形半径
  final List<Color> colors; // 三个扇形的颜色
  final List<String> labels; // 三个扇形的标签

  @override
  State<SectorButtonGroup> createState() => _SectorButtonGroupState();
}

class _SectorButtonGroupState extends State<SectorButtonGroup>
    with SingleTickerProviderStateMixin {
  late SectorType _selectedSector;
  late AnimationController _controller;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _selectedSector = widget.initialSector;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 为每个扇形创建独立的缩放动画
    _scaleAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 1.0,
        end: index == _selectedSector.index ? 1.3 : 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
    });

    // 初始化动画状态
    _updateAnimations();
  }

  void _updateAnimations() {
    // 先重置动画控制器
    _controller.reset();
    
    // 为每个扇形创建新的动画
    for (int i = 0; i < 3; i++) {
      final currentScale = _scaleAnimations[i].value;
      _scaleAnimations[i] = Tween<double>(
        begin: currentScale,
        end: i == _selectedSector.index ? 1.3 : 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
    }
    
    // 启动动画
    _controller.forward();
  }

  void _selectSector(SectorType sector) {
    if (_selectedSector != sector) {
      setState(() {
        _selectedSector = sector;
        _updateAnimations();
      });
      widget.onSectorChanged(sector);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTapDown: (details) {
          // 根据点击位置判断是哪个扇形
          final localPosition = details.localPosition;
          final sector = _getSectorAtPosition(localPosition);
          if (sector != null) {
            debugPrint('点击位置: ${localPosition.dx}, ${localPosition.dy}, 扇形: $sector');
            _selectSector(sector);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: ClipRect(
          child: SizedBox(
            width: widget.radius * 2,
            height: widget.radius * 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 先添加未选中的扇形
                if (_selectedSector != SectorType.first)
                  _buildSector(
                    index: 0,
                    startAngle: -90.0,
                    sweepAngle: 60.0,
                    sectorType: SectorType.first,
                  ),
                if (_selectedSector != SectorType.second)
                  _buildSector(
                    index: 1,
                    startAngle: -30.0,
                    sweepAngle: 60.0,
                    sectorType: SectorType.second,
                  ),
                if (_selectedSector != SectorType.third)
                  _buildSector(
                    index: 2,
                    startAngle: 30.0,
                    sweepAngle: 60.0,
                    sectorType: SectorType.third,
                  ),
                // 最后添加选中的扇形（确保在最上层）
                if (_selectedSector == SectorType.first)
                  _buildSector(
                    index: 0,
                    startAngle: -90.0,
                    sweepAngle: 60.0,
                    sectorType: SectorType.first,
                  ),
                if (_selectedSector == SectorType.second)
                  _buildSector(
                    index: 1,
                    startAngle: -30.0,
                    sweepAngle: 60.0,
                    sectorType: SectorType.second,
                  ),
                if (_selectedSector == SectorType.third)
                  _buildSector(
                    index: 2,
                    startAngle: 30.0,
                    sweepAngle: 60.0,
                    sectorType: SectorType.third,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 根据点击位置判断是哪个扇形
  SectorType? _getSectorAtPosition(Offset position) {
    // 圆心在左侧中心 (0, radius)
    final center = Offset(0, widget.radius);
    
    // 计算点到圆心的距离
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // 如果距离大于半径，不在扇形内
    if (distance > widget.radius) {
      return null;
    }
    
    // 计算角度（-180度到180度）
    var angle = math.atan2(dy, dx) * 180.0 / math.pi;
    
    // 判断角度属于哪个扇形
    // 第一个扇形：-90度到-30度
    if (angle >= -90.0 && angle < -30.0) {
      return SectorType.first;
    }
    // 第二个扇形：-30度到30度
    if (angle >= -30.0 && angle < 30.0) {
      return SectorType.second;
    }
    // 第三个扇形：30度到90度
    if (angle >= 30.0 && angle <= 90.0) {
      return SectorType.third;
    }
    
    return null;
  }

  Widget _buildSector({
    required int index,
    required double startAngle,
    required double sweepAngle,
    required SectorType sectorType,
  }) {
    final isSelected = _selectedSector == sectorType;
    
    // 计算扇形的中心点（用于缩放锚点）
    // 圆心在 (0, radius)，扇形的中心角度
    final centerAngle = startAngle + sweepAngle / 2;
    final centerRadians = centerAngle * math.pi / 180.0;
    final centerRadius = widget.radius * 0.5; // 中心点距离圆心的距离
    final centerX = centerRadius * math.cos(centerRadians);
    final centerY = widget.radius + centerRadius * math.sin(centerRadians);
    
    // Transform.scale的alignment是相对于widget的，范围是-1到1
    // widget大小是 radius * 2，所以需要归一化
    final alignmentX = (centerX / (widget.radius * 2)) * 2 - 1; // 转换为-1到1的范围
    final alignmentY = (centerY / (widget.radius * 2)) * 2 - 1;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _scaleAnimations[index].value;
        
        return Stack(
          children: [
            // 绘制扇形
            Transform.scale(
              scale: scale,
              alignment: Alignment(alignmentX, alignmentY),
              child: ClipPath(
                clipper: SectorClipper(
                  startAngle: startAngle,
                  sweepAngle: sweepAngle,
                  radius: widget.radius,
                ),
                child: CustomPaint(
                  size: Size(widget.radius * 2, widget.radius * 2),
                  painter: SectorPainter(
                    startAngle: startAngle,
                    sweepAngle: sweepAngle,
                    color: widget.colors[index],
                    isSelected: isSelected,
                    radius: widget.radius,
                  ),
                ),
              ),
            ),
            // 标签（不缩放，保持位置）
            _buildSectorLabel(index),
          ],
        );
      },
    );
  }

  Widget _buildSectorLabel(int index) {
    // 计算标签位置（在扇形中心偏右的位置）
    final angle = -90.0 + index * 60.0 + 30.0; // 每个扇形的中心角度
    final radians = angle * math.pi / 180.0;
    final labelRadius = widget.radius * 0.6; // 标签距离中心的距离
    
    // 圆心在左侧中心
    final centerX = 0.0;
    final centerY = widget.radius;
    
    final offsetX = centerX + labelRadius * math.cos(radians);
    final offsetY = centerY + labelRadius * math.sin(radians);
    
    return Positioned(
      left: offsetX,
      top: offsetY,
      child: Text(
        widget.labels[index],
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

/// 扇形裁剪器（用于定义点击区域）
class SectorClipper extends CustomClipper<Path> {
  SectorClipper({
    required this.startAngle,
    required this.sweepAngle,
    required this.radius,
  });

  final double startAngle;
  final double sweepAngle;
  final double radius;

  @override
  Path getClip(Size size) {
    // 圆心在左侧中心（x=0, y=半径）
    final center = Offset(0, radius);

    // 创建扇形路径
    final path = Path();
    path.moveTo(center.dx, center.dy);
    
    // 起始角度（转换为弧度）
    final startRadians = startAngle * math.pi / 180.0;
    
    // 起始点
    final startX = center.dx + radius * math.cos(startRadians);
    final startY = center.dy + radius * math.sin(startRadians);
    path.lineTo(startX, startY);
    
    // 绘制弧线（从起始角度到结束角度）
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startRadians,
      sweepAngle * math.pi / 180.0,
      false,
    );
    
    // 回到圆心
    path.close();

    return path;
  }

  @override
  bool shouldReclip(SectorClipper oldClipper) {
    return oldClipper.startAngle != startAngle ||
        oldClipper.sweepAngle != sweepAngle ||
        oldClipper.radius != radius;
  }
}

/// 扇形绘制器
class SectorPainter extends CustomPainter {
  SectorPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    required this.radius,
    this.isSelected = false,
  });

  final double startAngle;
  final double sweepAngle;
  final Color color;
  final double radius;
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? color : color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 圆心在左侧中心（x=0, y=半径）
    final center = Offset(0, radius);

    // 创建扇形路径
    final path = Path();
    path.moveTo(center.dx, center.dy);
    
    // 起始角度（转换为弧度）
    final startRadians = startAngle * math.pi / 180.0;
    
    // 起始点
    final startX = center.dx + radius * math.cos(startRadians);
    final startY = center.dy + radius * math.sin(startRadians);
    path.lineTo(startX, startY);
    
    // 绘制弧线（从起始角度到结束角度）
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startRadians,
      sweepAngle * math.pi / 180.0,
      false,
    );
    
    // 回到圆心
    path.close();

    // 绘制填充
    canvas.drawPath(path, paint);
    
    // 绘制边框
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(SectorPainter oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.isSelected != isSelected;
  }
}
