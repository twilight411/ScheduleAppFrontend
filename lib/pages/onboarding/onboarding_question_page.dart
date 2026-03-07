import 'package:flutter/material.dart';

import '../../utils/resource_manager.dart';
import '../../utils/font_manager.dart';
import '../../models/onboarding_question.dart';

// ========== 调位置 / 换行 说明（V1 三个问题公用） ==========
// 【整体高度 / 间距相关】
// - 气泡 → 第一个选项之间的距离：
//     在 build() 里找 `const SizedBox(height: 16)`，改这个数（改小 = 三块整体更靠上）。
// - 三个选项在滚动区域内部整体上/下：
//     改 `_kOptionsTopPadding`（改小 = 在滚动区内更靠上）。
// - 第 1 个选项和第 2 个选项之间的间距：
//     改 `_kBlockGapAfterFirst`（改大 = 第 2 块更靠下）。
// - 第 2 个选项和第 3 个选项之间的间距：
//     改 `_kBlockGapAfterSecond`（改大 = 第 3 块更靠下）。
// - 单块自身“有多高”（大字 + 小字 + 上下 padding）：
//     细调：改 `_kOptionTitleAreaHeight / _kOptionDescAreaHeight / _kOptionTileVerticalPadding`；
//     粗调：直接改 `_kOptionSlotHeight`，三块一起变高/变矮。
// - 只想对某一道题单独微调（比如第 3 题小字多）：
//     到 `onboarding_v1_data.dart` 里的 `_q1/_q2/_q3` 上设置：
//       - `optionsTopPadding`：本题在滚动区内的上边距；
//       - `gapAfterFirst` / `gapAfterSecond`：本题第 1/2、2/3 块之间的间距；
//       - `slotHeight`：本题每块选项的总高度。
//
// 【左右位置】
// - 三个选项整体左右收紧/放宽：
//     改 `_kOptionsHorizontalPadding`（改小 = 整列更宽）。
// - 每块内部左右偏移、以及 B 块右对齐：
//     在 `_OptionTile` 的 `contentPadding` 里调：
//       - 非中间块的 `100`：改小 = A/C 两块整体更靠左，给小字更多宽度；
//       - `_kBlock2RightInset`：改大 = B 块整体更靠左，对齐右缘。
//
// 【换行】
// - 顶部气泡问题：在 `questionText` 里用 `\n`。
// - 三个选项小字描述：在 `onboarding_v1_data.dart` 的 `description` 里用 `\n`。
// ========== 样式常量（大字 / 小字 分开） ==========
// ----- 大字（选项标题）------
const double _kOptionTitleSize = 32.0;
const Color _kOptionTitleColor = Color(0xFF234434);
const Color _kOptionTitleColorSelected = Color(0xFFEDFFDD);
const FontWeight _kOptionTitleWeight = FontWeight.w600;
// 大字所在区域高度（改大可以避免上下被“切掉”）
const double _kOptionTitleAreaHeight = 40.0;

// ----- 小字（选项描述，固定高度区域，在大字正下方）------
const double _kOptionDescSize = 13.0;
const Color _kOptionDescColor = Color(0xFF234434);
const FontWeight _kOptionDescWeight = FontWeight.normal;
/// 小字区高度：按设计稿够放 4～5 行，不压缩
const double _kOptionDescAreaHeight = 68.0;
const double _kOptionGapTitleToDesc = 4.0;
/// _OptionTile 内部上下 padding 共 24，槽高需包含这部分，否则 Column 会少 24 导致溢出
const double _kOptionTileVerticalPadding = 45.0;
/// 单块总高 = 标题区 + 间距 + 小字区 + 内部上下 padding；三块一致
const double _kOptionSlotHeight =
    _kOptionTitleAreaHeight +
    _kOptionGapTitleToDesc +
    _kOptionDescAreaHeight +
    _kOptionTileVerticalPadding;

/// 选项区整体距顶（改小=三块在滚动区内整体上移）
const double _kOptionsTopPadding = 5.0;
/// 第 1 块与第 2 块之间的间距（改大=第二块多下移）
const double _kBlockGapAfterFirst = 0.0;
/// 第 2 块与第 3 块之间的间距（改大=第三块多下移）
const double _kBlockGapAfterSecond = 20.0;
/// 选项区左右边距（改小=整列更宽）
const double _kOptionsHorizontalPadding = 32.0;
/// 第二块（中间选项）文字右留白，改大 = 整块文字左移，改小 = 整块文字右移
const double _kBlock2RightInset = 120.0;

