import '../../models/onboarding_question.dart';
import '../../utils/resource_manager.dart';

/// 版本一的三道题数据（对应 01提问页版本1）
/// 换行：在字符串里直接打换行符 \n，例如 '第一行\n第二行' 会显示两行。
List<OnboardingQuestionItem> get onboardingV1Questions => [
      _q1,
      _q2,
      _q3,
    ];

final _q1 = OnboardingQuestionItem(
  questionText: '你的"标准作息"更接近哪种状态?',
  spiritAssetPath: ResourceManager.onboarding.spiritSoil,
  bubbleSize: BubbleSize.long,
  options: const [
    OnboardingOption(
      title: '规律晨型人',
      description: '早6-7点起床,晚10-11点睡觉\n习惯早起早睡',
    ),
    OnboardingOption(
      title: '朝九晚五派',
      description: '早8-9点起床,晚11-12点睡觉\n配合社会主流节奏',
    ),
    OnboardingOption(
      title: '灵感夜猫子',
      description: '中午起床,晚12以后睡觉\n深夜才是我的黄金时间\n上午请让我静音',
    ),
  ],
  bottomHint: '我的作息不属于上述3个选项',
);

final _q2 = OnboardingQuestionItem(
  questionText: '想象你的一天,你希望 事件之间是怎么衔接的?',
  spiritAssetPath: ResourceManager.onboarding.spiritWater,
  bubbleSize: BubbleSize.medium,
  options: const [
    OnboardingOption(
      title: '严丝合缝',
      description: '我追求极致效率\n一个接一个\n别让我闲着',
    ),
    OnboardingOption(
      title: '游刃有余',
      description: '任务间留口喘气的时间\n我不喜欢赶场',
    ),
    OnboardingOption(
      title: '随性而为',
      description: '多留些空白\n不要把时间安排的太细\n我需要大量的自由时间来缓冲',
    ),
  ],
);

final _q3 = OnboardingQuestionItem(
  questionText: '当你面对一个要耗费好几天才能完成的大项目时，你更倾向于？',
  spiritAssetPath: ResourceManager.onboarding.spiritLight,
  bubbleSize: BubbleSize.long,
  options: const [
    OnboardingOption(
      title: '蚂蚁搬家',
      description: '我受不了一直干同一件事\n请帮我拆成每天只做 0.5-1小时的"小碎片"\n我喜欢慢慢磨',
    ),
    OnboardingOption(
      title: '稳扎稳打',
      description: '我喜欢按阶段来\n每次给我留出2-3小时\n让我能专心处理完一个大步骤\n不快也不慢',
    ),
    OnboardingOption(
      title: '暴力通关',
      description: '别打断我！\n请帮我找出一整天/大半天时间\n我想直接"闭关"\n一口气冲到底,不干完不舒服',
    ),
  ],
);
