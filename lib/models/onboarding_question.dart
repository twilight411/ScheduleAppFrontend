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
  });

  final String questionText;
  final String spiritAssetPath;
  final List<OnboardingOption> options;
  /// 底部次要文案，如「我的作息不属于上述3个选项」
  final String? bottomHint;
  final BubbleSize bubbleSize;
}

enum BubbleSize { short, medium, long }
