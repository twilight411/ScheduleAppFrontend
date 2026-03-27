import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/resource_manager.dart';
import '../../utils/font_manager.dart';
import '../../utils/onboarding_width_adapt.dart';
import '../../models/onboarding_question.dart';

// =============================================================================
// V1 三选项页：设计说明（为什么不同设备容易「对不齐 / 溢出 / 换行不一样」）
// =============================================================================
// 当前实现是「**无底纹叶子字母的底图** + **代码并排叶子/字母** + 叠文字」：
//   - 背景用 `ResourceManager.onboarding.background`（onboarding_question_bg.png）；叶子与 A/B/C 用
//     `leaf_left` / `leaf_right` 与 `opt_a`~`opt_c` 在 [_OptionTile] 里与标题并排绘制。
//   - 文案相对装饰的位移由 `OnboardingWidthAdapt` 的 block* 与 `_kOnboardingDecoGap` 等控制。
//   - 若需回退整图背景，可把 Stack 底图改回 `backgroundWithLeavesAndLetters` 并去掉装饰 Row。
//   - 标题区、描述区是固定高度槽位 + 内部 `SingleChildScrollView`；系统字体缩放
//     （无障碍「显示大小」）会让同样字数占更高，槽不够就溢出——所以代码里限制了 textScaler、
//     并用 `max(slotHeight, _kOptionSlotMinHeight)` 防止数据里槽高填太小。
//   - 描述里每一段是一个 `Text`，段内仍会因宽度不足自动软折行，所以窄机与宽机「行数」可能不同；
//     需要固定断行时在 `onboarding_v1_data.dart` 里用 `\n` 拆成多段。
//
// 若要做到各设备像素级稳定，更理想的做法是（工作量较大）：
//   - 字母与叶子分层资源 + `LayoutBuilder` 按宽度比例摆位，或
//   - 不用位图字母、改用纯文字/矢量绘制 A/B/C，或
//   - 为 2～3 档断点维护不同 inset（`MediaQuery.size` 分支）。
// 在不大改美术的前提下，下面这组 **具名常量** 就是推荐的调参入口：只改数字、不用在 build 里找魔法数。
//
// =============================================================================
// 【怎么移动】—— 只改本文件顶部常量即可（热重载生效）
// =============================================================================
// 左右 —— 三列整体（分档见 `lib/utils/onboarding_width_adapt.dart`）：
//   运行按屏宽选用 `OnboardingWidthAdapt.optionsHorizontalPadding` 等（改分档请编辑该文件）。
//
// 左右 —— 单块内部（与背景 A/B/C 对齐）：
//   **平板** A/C/B 左右微调优先改 `lib/utils/onboarding_width_adapt.dart` 里 `isTablet` 分支
//   （含 `blockALeadingExtra` / `blockCLeadingExtra` / `blockBTrailingExtra` / `blockBLeadingExtra`），
//   文件内中文注释逐项说明怎么改。
//   `OnboardingWidthAdapt.blockALeadingExtra` / `blockCLeadingExtra`（手机分档在 adapt 里）第 1、3 块左侧再加多少。
//                                   变小 → 该块文案左移；变大 → 右移（可与 A、C 设不同值）。
//   `_kOptionBlockBLeadingExtra`    第 2 块（B）左侧额外推距（**手机**；平板再加 `widthAdapt.blockBLeadingExtra`）。
//   `_kOptionBlockACTrailingPadding`  A/C 的右侧内边距；B 也用它作靠右一侧的基础值。
//   `_kOptionBlockBTrailingExtra`   仅 B：右侧再加的留白；变小 → B 文案左移、区变宽。
//   `_kOptionTilePaddingBase`       每块上下 + 左右计算的基准（一般不用动）。
//
// 上下 —— 三列整体在滚动区里：
//   `_kOptionsTopPadding`           默认上边距；单题可覆盖：见 `onboarding_v1_data.dart` 的 `optionsTopPadding`。
//   `_kBlockGapAfterFirst` / `_kBlockGapAfterSecond`  第 1-2、2-3 块之间的竖缝；单题可覆盖 `gapAfterFirst/Second`。
//   `_kOptionFirstBlockTopPullUp`     从滚动区顶缝减去，第一块上移（叠 `optionsTopPadding` / adapt 顶 padding）。
//   `_kOptionGapPullSecondBlockUp` / `_kOptionGapPullThirdBlockUp`  分别从 **A–B** / **B–C** 缝减去，第二、三块上移。
//   平板单独竖移：`optionsExtraGapAfterFirstOnly`（只推 B 下）、`optionsExtraGapAfterSecondOnly`（只推 C 下）。
//   气泡与第一块选项的间距：在 `OnboardingQuestionPage.build` 里找 `SizedBox(height: 5)`（注释写明的那行）。
//
// 上下 —— 单块高度（避免溢出必看）：
//   `_kOptionTitleAreaHeight` / `_kOptionDescAreaHeight` / `_kOptionTilePaddingBase*2`(上下)
//   三者之和 + 间距 `_kOptionGapTitleToDesc` = `_kOptionSlotMinHeight`；外层槽高不得小于它。
//   单题更高描述：`onboarding_v1_data.dart` 里该题的 `slotHeight` ≥ `_kOptionSlotMinHeight`。
//
// 大字 ↔ 小字竖距（想再调看这里）：
//   `_kOptionGapTitleToDesc`：标题槽底与小字区顶之间的 **布局缝**（可为 0）。
//   `_kOptionDescVisualPullTowardTitle`：小字区 **整体上移**叠向标题（不改槽高，只收紧视觉距离）。
//   `_kOptionTitleAreaHeight`：标题槽高度，略减可少留「字下方的空档」。
//   小字行框：`_OptionTile` 里描述 `Text` 的 `height` / `StrutStyle.height`、段间 `Padding(bottom: 2)`。
//
// 【换行】
//   气泡：`questionText` 里 `\n`。
//   选项描述：`onboarding_v1_data.dart` 的 `description` 里 `\n`（每段独立一行，减少软折行差异）。
// =============================================================================
// ========== 样式常量（大字 / 小字 分开） ==========
// ----- 大字（选项标题）------
const double _kOptionTitleSize = 32.0;
const Color _kOptionTitleColor = Color(0xFF234434);
const Color _kOptionTitleColorSelected = Color(0xFFEDFFDD);
const FontWeight _kOptionTitleWeight = FontWeight.w600;
// 大字所在区域高度（略小则大字与小字视觉上更近；过小易在极大字号下溢出）
const double _kOptionTitleAreaHeight = 48.0;

