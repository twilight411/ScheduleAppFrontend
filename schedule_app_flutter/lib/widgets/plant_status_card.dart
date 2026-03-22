import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plant_status.dart';
import '../utils/resource_manager.dart';

/// 植物状态卡片组件
/// 
/// 对应 iOS 的 setupPlantStatusView，显示植物状态、周标签和切换按钮。
class PlantStatusCard extends StatelessWidget {
  const PlantStatusCard({
    super.key,
    required this.plantStatus,
    required this.currentWeek,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  /// 植物状态数据
  final PlantStatus plantStatus;

  /// 当前显示的周（用于判断"本周"、"上周"、"下周"）
  final DateTime currentWeek;

  /// 切换到上一周的回调
  final VoidCallback onPreviousWeek;

  /// 切换到下一周的回调
  final VoidCallback onNextWeek;

  /// 格式化周标签文本
  /// 
  /// 格式："{前缀} {开始日期}—{结束日期}"
  /// 前缀根据当前周与本周的关系显示"本周"、"上周"或"下周"
  String _formatWeekLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 计算当前周的开始日期（周一）
    final currentWeekStart = _getWeekStart(currentWeek);
    final thisWeekStart = _getWeekStart(today);
    
    // 计算周差
    final weekDiff = (currentWeekStart.difference(thisWeekStart).inDays / 7).round();
    
    // 确定前缀
    String prefix;
    if (weekDiff == 0) {
      prefix = '本周';
    } else if (weekDiff < 0) {
      prefix = '上周';
    } else {
      prefix = '下周';
    }
    
    // 格式化日期
    final formatter = DateFormat('M月d日', 'zh_CN');
    final startDate = formatter.format(plantStatus.weekRange.start);
    final endDate = formatter.format(plantStatus.weekRange.end);
    
    return '$prefix $startDate—$endDate';
  }

  /// 获取指定日期所在周的开始日期（周一）
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 背景图片
            Positioned.fill(
              child: Image.asset(
                ResourceManager.backgrounds.plantStatus,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white.withOpacity(0.3),
                  );
                },
              ),
            ),
            
            // 周标签（顶部）
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            child: Text(
              _formatWeekLabel(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 植物图片（中间，居中）
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                ResourceManager.plant.treeSample,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderPlant();
                },
              ),
            ),
          ),
          
          // 左箭头按钮（稍微往外移，不遮挡植物图片）
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildArrowButton(
                imagePath: ResourceManager.plant.arrowLeft,
                onPressed: onPreviousWeek,
              ),
            ),
          ),
          
          // 右箭头按钮（稍微往外移，不遮挡植物图片）
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildArrowButton(
                imagePath: ResourceManager.plant.arrowRight,
                onPressed: onNextWeek,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  /// 构建占位符植物图片
  Widget _buildPlaceholderPlant() {
    return Icon(
      Icons.eco,
      size: 180,
      color: Colors.green,
    );
  }

  /// 构建箭头按钮
  /// 
  /// Flutter 版：去掉重阴影，只保留透明背景 + 点击反馈
  Widget _buildArrowButton({
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Image.asset(
              imagePath,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  imagePath.contains('left') ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.white,
                  size: 24,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
