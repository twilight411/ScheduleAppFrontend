import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/resource_manager.dart';
import '../../utils/font_manager.dart';

/// 版本二：单道题的数据（4 个预设 + 1 个自定义）
class V2BubbleOption {
  const V2BubbleOption({required this.title, this.description});

  final String title;
  final String? description;
}

/// 版本二提问页：背景图 + 两行问题 + 5 个圆形气泡（4 预设 + 自定义可编辑）
/// 未选中深绿色，选中浅绿色；自定义点击后可编辑，内容响应式显示
class OnboardingV2QuestionPage extends StatefulWidget {
  const OnboardingV2QuestionPage({
    super.key,
    required this.questionLine1,
    required this.questionLine2,
    required this.presetOptions,
    required this.selectedIndex,
    required this.customText,
    required this.customDescription,
    required this.onSelectionChanged,
    required this.onCustomTextChanged,
    required this.onCustomDescriptionChanged,
    this.showLeftArrow = false,
    this.showRightArrow = true,
    this.onLeftArrowTap,
    this.onRightArrowTap,
  });

  final String questionLine1;
  final String questionLine2;
  final List<V2BubbleOption> presetOptions;
  /// 选中的预设索引 0..3，4 表示选的是自定义，-1 未选
  final int selectedIndex;
  final String customText;
  /// 自定义选项的小字描述，可为空
  final String customDescription;
  final ValueChanged<int> onSelectionChanged;
  final ValueChanged<String> onCustomTextChanged;
  final ValueChanged<String> onCustomDescriptionChanged;
  final bool showLeftArrow;
  final bool showRightArrow;
  final VoidCallback? onLeftArrowTap;
  final VoidCallback? onRightArrowTap;

  @override
  State<OnboardingV2QuestionPage> createState() =>
      _OnboardingV2QuestionPageState();
}

class _OnboardingV2QuestionPageState extends State<OnboardingV2QuestionPage> {
  static const int _kCustomIndex = 4;

  /// 深绿色（未选中）
  static const Color _darkGreen = Color(0xFF1B5E20);
  /// 浅绿色（选中）
  static const Color _lightGreen = Color(0xFF8BC34A);
  /// 描述文字更浅的绿
  static const Color _subGreen = Color(0xFF558B2F);

  // 顶部两行问题文字大小：只影响
  // onboarding_v2_flow_page.dart / onboarding_flow_page.dart 传入的 questionLine1/2
  // 想单独调第四个问题界面的这两行字，就改下面两个数。
  static const double _kQuestionLine1Size = 24.0; // 「如果给你接下来的这一年」
  static const double _kQuestionLine2Size = 24.0; // 「定一个关键词,你希望是」