// ----- 小字（选项描述，固定高度区域，在大字正下方）------
const double _kOptionDescSize = 13.0;
const Color _kOptionDescColor = Color(0xFF234434);
const FontWeight _kOptionDescWeight = FontWeight.normal;

/// 小字区高度：多行描述 + 模拟器较大 textScale 时仍需可滚动浏览
const double _kOptionDescAreaHeight = 88.0;

// ---------------------------------------------------------------------------
// 【调参】选项「大字标题」与「小字描述」之间的竖直距离
// `_kOptionGapTitleToDesc`：布局上的缝（≥0），标题槽底到描述区占位顶。
// `_kOptionDescVisualPullTowardTitle`：把小字 **往上挪**（dp），与标题槽 **视觉重叠**，槽高不变；想再近就加大（如 8～12），太远改小。
// ---------------------------------------------------------------------------
const double _kOptionGapTitleToDesc = 0.0;

/// 描述块整体向上平移，收紧与标题的视觉效果（布局占位不变，热重载生效）。
const double _kOptionDescVisualPullTowardTitle = 8.0;

// ----- 单块选项卡片内边距（与背景图里 A/B/C 位置对齐的核心参数，见文件头「怎么移动」）-----
/// 卡片内上下左右共用的基准 padding（竖直方向全用此值）。
const double _kOptionTilePaddingBase = 10.0;

/// B 块 [左侧] 额外位移（各宽度共用；**A/C 左移与 B 右留白见** [OnboardingWidthAdapt]）。
const double _kOptionBlockBLeadingExtra = 0.0;

/// 第 1、3 块的 [右侧] 内边距。第 2 块右侧 = 本值 + `widthAdapt.blockBTrailingExtra`。
const double _kOptionBlockACTrailingPadding = 4.0;

