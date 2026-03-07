import 'package:flutter/material.dart';

/// 字体管理器
///
/// 使用系统默认字体，统一管理字号、粗细、颜色等样式。
class FontManager {
  FontManager._(); // 私有构造函数，防止实例化

  /// 获取文本样式（系统默认字体）
  static TextStyle customFont({
    required double size,
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
    );
  }

  /// 获取带颜色的文本样式（系统默认字体）
  static TextStyle customFontWithColor({
    required double size,
    required Color color,
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontStyle: style,
    );
  }
}
