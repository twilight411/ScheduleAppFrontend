import 'package:flutter/material.dart';
import '../../utils/font_manager.dart';
import '../../utils/resource_manager.dart';

/// 03 基本信息 - 身份页：背景图 + 「你现在是」+ 四段散落文字（学生、自由职业者、其他、上班族），无勾选框
class BasicInfoIdentityPage extends StatelessWidget {
  const BasicInfoIdentityPage({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onNext,
    this.showLeftArrow = false,
    this.onLeftArrowTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onNext;
  final bool showLeftArrow;
  final VoidCallback? onLeftArrowTap;

  static const List<String> _options = ['学生', '自由职业者', '其他', '上班族'];

  /// 散落文字颜色（与设计稿一致的浅棕绿）
  static const Color _textColor = Color(0xFF5C6B5C);
  static const Color _green = Color(0xFF234434);

  /// 四个选项的散落位置（占屏幕宽高的比例）。[左, 上]，可微调
  /// 想让四个字整体上移：统一减小下面几行里的「上」这个数值（第二个参数）。
  static const List<List<double>> _positions = [
    [0.18, 0.14], // 学生 - 再稍微靠上，与「你现在是」距离更近
    [0.62, 0.10], // 自由职业者 - 同步上移
    [0.12, 0.30], // 其他 - 同步上移
    [0.58, 0.26], // 上班族 - 同步上移
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ResourceManager.basicInfo.identityBackground,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF5F0E8),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 150), // 调整「你现在是」距顶部的间距（数值越大越靠下）
                Center(
                  child: Text(
                    '你现在是',
                    style: FontManager.customFontWithColor(
                      size: 20,
                      color: _textColor,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (int i = 0; i < _options.length; i++)
                            Positioned(
                              left: w * _positions[i][0],
                              top: h * _positions[i][1],
                              child: GestureDetector(
                                onTap: () => onSelected(i),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    _options[i],
                                    style: FontManager.customFontWithColor(
                                      size: 18,
                                      color: selectedIndex == i
                                          ? _green
                                          : _textColor,
                                      weight: selectedIndex == i
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: showLeftArrow && onLeftArrowTap != null
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: _textColor,
                      size: 22,
                    ),
                    onPressed: onLeftArrowTap,
                  )
                : const SizedBox(),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: selectedIndex >= 0 ? _green : Colors.grey.shade500,
              size: 22,
            ),
            onPressed: selectedIndex >= 0 ? onNext : null,
          ),
        ],
      ),
    );
  }
}