/// 与 [_OptionTile] 内上下 padding（2 × [_kOptionTilePaddingBase]）一致。
const double _kOptionTileVerticalPadding =
    _kOptionTilePaddingBase + _kOptionTilePaddingBase;

/// 标题区 + 与描述间距 + 描述区 的叠层总高度（与叶子比高，取大者定槽高）。
const double _kOptionTextStackHeight =
    _kOptionTitleAreaHeight + _kOptionGapTitleToDesc + _kOptionDescAreaHeight;

// ----- 选项块左侧/右侧：叶子 + 字母装饰（调外观主要改下面几个）-----
/// 【调字母装饰大小】`opt_a` / `opt_b` / `opt_c` 的显示高度（逻辑 dp），与标题行大致齐平。
const double _kOnboardingDecoLetterHeight = 56.0;

/// 【调叶子大小 — 主旋钮】`leaf_left` / `leaf_right` 的显示高度；越大叶子越大。
/// 槽高下限会自动用 max(本值, 上面文案叠层高度)+上下 padding，一般不必改 `slotHeight`。这个调大叶子就大
/// 手机单屏需容纳三槽时略收叶子高度（仍高于文案叠层则仍由叶子定槽高）。
const double _kOnboardingDecoLeafHeight = 200.0;

/// 【调叶-字-文水平间距】叶子与字母、字母与标题文案之间的水平缝（dp）。
const double _kOnboardingDecoGap = 6.0;

/// 【调叶子贴边微调】在已抵消 `optionsHorizontalPadding` 之后，再向屏侧多伸出的 dp；一般 0～8。
const double _kOnboardingLeafEdgeBleed = 6.0;

/// 单块槽高下限：上下 padding + max(文案叠层, 叶子)，避免叶子放大后竖直溢出（不用 math.max 以便保持顶层 const）。
const double _kOptionSlotMinHeight =
    _kOptionTileVerticalPadding +
    (_kOptionTextStackHeight > _kOnboardingDecoLeafHeight
        ? _kOptionTextStackHeight
        : _kOnboardingDecoLeafHeight);

/// 默认槽高；某题描述更多时可在数据里传更大的 `slotHeight`
const double _kOptionSlotHeight = _kOptionSlotMinHeight;

/// 选项区整体距顶（改小=三块在滚动区内整体上移）
const double _kOptionsTopPadding = 3.0;

/// 第 1 块与第 2 块之间的间距（改大=第二块多下移）
const double _kBlockGapAfterFirst = 0.0;

/// 第 2 块与第 3 块之间的间距（改大=第三块多下移）
const double _kBlockGapAfterSecond = 10.0;

/// 从选项滚动区 **顶部留白** 再减去的 dp，第一块整体上移（与 `optionsTopPadding`、`optionsScrollTopPaddingExtra` 叠加）。
const double _kOptionFirstBlockTopPullUp = 24.0;

/// 仅从 A–B 缝「吃掉」的 dp，第二块整体上移（与 adapt 的 gapAfterFirstOnly 等叠加）。
const double _kOptionGapPullSecondBlockUp = 28.0;

/// 仅从 B–C 缝「吃掉」的 dp，第三块整体上移（与 adapt 的 gapAfterSecondOnly 等叠加）。
const double _kOptionGapPullThirdBlockUp = 56.0;
// 底部小字「我的作息不属于上述3个选项」：改 size / color / weight，且置底
const double _kBottomHintSize = 14.0;
const Color _kBottomHintColor = Color(0xFF688F59); // #688F59

/// 【调精灵大小】三题气泡旁小精灵头像边长（逻辑 dp）；热重载生效。
const double _kSpiritAvatarSize = 90.0;

/// 版本一：单页「三选项」提问 UI
/// 包含：精灵头像 + 对话气泡 + A/B/C 三个选项（单选）+ 可选底部提示
class OnboardingQuestionPage extends StatelessWidget {
  const OnboardingQuestionPage({
    super.key,
    required this.item,
    required this.selectedIndex,
    required this.onOptionSelected,
    this.showLeftArrow = false,
    this.showRightArrow = true,
    this.onLeftArrowTap,
    this.onRightArrowTap,
  });

  final OnboardingQuestionItem item;

