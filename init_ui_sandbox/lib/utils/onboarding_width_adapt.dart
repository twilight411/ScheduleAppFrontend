import 'package:flutter/material.dart';

/// V1 引导页布局参数：手机按宽度分档，**平板**（`shortestSide >= 600`）单独一套。
///
/// 手机常见逻辑宽：~360、375–393、**411 Medium Phone / Pixel 9a**、428+。
///
/// **勿仅 Hot Reload**：增删本类字段后须 **Hot Restart**。
@immutable
class OnboardingWidthAdapt {
  const OnboardingWidthAdapt._({
    required this.isTablet,
    required this.optionsHorizontalPadding,
    required this.bubbleSectionHorizontalPadding,
    required this.blockALeadingExtra,
    required this.blockCLeadingExtra,
    required this.blockBTrailingExtra,
    this.blockBLeadingExtra = 0,
    this.optionsExtraTopOffset = 0,
    this.optionsExtraGapBetweenBlocks = 0,
    this.optionsExtraGapAfterFirstOnly = 0,
    this.optionsExtraGapAfterSecondOnly = 0,
    this.optionsScrollTopPaddingExtra = 0,
    this.contentMaxWidth,
    this.arrowRowEdgePadding = 8,
  });

  /// 顶栏左/右箭头距 **屏幕安全区左右边** 的留白（越小越贴边）。平板可略小以「挨边」。
  final double arrowRowEdgePadding;

  /// 非 null 时：气泡+选项区水平 **居中** 且 **最大宽度** 为此值；**顶栏箭头始终全屏宽**。
  /// 手机为 null = 铺满；平板典型 **520–560**。
  final double? contentMaxWidth;

  /// 是否按平板规则选的档（便于以后加调试 UI）。
  final bool isTablet;

  /// 气泡与选项列表之间 **额外** 下移。
  final double optionsExtraTopOffset;

  /// 第 1↔2、2↔3 块之间在数据 `gapAfter*` 之上 **再** 加的竖缝。
  final double optionsExtraGapBetweenBlocks;

  /// 仅在 **第 1 与第 2 块之间** 再额外加高（不影响 B-C）。手机默认 0。
  final double optionsExtraGapAfterFirstOnly;

  /// 仅在 **第 2 与第 3 块之间** 再额外加高（不影响 A-B 间距）。手机默认 0。
  final double optionsExtraGapAfterSecondOnly;

  /// 叠在题目 `optionsTopPadding` / 默认 `_kOptionsTopPadding` 上；**可为负**，负得越多第一块越靠上（与 B-C 相对位置不变）。
  final double optionsScrollTopPaddingExtra;

  final double optionsHorizontalPadding;
  final double bubbleSectionHorizontalPadding;
  final double blockALeadingExtra;
  final double blockCLeadingExtra;
  final double blockBTrailingExtra;

  /// 第 2 块（B）左侧在 [_kOptionTilePaddingBase] 之上 **再** 加多少。
  /// 手机一般为 0；平板可加大，让右对齐的 B 整体 **往左** 收（配合 [blockBTrailingExtra] 减小时更明显）。
  final double blockBLeadingExtra;


//平板三个选项间距以及左右距离调节

  /// 推荐入口：同时考虑宽度与 **平板短边**。
  factory OnboardingWidthAdapt.fromMediaQuery(MediaQueryData mq) {
    if (mq.size.shortestSide >= 600) {
      return const OnboardingWidthAdapt._(
        isTablet: true,
        // 选项区相对中间栏左右留白；增大则 A/B/C 整块离左右边更远（A 也会略右移）。
        optionsHorizontalPadding: 26,
        // 气泡+精灵一行相对中间栏左右留白（与选项列无关）。
        bubbleSectionHorizontalPadding: 10,
        // 字母/叶子已用代码并排；以下为「文案相对装饰」微调（大数值为旧整图背景遗留，宜用小值）。
        // 【第一个选项 A 文案】越大越往右离字母。
        blockALeadingExtra: 12,
        // 【第三个选项 C 文案】越大越往右离字母。
        blockCLeadingExtra: 12,
        // 【第二个选项 B 文案】右侧留白：越大整列标题越往左。
        blockBTrailingExtra: 28,
        // 【第二个选项 B 文案】左侧：越大右对齐文字越往左。
        blockBLeadingExtra: 8,
        // 气泡与选项列表之间额外竖距；减小 → 整块选项更靠上（第一块最明显）；已为 0 则勿再减。
        optionsExtraTopOffset: 0,
        // 【第一块往上】叠在滚动区顶 padding 上，一般为负；越负越靠上（与 optionsTopPadding 相加后不小于 0）。
        optionsScrollTopPaddingExtra: -38,
        // 第 1-2、2-3 块之间额外竖缝（两段都会加同样多）。
        optionsExtraGapBetweenBlocks: 18,
        // 【第二块 B 单独往下】只加在 A 与 B 之间，不影响 B-C；越大 B 越往下。
        optionsExtraGapAfterFirstOnly: 120,
        // 【第三块 C 单独往下】只加在 B 与 C 之间，不影响 A-B；越大 C 越往下。
        optionsExtraGapAfterSecondOnly: 200,
        // 中间内容栏最大宽度（气泡+选项）；只改宽窄不改单块左右时用 contentMaxWidth。
        contentMaxWidth: 540,
        // 顶栏箭头距安全区左右边。
        arrowRowEdgePadding: 10,
      );
    }
    return OnboardingWidthAdapt._phoneFromWidth(mq.size.width);
  }

  /// 仅按宽度（单元测试或忽略平板时）。
  factory OnboardingWidthAdapt.fromWidth(double logicalWidth) =>
      OnboardingWidthAdapt._phoneFromWidth(logicalWidth);

  static OnboardingWidthAdapt _phoneFromWidth(double w) {
    if (w < 365) {
      return const OnboardingWidthAdapt._(
        isTablet: false,
        optionsHorizontalPadding: 20,
        bubbleSectionHorizontalPadding: 14,
        blockALeadingExtra: 8,
        blockCLeadingExtra: 8,
        blockBTrailingExtra: 22,
        optionsExtraGapBetweenBlocks: 0,
        optionsScrollTopPaddingExtra: -10,
      );
    }

    if (w < 395) {
      return const OnboardingWidthAdapt._(
        isTablet: false,
        optionsHorizontalPadding: 26,
        bubbleSectionHorizontalPadding: 17,
        blockALeadingExtra: 10,
        blockCLeadingExtra: 10,
        blockBTrailingExtra: 24,
        optionsExtraGapBetweenBlocks: 0,
        optionsScrollTopPaddingExtra: -12,
      );
    }

    // 395–424dp：含 Pixel 9a（~411）。单屏三选项：少加块间缝、整体上移。
    if (w < 425) {
      return const OnboardingWidthAdapt._(
        isTablet: false,
        optionsHorizontalPadding: 32,
        bubbleSectionHorizontalPadding: 20,
        blockALeadingExtra: 10,
        blockCLeadingExtra: 10,
        blockBTrailingExtra: 26,
        optionsExtraTopOffset: 0,
        optionsExtraGapBetweenBlocks: 0,
        optionsScrollTopPaddingExtra: -14,
      );
    }

    return const OnboardingWidthAdapt._(
      isTablet: false,
      optionsHorizontalPadding: 36,
      bubbleSectionHorizontalPadding: 22,
      blockALeadingExtra: 12,
      blockCLeadingExtra: 12,
      blockBTrailingExtra: 28,
      optionsExtraGapBetweenBlocks: 0,
      optionsScrollTopPaddingExtra: -10,
    );
  }
}
