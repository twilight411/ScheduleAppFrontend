import 'package:flutter/material.dart';

/// 对应 iOS 中的 SpiritType 枚举
enum SpiritType {
  light, // 光精灵（工作学习）
  water, // 水精灵（娱乐休闲）
  soil, // 土壤精灵（健康）
  air, // 空气精灵（社交）
  nutrition, // 营养精灵（爱好）
}

extension SpiritTypeDisplayName on SpiritType {
  String get displayName {
    switch (this) {
      case SpiritType.light:
        return '光精灵';
      case SpiritType.water:
        return '水精灵';
      case SpiritType.soil:
        return '土壤精灵';
      case SpiritType.air:
        return '空气精灵';
      case SpiritType.nutrition:
        return '营养精灵';
    }
  }
}

extension SpiritTypeColor on SpiritType {
  Color get color {
    switch (this) {
      case SpiritType.light:
        // 原先的纯黄色太亮，改为偏柔和的琥珀色，接近 iOS 中的暖黄但不刺眼
        return Colors.amber.shade600;
      case SpiritType.water:
        return Colors.blue;
      case SpiritType.soil:
        return Colors.brown;
      case SpiritType.air:
        return Colors.grey;
      case SpiritType.nutrition:
        return Colors.green;
    }
  }
}

extension SpiritTypeIcon on SpiritType {
  IconData get icon {
    switch (this) {
      case SpiritType.light:
        return Icons.sunny;
      case SpiritType.water:
        return Icons.water_drop;
      case SpiritType.soil:
        return Icons.eco;
      case SpiritType.air:
        return Icons.air;
      case SpiritType.nutrition:
        return Icons.star;
    }
  }
}