  bool _customEditing = false;
  final TextEditingController _customController = TextEditingController();
  final FocusNode _customFocus = FocusNode();
  final TextEditingController _customDescController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customController.text = widget.customText;
    _customDescController.text = widget.customDescription;
  }

  @override
  void didUpdateWidget(OnboardingV2QuestionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customText != widget.customText) {
      _customController.text = widget.customText;
    }
    if (oldWidget.customDescription != widget.customDescription) {
      _customDescController.text = widget.customDescription;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    _customFocus.dispose();
    _customDescController.dispose();
    super.dispose();
  }

  void _onPresetTap(int index) {
    widget.onSelectionChanged(index);
    if (_customEditing) {
      setState(() => _customEditing = false);
      _customFocus.unfocus();
    }
    // 点预设关键词后，直接走当前页面的「下一步」逻辑
    widget.onRightArrowTap?.call();
  }

  void _onCustomTap() {
    if (widget.selectedIndex != _kCustomIndex) {
      widget.onSelectionChanged(_kCustomIndex);
    }
    setState(() => _customEditing = true);
    _customFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            ResourceManager.onboarding.v2Background,
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
              _buildQuestion(),
              const SizedBox(height: 32),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildBubbles(constraints.biggest);
                  },
                ),
              ),
            ],
          ),
        ),
        // 自定义编辑时底部弹起的输入区（可选：也可内嵌在气泡下方）
        if (_customEditing) _buildCustomOverlay(),
      ],
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: widget.showLeftArrow
                ? GestureDetector(
                    onTap: widget.onLeftArrowTap,
                    child: Image.asset(
                      ResourceManager.onboarding.arrowLeft,
                      width: 36,
                      height: 36,
                      color: _lightGreen,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const Spacer(),
          SizedBox(
            width: 36,
            height: 36,
            child: widget.showRightArrow
                ? GestureDetector(
                    onTap: widget.onRightArrowTap,
                    child: Image.asset(
                      ResourceManager.onboarding.arrowRight,
                      width: 36,
                      height: 36,
                      color: _lightGreen,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 问题两行字：调位置可改上方 SizedBox(height: 24) 和下方 SizedBox(height: 32) 的数值
  Widget _buildQuestion() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.questionLine1,
            textAlign: TextAlign.center,
            style: FontManager.customFontWithColor(
              size: _kQuestionLine1Size, // 顶部第一行字号
              color: _darkGreen,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.questionLine2,
            textAlign: TextAlign.center,
            style: FontManager.customFontWithColor(
              size: _kQuestionLine2Size, // 顶部第二行字号
              color: _darkGreen,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbles(Size size) {
    final w = size.width;
    final h = size.height;

    // 调位置：改下面 positions 的系数即可。例如 0.22 改大则下移/右移，改小则上移/左移。
    // 四个预设：左上、右上、左下、右下
    final positions = [
      Offset(w * 0.30, h * 0.13), // 突破 左上
      Offset(w * 0.78, h * 0.25), // 修复 右上
      Offset(w * 0.25, h * 0.55), // 探索 左下
      Offset(w * 0.78, h * 0.60), // 稳定 右下
    ];
    // 「自定义」位置：改下面两个系数即可。0.5=水平居中，改小左移、改大右移；0.72=距顶 72%，改小上移、改大下移
    const double kCustomPosX = 0.45;
    const double kCustomPosY = 0.90;
    const optionWidth = 120.0;
    const optionHeight = 56.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (int i = 0; i < widget.presetOptions.length; i++)
          Positioned(
            left: positions[i].dx - optionWidth / 2,
            top: positions[i].dy - optionHeight / 2,
            child: _OptionText(
              title: widget.presetOptions[i].title,
              description: widget.presetOptions[i].description,
              isSelected: widget.selectedIndex == i,
              darkGreen: _darkGreen,
              lightGreen: _lightGreen,
              subGreen: _subGreen,
              onTap: () => _onPresetTap(i),
            ),
          ),
        Positioned(
          left: w * kCustomPosX - optionWidth / 2,
          top: h * kCustomPosY - optionHeight / 2,
          child: _CustomOptionText(
            title: widget.customText.isEmpty ? '自定义' : widget.customText,
            description: widget.customDescription,
            isSelected: widget.selectedIndex == _kCustomIndex,
            isEditing: _customEditing,
            darkGreen: _darkGreen,
            lightGreen: _lightGreen,
            subGreen: _subGreen,
            onTap: _onCustomTap,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomOverlay() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      child: Material(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _customController,
                focusNode: _customFocus,
                autofocus: true,
                maxLength: 20,
                inputFormatters: [
                  // 关键词只允许单行输入
                  FilteringTextInputFormatter.deny(RegExp(r'\n')),
                ],
                decoration: InputDecoration(
                  hintText: '输入你的关键词',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                ),
                style: FontManager.customFontWithColor(
                  size: 20,
                  color: _darkGreen,
                  weight: FontWeight.w600,
                ),
                onChanged: (value) =>
                    widget.onCustomTextChanged(value.trim()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customDescController,
                maxLength: 40,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '补充一句小描述（可选）',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                ),
                style: FontManager.customFontWithColor(
                  size: 15,
                  color: _subGreen,
                  weight: FontWeight.normal,
                ),
                onChanged: (value) => widget.onCustomDescriptionChanged(
                  value.trim(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() => _customEditing = false);
                    _customFocus.unfocus();
                    FocusScope.of(context).unfocus();
                    // 自定义填写完成后，直接走当前页面的「下一步」逻辑
                    widget.onRightArrowTap?.call();
                  },
                  child: Text(
                    '完成',
                    style: FontManager.customFontWithColor(
                      size: 16,
                      color: _darkGreen,
                      weight: FontWeight.w600,
                    ),
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

/// 预设选项：仅文字，无圆形背景
class _OptionText extends StatelessWidget {
  const _OptionText({
    required this.title,
    this.description,
    required this.isSelected,
    required this.darkGreen,
    required this.lightGreen,
    required this.subGreen,
    required this.onTap,
  });

  final String title;
  final String? description;
  final bool isSelected;
  final Color darkGreen;
  final Color lightGreen;
  final Color subGreen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = isSelected ? lightGreen : darkGreen;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontManager.customFontWithColor(
                size: 22,        // 第四个问题界面 关键字稍微放大
                color: titleColor,
                weight: FontWeight.w700,
                style: FontStyle.italic, // 斜体
              ),
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              // 描述文字支持在文案中使用 \n 手动换行，
              // 例如 '专注事业/学业，\n寻求跨越' 会强制分成两行。
              ...description!
                  .replaceAll(r'\n', '\n')
                  .split('\n')
                  .map(
                    (line) => Text(
                      line,
                      textAlign: TextAlign.center,
                      style: FontManager.customFontWithColor(
                        size: 17,       // 小字也整体放大一点
                        color: subGreen,
                        weight: FontWeight.normal,
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 自定义选项：仅文字，无圆形背景
class _CustomOptionText extends StatelessWidget {
  const _CustomOptionText({
    required this.title,
    this.description,
    required this.isSelected,
    required this.isEditing,
    required this.darkGreen,
    required this.lightGreen,
    required this.subGreen,
    required this.onTap,
  });

  final String title;
  final String? description;
  final bool isSelected;
  final bool isEditing;
  final Color darkGreen;
  final Color lightGreen;
  final Color subGreen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = isSelected || isEditing ? lightGreen : darkGreen;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontManager.customFontWithColor(
                size: 22, // 和上面四个选项保持一致，略大
                color: titleColor,
                weight: FontWeight.w700,
                style: FontStyle.italic, // 斜体
              ),
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...description!
                  .replaceAll(r'\n', '\n')
                  .split('\n')
                  .map(
                    (line) => Text(
                      line,
                      textAlign: TextAlign.center,
                      style: FontManager.customFontWithColor(
                        size: 17,
                        color: subGreen,
                        weight: FontWeight.normal,
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
