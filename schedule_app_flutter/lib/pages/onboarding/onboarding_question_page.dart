import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/resource_manager.dart';
import '../../utils/font_manager.dart';
import '../../models/onboarding_question.dart';

// =============================================================================
// V1 三选项页：设计说明（为什么不同设备容易「对不齐 / 溢出 / 换行不一样」）
// =============================================================================
// 当前实现是「整屏背景图 + 叠文字」：
//   - 背景是一张带水彩叶子 + A/B/C 装饰字母的位图，`BoxFit.cover` 铺满屏幕。
//   - cover 会按屏幕宽高比裁切，字母在图里的像素位置不变，但相对屏幕边缘的位置会变。
//   - 文案区用固定 dp（如 `_kOptionBlockALeadingExtra`）去「躲」背景字母，这些数是在
//     某一版设计稿分辨率上调出来的，换长屏/折叠/平板时，图裁切变了，文字与字母就容易岔开。
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
// 左右 —— 三列整体：
//   `_kOptionsHorizontalPadding`  变小 → 整块选项区更贴屏幕左右、列更宽；变大 → 列更窄、更居中。
//
// 左右 —— 单块内部（与背景 A/B/C 对齐）：
//   `_kOptionBlockALeadingExtra` / `_kOptionBlockCLeadingExtra`  第 1、3 块各自左侧再加多少。
//                                   变小 → 该块文案左移；变大 → 右移（可与 A、C 设不同值）。
//   `_kOptionBlockBLeadingExtra`    第 2 块（B）左侧额外推距；变小 → B 整体左移。
//   `_kOptionBlockACTrailingPadding`  A/C 的右侧内边距；B 也用它作靠右一侧的基础值。
//   `_kOptionBlockBTrailingExtra`   仅 B：右侧再加的留白；变小 → B 文案左移、区变宽。
//   `_kOptionTilePaddingBase`       每块上下 + 左右计算的基准（一般不用动）。
//
// 上下 —— 三列整体在滚动区里：
//   `_kOptionsTopPadding`           默认上边距；单题可覆盖：见 `onboarding_v1_data.dart` 的 `optionsTopPadding`。
//   `_kBlockGapAfterFirst` / `_kBlockGapAfterSecond`  第 1-2、2-3 块之间的竖缝；单题可覆盖 `gapAfterFirst/Second`。
//   气泡与第一块选项的间距：在 `OnboardingQuestionPage.build` 里找 `SizedBox(height: 5)`（注释写明的那行）。
//
// 上下 —— 单块高度（避免溢出必看）：
//   `_kOptionTitleAreaHeight` / `_kOptionDescAreaHeight` / `_kOptionTilePaddingBase*2`(上下)
//   三者之和 + 间距 `_kOptionGapTitleToDesc` = `_kOptionSlotMinHeight`；外层槽高不得小于它。
//   单题更高描述：`onboarding_v1_data.dart` 里该题的 `slotHeight` ≥ `_kOptionSlotMinHeight`。
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
// 大字所在区域高度（需容纳 32sp 标题在略大字号/斜体下的行高，避免 RenderFlex 溢出）
const double _kOptionTitleAreaHeight = 52.0;

// ----- 小字（选项描述，固定高度区域，在大字正下方）------
const double _kOptionDescSize = 13.0;
const Color _kOptionDescColor = Color(0xFF234434);
const FontWeight _kOptionDescWeight = FontWeight.normal;
/// 小字区高度：多行描述 + 模拟器较大 textScale 时仍需可滚动浏览
const double _kOptionDescAreaHeight = 88.0;
const double _kOptionGapTitleToDesc = 4.0;

// ----- 单块选项卡片内边距（与背景图里 A/B/C 位置对齐的核心参数，见文件头「怎么移动」）-----
/// 卡片内上下左右共用的基准 padding（竖直方向全用此值）。
const double _kOptionTilePaddingBase = 12.0;
/// 三个选项之第一个选项 第 1 块（A）：[左侧] 在基准上再加的位移。**增大 → 整块文案右移**。
const double _kOptionBlockALeadingExtra = 128.0;
/// 三个选项之第二个选项 第 2 块（B）：[左侧] 额外位移。**减小 → B 左移**（与 [_kOptionBlockBTrailingExtra] 一起调）。
const double _kOptionBlockBLeadingExtra = 0.0;
/// 三个选项之第三个选项 第 3 块（C）：[左侧] 在基准上再加的位移。**增大 → 整块文案右移**。
const double _kOptionBlockCLeadingExtra = 128.0;
/// 第 1、3 块的 [右侧] 内边距。第 2 块右侧 = 本值 + [_kOptionBlockBTrailingExtra]。
const double _kOptionBlockACTrailingPadding = 4.0;
/// 第 2 块（B）在右侧多留的空。**增大 → B 文案整体左移**；减小 → 更靠右、区更宽。
/// 三个选项之第二个选项（B 为右对齐；左移主要靠调大本值；当前 96。）
const double _kOptionBlockBTrailingExtra = 130.0;

