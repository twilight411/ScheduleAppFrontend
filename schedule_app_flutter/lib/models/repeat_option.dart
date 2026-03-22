/// 任务重复选项，对应 iOS 中的重复设置
enum RepeatOption {
  never, // 永不
  daily, // 每日重复
  weekly, // 每周重复
  monthly, // 每月重复
}

extension RepeatOptionDisplayName on RepeatOption {
  String get displayName {
    switch (this) {
      case RepeatOption.never:
        return '永不';
      case RepeatOption.daily:
        return '每日重复';
      case RepeatOption.weekly:
        return '每周重复';
      case RepeatOption.monthly:
        return '每月重复';
    }
  }
}

extension RepeatOptionValues on RepeatOption {
  /// 显式列出所有枚举值，便于在 UI 中使用
  static List<RepeatOption> get values => [
        RepeatOption.never,
        RepeatOption.daily,
        RepeatOption.weekly,
        RepeatOption.monthly,
      ];
}

