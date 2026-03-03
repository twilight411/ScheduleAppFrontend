import 'package:flutter/material.dart';

/// AI周报组件
/// 
/// 对应 iOS 的 setupWeekReport，显示本周的AI生成周报。
class WeekReportWidget extends StatelessWidget {
  const WeekReportWidget({
    super.key,
    this.reportText,
    this.backgroundImagePath,
  });

  /// 周报文本内容（可选）
  final String? reportText;

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
            
            // 内容区域（使用ScrollView支持长文本滚动）
            SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题"本周AI周报"（距离顶部45）
                  Padding(
                    padding: const EdgeInsets.only(top: 45),
                    child: Center(
                      child: Text(
                        '本周AI周报',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  
                  // 周报内容（距离标题20，左右边距35和25）
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 35,
                      right: 25,
                      bottom: 20,
                    ),
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    // 如果没有周报文本，显示"暂无周报数据"
    if (reportText == null || reportText!.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '暂无周报数据',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // 显示周报文本
    return Text(
      reportText!,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
        height: 1.5, // 行高，使文本更易读
      ),
      textAlign: TextAlign.left,
    );
  }
}
