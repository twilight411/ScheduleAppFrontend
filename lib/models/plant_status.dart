import 'package:flutter/material.dart';
import 'spirit_type.dart';

/// 日期范围辅助类，对应 iOS 中的 DateInterval
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({
    required this.start,
    required this.end,
  }) : assert(
          end.isAfter(start) || end.isAtSameMomentAs(start),
          '结束日期必须大于或等于开始日期',
        );

  /// 获取日期范围的持续时间（天数）
  Duration get duration => end.difference(start);

  /// 获取日期范围的天数
  int get days => duration.inDays + 1;

  /// 检查日期是否在范围内
  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  /// 从 JSON 创建
  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() => 'DateRange(start: $start, end: $end)';
}

/// 植物状态模型，对应 iOS 中的 PlantStatus
class PlantStatus {
  /// 周的开始和结束日期
  final DateRange weekRange;

  /// 每个精灵的分数，范围 0.0-1.0
  final Map<SpiritType, double> spiritScores;

  /// 植物图片URL，可选
  final String? plantImageUrl;

  PlantStatus({
    required this.weekRange,
    required this.spiritScores,
    this.plantImageUrl,
  });

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    // 将 SpiritType 枚举转换为字符串键
    final scoresJson = <String, double>{};
    spiritScores.forEach((key, value) {
      scoresJson[_spiritTypeToString(key)] = value;
    });

    return {
      'weekRange': weekRange.toJson(),
      'spiritScores': scoresJson,
      'plantImageUrl': plantImageUrl,
    };
  }

  /// 从 JSON 创建
  factory PlantStatus.fromJson(Map<String, dynamic> json) {
    // 将字符串键转换回 SpiritType 枚举
    final scores = <SpiritType, double>{};
    if (json['spiritScores'] != null) {
      final scoresJson = json['spiritScores'] as Map<String, dynamic>;
      scoresJson.forEach((key, value) {
        final spiritType = _spiritTypeFromString(key);
        if (spiritType != null) {
          scores[spiritType] = (value as num).toDouble();
        }
      });
    }

    return PlantStatus(
      weekRange: DateRange.fromJson(json['weekRange'] as Map<String, dynamic>),
      spiritScores: scores,
      plantImageUrl: json['plantImageUrl'] as String?,
    );
  }

  /// 将 SpiritType 枚举转换为字符串
  static String _spiritTypeToString(SpiritType type) {
    switch (type) {
      case SpiritType.light:
        return 'light';
      case SpiritType.water:
        return 'water';
      case SpiritType.soil:
        return 'soil';
      case SpiritType.air:
        return 'air';
      case SpiritType.nutrition:
        return 'nutrition';
    }
  }

  /// 从字符串转换为 SpiritType 枚举
  static SpiritType? _spiritTypeFromString(String value) {
    switch (value) {
      case 'light':
        return SpiritType.light;
      case 'water':
        return SpiritType.water;
      case 'soil':
        return SpiritType.soil;
      case 'air':
        return SpiritType.air;
      case 'nutrition':
        return SpiritType.nutrition;
      default:
        return null;
    }
  }

  /// 创建副本并更新字段
  PlantStatus copyWith({
    DateRange? weekRange,
    Map<SpiritType, double>? spiritScores,
    String? plantImageUrl,
  }) {
    return PlantStatus(
      weekRange: weekRange ?? this.weekRange,
      spiritScores: spiritScores ?? this.spiritScores,
      plantImageUrl: plantImageUrl ?? this.plantImageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantStatus &&
        other.weekRange == weekRange &&
        _mapEquals(other.spiritScores, spiritScores) &&
        other.plantImageUrl == plantImageUrl;
  }

  @override
  int get hashCode =>
      weekRange.hashCode ^
      spiritScores.hashCode ^
      (plantImageUrl?.hashCode ?? 0);

  /// 比较两个 Map 是否相等
  bool _mapEquals(Map<SpiritType, double> a, Map<SpiritType, double> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'PlantStatus(weekRange: $weekRange, spiritScores: $spiritScores, plantImageUrl: $plantImageUrl)';
  }
}
