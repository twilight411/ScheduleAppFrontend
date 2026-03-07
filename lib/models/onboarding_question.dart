/// 初始化提问页（版本一）单道题的选项
class OnboardingOption {
  const OnboardingOption({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

/// 初始化提问页（版本一）单道题的数据
class OnboardingQuestionItem {
  const OnboardingQuestionItem({
    required this.questionText,
    required this.spiritAssetPath,
    required this.options,
    this.bottomHint,
    this.bubbleSize = BubbleSize.medium,
    this.optionsTopPadding,
    this.gapAfterFirst,
    this.gapAfterSecond,
    this.slotHeight,
  });

  final String questionText;
  final String spiritAssetPath;
  final List<OnboardingOption> options;
  /// 底部次要文案，如「我的作息不属于上述3个选项」
  final String? bottomHint;
  final BubbleSize bubbleSize;
  /// 如果某一道题需要单独调整「选项整体在滚动区里的上边距」，在数据里传这个值；
  /// 不传则使用默认常量 _kOptionsTopPadding。
  final double? optionsTopPadding;
  /// 如果某一道题需要单独调整「第 1 个选项和第 2 个选项之间的间距」，在数据里传这个值；
  /// 不传则使用默认常量 _kBlockGapAfterFirst。
  final double? gapAfterFirst;
  /// 如果某一道题需要单独调整「第 2 个选项和第 3 个选项之间的间距」，在数据里传这个值；
  /// 不传则使用默认常量 _kBlockGapAfterSecond。
  final double? gapAfterSecond;
  /// 如果某一道题的小字比较多/比较少，希望整块选项「更高或更矮」，在数据里传 slotHeight；
  /// 不传则使用默认常量 _kOptionSlotHeight。
  final double? slotHeight;
}

enum BubbleSize { short, medium, long }
