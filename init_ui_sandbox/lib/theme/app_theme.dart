import 'package:flutter/material.dart';

/// 沙盒专用主题与断点，迁入主工程时可对齐 `schedule_app_flutter` 的绿色系。
abstract final class AppTheme {
  static const Color seedGreen = Color(0xFF4A7C4E);
  static const Color surfaceMuted = Color(0xFFE8F5E9);

  /// 与主工程 MaterialApp 接近的入口
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedGreen,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }

  /// 粗判平板：短边 ≥ 600（可改为只看 width）
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= 600;
  }

  /// 内容区最大宽度（平板/折叠屏阅读舒适）
  static double contentMaxWidth(BuildContext context) {
    return isTablet(context) ? 560 : double.infinity;
  }
}
