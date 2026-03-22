import 'package:flutter/material.dart';
import '../models/plant_status.dart';
import '../models/spirit_type.dart';
import '../utils/resource_manager.dart';

/// 雷达图组件
/// 
/// 对应 iOS 的 setupRadarChart，显示精灵分数的雷达图。
/// 当前阶段显示静态图片，后续可以升级为动态绘制雷达图（使用 CustomPaint）。
class RadarChartWidget extends StatelessWidget {
  const RadarChartWidget({
    super.key,
    required this.plantStatus,
    this.radarImagePath,
    this.backgroundImagePath,
  });

  /// 植物状态数据（用于显示精灵分数）
  final PlantStatus plantStatus;

  /// 雷达图图片路径（可选，后续阶段5会添加）
  /// 
  /// 如果提供，将使用 Image.asset 显示
  final String? radarImagePath;

  /// 背景图片路径（可选，后续阶段5会添加）
  /// 
  /// 如果提供，将作为背景显示
  final String? backgroundImagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 背景：如果有背景图则使用背景图，否则使用半透明白色
        color: backgroundImagePath == null
            ? Colors.white.withOpacity(0.3)
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 背景图片（如果有）
            if (backgroundImagePath != null)
              Positioned.fill(
                child: Image.asset(
                  backgroundImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // 如果背景图加载失败，使用半透明白色
                    return Container(
                      color: Colors.white.withOpacity(0.3),
                    );
                  },
                ),
              ),
            
            // 雷达图（居中显示，占容器的90%）
            Center(
              child: _buildRadarContent(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建雷达图内容
  Widget _buildRadarContent(BuildContext context) {
    // 优先使用传入的 radarImagePath，否则使用 ResourceManager 的默认路径
    final imagePath = radarImagePath ?? ResourceManager.plant.radarSample;
    
    return FractionallySizedBox(
      widthFactor: 0.9,
      heightFactor: 0.9,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // 如果图片加载失败，显示占位符
          return _buildPlaceholder();
        },
      ),
    );
  }

  /// 构建占位符
  /// 
  /// 显示文字提示和精灵分数信息
  Widget _buildPlaceholder() {
    return FractionallySizedBox(
      widthFactor: 0.9,
      heightFactor: 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.radar,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '雷达图',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '（静态图片占位符）',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            // 显示精灵分数信息（可选）
            ...plantStatus.spiritScores.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${(entry.value * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
