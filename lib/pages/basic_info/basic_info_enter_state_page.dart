import 'package:flutter/material.dart';
import '../../utils/font_manager.dart';
import '../../utils/resource_manager.dart';

/// 03 基本信息 - 进入状态页：背景图 +「你是 {昵称}」+「一颗神奇的小种子」+ 种子插画区 +「此刻,你沉入土壤」「而生命正在向上」
class BasicInfoEnterStatePage extends StatelessWidget {
  const BasicInfoEnterStatePage({
    super.key,
    required this.nickname,
    required this.onEnter,
    this.showLeftArrow = false,
    this.onLeftArrowTap,
  });

  final String nickname;
  final VoidCallback onEnter;
  final bool showLeftArrow;
  final VoidCallback? onLeftArrowTap;

  /// 与设计稿一致的棕金色
  static const Color _textColor = Color(0xFF8B7355);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ResourceManager.basicInfo.enterStateBackground,
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
                const SizedBox(height: 32),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: FontManager.customFontWithColor(
                        size: 22,
                        color: _textColor,
                        weight: FontWeight.bold,
                      ),
                      children: [
                        const TextSpan(text: '你是 '),
                        TextSpan(
                          text: nickname.isEmpty ? '——' : nickname,
                          style: FontManager.customFontWithColor(
                            size: 22,
                            color: _textColor,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '一颗神奇的小种子',
                    style: FontManager.customFontWithColor(
                      size: 16,
                      color: _textColor,
                      weight: FontWeight.normal,
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    '此刻,你沉入土壤',
                    style: FontManager.customFontWithColor(
                      size: 15,
                      color: _textColor,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '而生命正在向上',
                    style: FontManager.customFontWithColor(
                      size: 15,
                      color: _textColor,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onEnter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _textColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        '进入',
                        style: FontManager.customFontWithColor(
                          size: 18,
                          color: Colors.white,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
