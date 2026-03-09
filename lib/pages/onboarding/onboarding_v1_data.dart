import '../../models/onboarding_question.dart';
import '../../utils/resource_manager.dart';

/// 版本一的三道题数据（对应 01提问页版本1）
/// 换行：在字符串里直接打换行符 \n，例如 '第一行\n第二行' 会显示两行。
List<OnboardingQuestionItem> get onboardingV1Questions => [
      _q1,
      _q2,
      _q3,
    ];

// ===== 三个问题页各自的“选项间距参数” =====
// 想让三个页面的排版一开始保持一致，这里给三题同一套初始值；
// 之后如果只想改某一题，就单独改那一题对应的这几个数即可。
//
// 说明：
// - XxxOptionsTopPadding：这一页三块选项在滚动区内整体距顶部的距离（数值越小越靠上）
// - XxxGapAfterFirst   ：这一页第 1、2 块之间的竖直间距
// - XxxGapAfterSecond  ：这一页第 2、3 块之间的竖直间距
// - XxxSlotHeight      ：这一页单块选项的总高度（大字+小字+上下 padding）

// 第 1 题 - 作息类型
// 将全局气泡与选项之间的间距略微减小（在 OnboardingQuestionPage 中从 16 调整为 5），
// 为保持第 1 题的视觉位置不变，这里把本题的顶部间距从 5 调整为 9 
const double kQ1OptionsTopPadding = 9.0;
const double kQ1GapAfterFirst = 0.0;
const double kQ1GapAfterSecond = 20.0;
const double kQ1SlotHeight = 157.0; // 对应 _kOptionSlotHeight 当前的和：40 + 4 + 68 + 45

// 第 2 题 - 事件衔接方式
const double kQ2OptionsTopPadding = 0.0;
const double kQ2GapAfterFirst = 0.0;
const double kQ2GapAfterSecond = 15.0;
const double kQ2SlotHeight = 157.0;

// 第 3 题 - 大项目偏好
const double kQ3OptionsTopPadding = 5.0;
const double kQ3GapAfterFirst = 0.0;
const double kQ3GapAfterSecond = 20.0;
const double kQ3SlotHeight = 157.0;

// ===== 第 1 题：作息类型 =====
final _q1 = OnboardingQuestionItem(
  questionText: '你的"标准作息"更接近哪种状态?',
  spiritAssetPath: ResourceManager.onboarding.spiritSoil,
  bubbleSize: BubbleSize.long,
  // 👉 本题选项间距 / 高度：只影响第 1 题
  optionsTopPadding: kQ1OptionsTopPadding,
  gapAfterFirst: kQ1GapAfterFirst,
  gapAfterSecond: kQ1GapAfterSecond,
  slotHeight: kQ1SlotHeight,
  options: const [
    OnboardingOption(
      title: '规律晨型人',
      description: '早6-7点起床\n晚10-11点睡觉\n习惯早起早睡',
    ),
    OnboardingOption(
      title: '朝九晚五派',
      description: '早8-9点起床\n晚11-12点睡觉\n配合社会主流节奏',
    ),
    OnboardingOption(
      title: '灵感夜猫子',
      description: '中午起床,晚12以后睡觉\n深夜才是我的黄金时间\n上午请让我静音',
    ),
  ],
  bottomHint: '我的作息不属于上述3个选项',
);

// ===== 第 2 题：事件衔接方式 =====
final _q2 = OnboardingQuestionItem(
  questionText: '想象你的一天,你希望 事件之间是怎么衔接的?',
  spiritAssetPath: ResourceManager.onboarding.spiritWater,
  bubbleSize: BubbleSize.medium,
  // 👉 本题选项间距 / 高度：只影响第 2 题
  optionsTopPadding: kQ2OptionsTopPadding,
  gapAfterFirst: kQ2GapAfterFirst,
  gapAfterSecond: kQ2GapAfterSecond,
  slotHeight: kQ2SlotHeight,
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

// ===== 第 3 题：面对大项目的偏好 =====
final _q3 = OnboardingQuestionItem(
  questionText: '当你面对一个要耗费好几天才能完成的大项目时，你更倾向于？',
  spiritAssetPath: ResourceManager.onboarding.spiritLight,
  bubbleSize: BubbleSize.long,
  // 👉 本题选项间距 / 高度：只影响第 3 题
  optionsTopPadding: kQ3OptionsTopPadding,
  gapAfterFirst: kQ3GapAfterFirst,
  gapAfterSecond: kQ3GapAfterSecond,
  slotHeight: kQ3SlotHeight,
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