// 底部小字「我的作息不属于上述3个选项」：改 size / color / weight，且置底
const double _kBottomHintSize = 14.0;
const Color _kBottomHintColor = Color(0xFF688F59); // #688F59

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
    final double slotHeight = item.slotHeight ?? _kOptionSlotHeight;

    return Stack(
      children: [
        // 背景（含叶子和字母，无需单独渲染）
        Positioned.fill(
          child: Image.asset(
            ResourceManager.onboarding.backgroundWithLeavesAndLetters,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              ResourceManager.onboarding.background,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 内容区
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              top: true,
              bottom: false,
              left: true,
              right: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 顶部导航：左箭头 | 空白 | 右箭头
                  SizedBox(
                    height: 40,
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: showLeftArrow
                          ? _ArrowButton(
                              asset: ResourceManager.onboarding.arrowLeft,
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
                              asset: ResourceManager.onboarding.arrowRight,
                              onTap: onRightArrowTap ?? () {},
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 问题区：精灵 + 气泡
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 精灵头像
                    Image.asset(
                      item.spiritAssetPath,
                      width: 64,
                      height: 64,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.face,
                        size: 64,
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
                            errorBuilder: (context, error, stackTrace) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.questionText,
                                style: FontManager.customFontWithColor(
                                  size: 16,
                                  color: Colors.black87,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(28, 16, 20, 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: item.questionText
                                  .replaceAll(r'\n', '\n')
                                  .split('\n')
                                      .map((line) => Text(
                                            line,
                                            textAlign: TextAlign.center,
                                            style: FontManager.customFontWithColor(
                                              size: 16,
                                              color: const Color(0xFF333333),
                                              weight: FontWeight.w500,
                                            ),
                                          ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // 选项整体距上方的间距（改小=第一个选项框整体上移）
            const SizedBox(height: 16),
            // 三个选项：固定高度、不压缩，按设计稿；整区可滚动，避免小屏溢出
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kOptionsHorizontalPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: optionsTopPadding),
                      ...List.generate(
                        item.options.length,
                        (i) => [
                          SizedBox(
                            height: slotHeight,
                            child: _OptionTile(
                              option: item.options[i],
                              isSelected: selectedIndex == i,
                              onTap: () => onOptionSelected(i),
                              blockIndex: i,
                            ),
                          ),
                          if (i < item.options.length - 1)
                            SizedBox(
                              height: i == 0 ? gapAfterFirst : gapAfterSecond,
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
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => onOptionSelected(-1),
                    child: Center(
                      child: Text(
                        item.bottomHint!,
                        style: FontManager.customFontWithColor(
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
      ],
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
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.arrow_back,
          size: 24,
          color: Colors.green.shade300,
        ),
      ),
    );
  }
}

/// 选项行：标题+描述在固定槽内；第一/三块左对齐、第二块右对齐，三块右缘对齐。
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.blockIndex = 0,
  });

  final OnboardingOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final int blockIndex;

  @override
  Widget build(BuildContext context) {
    final bool isRightAligned = blockIndex == 1;
    const double horizontalInset = 12.0;
    // 三块统一左右边距，第二块用右对齐；第二块右留白 _kBlock2RightInset 控制左移/右移
    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      horizontalInset + (isRightAligned ? 10 : 100),
      12,
      horizontalInset - 8 + (isRightAligned ? _kBlock2RightInset : 0),
      12,
    );
    final content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment:
                  isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: _kOptionTitleAreaHeight,
                  child: Align(
                    alignment: isRightAligned
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      // 左右多留一点空白，避免斜体太贴边看起来被“削掉”
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        option.title,
                        textAlign:
                            isRightAligned ? TextAlign.right : TextAlign.left,
                        style: FontManager.customFontWithColor(
                          size: _kOptionTitleSize,
                          color: isSelected
                              ? _kOptionTitleColorSelected
                              : _kOptionTitleColor,
                          weight: _kOptionTitleWeight,
                          style: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: _kOptionGapTitleToDesc),
                SizedBox(
                  height: _kOptionDescAreaHeight,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: isRightAligned
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: option.description
                          .replaceAll(r'\n', '\n')
                          .split('\n')
                          .map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                line,
                                textAlign: isRightAligned
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: FontManager.customFontWithColor(
                                  size: _kOptionDescSize,
                                  color: _kOptionDescColor,
                                  weight: _kOptionDescWeight,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
    return content;
  }
}