/// 与 [_OptionTile] 内上下 padding（2 × [_kOptionTilePaddingBase]）一致，槽高必须包含
const double _kOptionTileVerticalPadding =
    _kOptionTilePaddingBase + _kOptionTilePaddingBase;
/// 单块「外包装」高度下限：= 内部上下 padding + 标题区 + 间距 + 描述区。
/// 外层 `SizedBox(height: slotHeight)` **不得小于**此值，否则内部 Column 会溢出
/// （例如 slotHeight=157 → 扣掉 24 后只剩 133，而子项需要 52+4+88=144，正好溢出 11px）。
const double _kOptionSlotMinHeight =
    _kOptionTileVerticalPadding +
    _kOptionTitleAreaHeight +
    _kOptionGapTitleToDesc +
    _kOptionDescAreaHeight;
/// 默认槽高；某题描述更多时可在数据里传更大的 `slotHeight`
const double _kOptionSlotHeight = _kOptionSlotMinHeight;

/// 选项区整体距顶（改小=三块在滚动区内整体上移）
const double _kOptionsTopPadding = 5.0;
/// 第 1 块与第 2 块之间的间距（改大=第二块多下移）
const double _kBlockGapAfterFirst = 0.0;
/// 第 2 块与第 3 块之间的间距（改大=第三块多下移）
const double _kBlockGapAfterSecond = 20.0;
/// 滚动区内三列选项相对屏幕左右的留白（对称）。**改小 = 整列更宽、更贴边；改大 = 更窄、更居中。**
const double _kOptionsHorizontalPadding = 32.0;

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

    return MediaQuery(
      data: mq.copyWith(textScaler: clampedScaler),
      child: Stack(
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
            // 气泡区域 ↔ 下方选项列表 的竖直间距（改小=选项整体上移；与文件头「怎么移动」一致）
            const SizedBox(height: 5),
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
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.arrow_back,
          size: 24,
          color: Colors.green.shade300,
        ),
      ),
    );
  }
}

/// 选项行：标题+描述在固定槽内；第 1、3 块左对齐，第 2 块右对齐（与背景图 A/B/C 位置配套）。
/// 左右位移请改文件顶部 `_kOptionBlockALeadingExtra` / `B` / `C` 等常量，勿在此写魔法数。
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
    final bool isBlockB = blockIndex == 1;
    final double leadingExtra = blockIndex == 0
        ? _kOptionBlockALeadingExtra
        : blockIndex == 1
            ? _kOptionBlockBLeadingExtra
            : _kOptionBlockCLeadingExtra;
    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      _kOptionTilePaddingBase + leadingExtra,
      _kOptionTilePaddingBase,
      _kOptionBlockACTrailingPadding +
          (isBlockB ? _kOptionBlockBTrailingExtra : 0),
      _kOptionTilePaddingBase,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // 去掉点击/悬停时默认的灰色高亮效果
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Padding(
          padding: contentPadding,
          child: Column(
            crossAxisAlignment:
                isBlockB ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题必须单行完整可见：窄屏/大左右缩进时用 FittedBox 整体缩小，禁止换行与省略号
              SizedBox(
                height: _kOptionTitleAreaHeight,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: isBlockB
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: isBlockB
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        option.title,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: isBlockB
                            ? TextAlign.right
                            : TextAlign.left,
                        style: FontManager.customFontWithColor(
                          size: _kOptionTitleSize,
                          color: isSelected
                              ? _kOptionTitleColorSelected
                              : _kOptionTitleColor,
                          weight: _kOptionTitleWeight,
                          style: FontStyle.italic,
                        ).copyWith(height: 1.05),
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
                    crossAxisAlignment: isBlockB
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
                              textAlign: isBlockB
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: FontManager.customFontWithColor(
                                size: _kOptionDescSize,
                                color: _kOptionDescColor,
                                weight: _kOptionDescWeight,
                              ).copyWith(height: 1.35),
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
  }
}