  /// 当前选中的选项索引 0/1/2，未选为 -1
  final int selectedIndex;
  final ValueChanged<int> onOptionSelected;
  final bool showLeftArrow;
  final bool showRightArrow;
  final VoidCallback? onLeftArrowTap;
  final VoidCallback? onRightArrowTap;

  String get _bubbleAsset {
    switch (item.bubbleSize) {
      case BubbleSize.short:
        return ResourceManager.onboarding.bubbleShort;
      case BubbleSize.medium:
        return ResourceManager.onboarding.bubbleMedium;
      case BubbleSize.long:
        return ResourceManager.onboarding.bubbleLong;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 默认布局参数 + 每道题可选覆盖（item.xxx），便于针对小字多少微调：
    // - optionsTopPadding：这一页三块在滚动区内整体的上边距
    // - gapAfterFirst / gapAfterSecond：这一页第 1/2、2/3 块之间的竖直间距
    // - slotHeight：这一页单块总高度（大字+小字+上下 padding），小字很多/很少时单独调
    final double optionsTopPadding =
        item.optionsTopPadding ?? _kOptionsTopPadding;
    final double gapAfterFirst = item.gapAfterFirst ?? _kBlockGapAfterFirst;
    final double gapAfterSecond = item.gapAfterSecond ?? _kBlockGapAfterSecond;
    // 防止数据里误填小于内容所需的 slotHeight（旧版 157 等），强制不低于理论最小高度
    final double slotHeight = math.max(
      item.slotHeight ?? _kOptionSlotHeight,
      _kOptionSlotMinHeight,
    );

    // 模拟器/系统「显示大小」较大时 textScale 可达 1.2+，固定槽高易溢出；略限制缩放使与真机更接近
    final mq = MediaQuery.of(context);
    final clampedScaler = mq.textScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.12,
    );
    final widthAdapt = OnboardingWidthAdapt.fromMediaQuery(mq);

    // 与第 1/2 题共用同一套布局。第 3 题在数据里往往 slotHeight 更大（如 182）、描述行更多，
    // 再叠 Medium Phone 的「整体下移 + 块间加距」会把第三块 C 挤到贴底；高槽题自动减弱附加竖向量。
    // **平板** 不减弱：否则平板第三题块间距被压得太扁，B/C 会显得「挤在上半屏」。
    final bool isHeavyVerticalQuestion = slotHeight > _kOptionSlotMinHeight + 4;
    final double pageExtraTopOffset =
        (!widthAdapt.isTablet && isHeavyVerticalQuestion)
        ? widthAdapt.optionsExtraTopOffset * 0.4
        : widthAdapt.optionsExtraTopOffset;
    final double pageExtraGapBetweenBlocks =
        (!widthAdapt.isTablet && isHeavyVerticalQuestion)
        ? widthAdapt.optionsExtraGapBetweenBlocks * 0.35
        : widthAdapt.optionsExtraGapBetweenBlocks;
    // 仅 A-B / B-C 之间额外缝；高槽手机题同比例减弱。
    final double pageExtraGapAfterFirstOnly =
        (!widthAdapt.isTablet && isHeavyVerticalQuestion)
        ? widthAdapt.optionsExtraGapAfterFirstOnly * 0.35
        : widthAdapt.optionsExtraGapAfterFirstOnly;
    final double pageExtraGapAfterSecondOnly =
        (!widthAdapt.isTablet && isHeavyVerticalQuestion)
        ? widthAdapt.optionsExtraGapAfterSecondOnly * 0.35
        : widthAdapt.optionsExtraGapAfterSecondOnly;

    return MediaQuery(
      data: mq.copyWith(textScaler: clampedScaler),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 全屏底图；前景 Column 无底色，透明处勿用黑 Scaffold 衬底（见沙盒 flow 的 scaffoldBackgroundColor）
          Positioned.fill(
            child: Image.asset(
              ResourceManager.onboarding.background,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Color(0xFFE2EEE0)),
            ),
          ),
          // 内容区：平板居中限宽（背景仍全屏）；手机铺满（透明，不挡底图）
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxContentW = widthAdapt.contentMaxWidth;
                  final w =
                      maxContentW != null && constraints.maxWidth > maxContentW
                      ? maxContentW
                      : constraints.maxWidth;
                  final screenW = constraints.maxWidth;
                  final screenH = constraints.maxHeight;
                  return SizedBox(
                    width: screenW,
                    height: screenH,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 顶栏全屏宽，箭头贴安全区左右（平板不再跟中间 540 栏）
                        SafeArea(
                          top: true,
                          bottom: false,
                          left: true,
                          right: true,
                          child: SizedBox(
                            height: 40,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: widthAdapt.arrowRowEdgePadding,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: showLeftArrow
                                        ? _ArrowButton(
                                            asset: ResourceManager
                                                .onboarding
                                                .arrowLeft,
                                            onTap: onLeftArrowTap ?? () {},
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: showRightArrow
                                        ? _ArrowButton(
                                            asset: ResourceManager
                                                .onboarding
                                                .arrowRight,
                                            onTap: onRightArrowTap ?? () {},
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 4),
                                  // 问题区：精灵 + 气泡
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: widthAdapt
                                          .bubbleSectionHorizontalPadding,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 精灵头像
                                        Image.asset(
                                          item.spiritAssetPath,
                                          width: _kSpiritAvatarSize,
                                          height: _kSpiritAvatarSize,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.face,
                                                    size: _kSpiritAvatarSize,
                                                    color: Colors.white54,
                                                  ),
                                        ),
                                        const SizedBox(width: 8),
                                        // 气泡 + 问题文字
                                        Expanded(
                                          child: Stack(
                                            alignment: Alignment.centerLeft,
                                            children: [
                                              Image.asset(
                                                _bubbleAsset,
                                                fit: BoxFit.fitWidth,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.9,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        item.questionText,
                                                        style:
                                                            FontManager.customFontWithColor(
                                                              size: 16,
                                                              color: Colors
                                                                  .black87,
                                                              weight: FontWeight
                                                                  .w500,
                                                            ),
                                                      ),
                                                    ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      28,
                                                      16,
                                                      20,
                                                      20,
                                                    ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: item.questionText
                                                      .replaceAll(r'\n', '\n')
                                                      .split('\n')
                                                      .map(
                                                        (line) => Text(
                                                          line,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              FontManager.customFontWithColor(
                                                                size: 16,
                                                                color:
                                                                    const Color(
                                                                      0xFF333333,
                                                                    ),
                                                                weight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // 气泡区域 ↔ 下方选项列表 的竖直间距（高槽题会减弱 pageExtraTopOffset）
                                  SizedBox(height: 2 + pageExtraTopOffset),
                                  // 三个选项：固定高度、不压缩，按设计稿；整区可滚动，避免小屏溢出
                                  Expanded(
                                    child: SingleChildScrollView(
                                      // 允许选项内叶子 Transform 伸出到 padding 外，贴齐屏侧（仍受安全区约束）
                                      clipBehavior: Clip.none,
                                      padding: EdgeInsets.only(
                                        bottom: isHeavyVerticalQuestion
                                            ? 16
                                            : 6,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: widthAdapt
                                              .optionsHorizontalPadding,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: math.max(
                                                0,
                                                optionsTopPadding +
                                                    widthAdapt
                                                        .optionsScrollTopPaddingExtra -
                                                    _kOptionFirstBlockTopPullUp,
                                              ),
                                            ),
                                            ...List.generate(
                                              item.options.length,
                                              (i) => [
                                                SizedBox(
                                                  height: slotHeight,
                                                  child: _OptionTile(
                                                    option: item.options[i],
                                                    isSelected:
                                                        selectedIndex == i,
                                                    onTap: () =>
                                                        onOptionSelected(i),
                                                    blockIndex: i,
                                                    widthAdapt: widthAdapt,
                                                  ),
                                                ),
                                                if (i < item.options.length - 1)
                                                  SizedBox(
                                                    height: math.max(
                                                      0,
                                                      (i == 0
                                                              ? gapAfterFirst
                                                              : gapAfterSecond) +
                                                          pageExtraGapBetweenBlocks +
                                                          (i == 0
                                                              ? pageExtraGapAfterFirstOnly
                                                              : 0) +
                                                          (i == 1
                                                              ? pageExtraGapAfterSecondOnly
                                                              : 0) -
                                                          (i == 0
                                                              ? _kOptionGapPullSecondBlockUp
                                                              : i == 1
                                                                  ? _kOptionGapPullThirdBlockUp
                                                                  : 0.0),
                                                    ),
                                                  ),
                                              ],
                                            ).expand((e) => e),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (item.bottomHint != null)
                                    SafeArea(
                                      top: false,
                                      bottom: true,
                                      left: true,
                                      right: true,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: GestureDetector(
                                          onTap: () => onOptionSelected(-1),
                                          child: Center(
                                            child: Text(
                                              item.bottomHint!,
                                              style:
                                                  FontManager.customFontWithColor(
                                                    size: _kBottomHintSize,
                                                    color: _kBottomHintColor,
                                                    weight: FontWeight.normal,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        asset,
        width: 36,
        height: 36,
        color: const Color(0xFF8BC34A),
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.arrow_back, size: 24, color: Colors.green.shade300),
      ),
    );
  }
}

/// 选项行：叶子 + 字母 + 标题/描述；A/C 左起「叶→字母→文案」，B 为「文案→字母→叶」。
/// 文案相对装饰的位移：`OnboardingWidthAdapt` 的 block*（见 `onboarding_width_adapt.dart`）。
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.widthAdapt,
    this.blockIndex = 0,
  });

  final OnboardingOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final int blockIndex;
  final OnboardingWidthAdapt widthAdapt;

  @override
  Widget build(BuildContext context) {
    final bool isBlockB = blockIndex == 1;
    final double textLeftPad = isBlockB
        ? (_kOptionBlockBLeadingExtra + widthAdapt.blockBLeadingExtra)
        : (blockIndex == 0
              ? widthAdapt.blockALeadingExtra
              : widthAdapt.blockCLeadingExtra);
    final double textRightPad = isBlockB
        ? (_kOptionBlockACTrailingPadding + widthAdapt.blockBTrailingExtra)
        : _kOptionBlockACTrailingPadding;

    // 抵消选项区外层 horizontal padding，使叶图缘对齐安全区内的屏幕左/右缘（再叠 [_kOnboardingLeafEdgeBleed]）。
    // 平板 `contentMaxWidth` 居中栏时，还要再吃掉栏外左右对称留白，否则叶停在 540 栏边而非屏边。
    //贴边属性是设置MediaQuery.paddingOf(context)的left和right 设置成0 就能贴边
    
    final mq = MediaQuery.paddingOf(context);
    final double screenW = MediaQuery.sizeOf(context).width;
    final double contentColW = widthAdapt.contentMaxWidth == null
        ? screenW
        : math.min(widthAdapt.contentMaxWidth!, screenW);
    final double horizontalContentInset =
        math.max(0.0, (screenW - contentColW) / 2);
    final double leafPullLayers =
        widthAdapt.optionsHorizontalPadding + _kOnboardingLeafEdgeBleed;
    final Offset leafTranslateLeft = Offset(
      mq.left - leafPullLayers - horizontalContentInset,
      0,
    );
    final Offset leafTranslateRight = Offset(
      leafPullLayers - mq.right + horizontalContentInset,
      0,
    );

    final Widget textColumn = Column(
      crossAxisAlignment: isBlockB
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _kOptionTitleAreaHeight,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment:
                  isBlockB ? Alignment.topRight : Alignment.topLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment:
                    isBlockB ? Alignment.topRight : Alignment.topLeft,
                child: Text(
                  option.title,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: isBlockB ? TextAlign.right : TextAlign.left,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  strutStyle: StrutStyle(
                    fontSize: _kOptionTitleSize,
                    fontWeight: _kOptionTitleWeight,
                    fontStyle: FontStyle.italic,
                    height: 1.0,
                    leading: 0,
                    forceStrutHeight: true,
                  ),
                  style: FontManager.customFontWithColor(
                    size: _kOptionTitleSize,
                    color: isSelected
                        ? _kOptionTitleColorSelected
                        : _kOptionTitleColor,
                    weight: _kOptionTitleWeight,
                    style: FontStyle.italic,
                  ).copyWith(height: 1.0),
                ),
              ),
            ),
          ),
        ),
        // 【调参】布局缝：[_kOptionGapTitleToDesc]；视觉再上移：[_kOptionDescVisualPullTowardTitle]
        const SizedBox(height: _kOptionGapTitleToDesc),
        Transform.translate(
          offset: Offset(0, -_kOptionDescVisualPullTowardTitle),
          child: SizedBox(
            height: _kOptionDescAreaHeight,
            child: Align(
              alignment: isBlockB ? Alignment.topRight : Alignment.topLeft,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: isBlockB
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: option.description
                      .replaceAll(r'\n', '\n')
                      .split('\n')
                      .map(
                        (line) => Padding(
                          // 【调参】描述行间距；首行与标题距离主要改顶部 [_kOptionDescVisualPullTowardTitle] / [_kOptionGapTitleToDesc]。
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            line,
                            textAlign:
                                isBlockB ? TextAlign.right : TextAlign.left,
                            // 【调参】小字行高：与下方 StrutStyle.height 保持一致，略减更紧。
                            textHeightBehavior: const TextHeightBehavior(
                              applyHeightToFirstAscent: false,
                              applyHeightToLastDescent: false,
                            ),
                            strutStyle: StrutStyle(
                              fontSize: _kOptionDescSize,
                              fontWeight: _kOptionDescWeight,
                              height: 1.1,
                              leading: 0,
                              forceStrutHeight: true,
                            ),
                            style: FontManager.customFontWithColor(
                              size: _kOptionDescSize,
                              color: _kOptionDescColor,
                              weight: _kOptionDescWeight,
                            ).copyWith(height: 1.1),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Padding(
          // 叶贴列边缘：A/C 去掉左内边距、B 去掉右内边距，其余边保留点击留白
          padding: isBlockB
              ? EdgeInsets.fromLTRB(
                  _kOptionTilePaddingBase,
                  _kOptionTilePaddingBase,
                  0,
                  _kOptionTilePaddingBase,
                )
              : EdgeInsets.fromLTRB(
                  0,
                  _kOptionTilePaddingBase,
                  _kOptionTilePaddingBase,
                  _kOptionTilePaddingBase,
                ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isBlockB) ...[
                Transform.translate(
                  offset: leafTranslateLeft,
                  child: const _OnboardingLeafDeco(pointLeft: true),
                ),
                const SizedBox(width: _kOnboardingDecoGap),
                _OnboardingLetterDeco(blockIndex: blockIndex),
                const SizedBox(width: _kOnboardingDecoGap),
              ],
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: textLeftPad,
                    right: textRightPad,
                  ),
                  child: textColumn,
                ),
              ),
              if (isBlockB) ...[
                const SizedBox(width: _kOnboardingDecoGap),
                _OnboardingLetterDeco(blockIndex: blockIndex),
                const SizedBox(width: _kOnboardingDecoGap),
                Transform.translate(
                  offset: leafTranslateRight,
                  child: const _OnboardingLeafDeco(pointLeft: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingLeafDeco extends StatelessWidget {
  const _OnboardingLeafDeco({required this.pointLeft});

  /// true：A/C 左侧小叶；false：B 右侧小叶（用 leaf_right）。
  final bool pointLeft;

  @override
  Widget build(BuildContext context) {
    final path = pointLeft
        ? ResourceManager.onboarding.leafLeft
        : ResourceManager.onboarding.leafRight;
    return Image.asset(
      path,
      height: _kOnboardingDecoLeafHeight,
      fit: BoxFit.fitHeight,
      alignment: pointLeft ? Alignment.centerLeft : Alignment.centerRight,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: _kOnboardingDecoLeafHeight,
        width: 64,
        child: Icon(
          Icons.eco_outlined,
          size: 64,
          color: Colors.green.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _OnboardingLetterDeco extends StatelessWidget {
  const _OnboardingLetterDeco({required this.blockIndex});

  final int blockIndex;

  @override
  Widget build(BuildContext context) {
    final path = switch (blockIndex) {
      0 => ResourceManager.onboarding.optA,
      1 => ResourceManager.onboarding.optB,
      _ => ResourceManager.onboarding.optC,
    };
    final String fallbackLetter = String.fromCharCode(
      'A'.codeUnitAt(0) + blockIndex.clamp(0, 2),
    );
    return Image.asset(
      path,
      height: _kOnboardingDecoLetterHeight,
      fit: BoxFit.fitHeight,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: _kOnboardingDecoLetterHeight,
        width: 32,
        child: Center(
          child: Text(
            fallbackLetter,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF234434).withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
