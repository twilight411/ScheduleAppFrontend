import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/font_manager.dart';
import '../../utils/resource_manager.dart';

/// 03 基本信息 - 昵称页：背景图 +「你想让我叫你什么」+ 横线输入
class BasicInfoNicknamePage extends StatefulWidget {
  const BasicInfoNicknamePage({
    super.key,
    required this.nickname,
    required this.onNicknameChanged,
    required this.onNext,
    this.showLeftArrow = false,
    this.onLeftArrowTap,
  });

  final String nickname;
  final ValueChanged<String> onNicknameChanged;
  final VoidCallback onNext;
  final bool showLeftArrow;
  final VoidCallback? onLeftArrowTap;

  @override
  State<BasicInfoNicknamePage> createState() => _BasicInfoNicknamePageState();
}

class _BasicInfoNicknamePageState extends State<BasicInfoNicknamePage> {
  late TextEditingController _controller;

  /// 与设计稿一致的浅棕灰
  static const Color _textColor = Color(0xFF6B5C5C);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nickname);
  }

  @override
  void didUpdateWidget(BasicInfoNicknamePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nickname != widget.nickname &&
        widget.nickname != _controller.text) {
      _controller.text = widget.nickname;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ResourceManager.basicInfo.nicknameBackground,
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
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    '你想让我叫你什么',
                    style: FontManager.customFontWithColor(
                      size: 20,
                      color: _textColor,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onNicknameChanged,
                    maxLength: 20,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\n')),
                    ],
                    decoration: InputDecoration(
                      hintText: '',
                      counterText: '',
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: _textColor, width: 1.5),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: _textColor, width: 1.5),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: _textColor, width: 2),
                      ),
                    ),
                    style: FontManager.customFontWithColor(
                      size: 18,
                      color: _textColor,
                      weight: FontWeight.w500,
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
    final hasText = _controller.text.trim().isNotEmpty;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: widget.showLeftArrow && widget.onLeftArrowTap != null
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: _textColor,
                      size: 22,
                    ),
                    onPressed: widget.onLeftArrowTap,
                  )
                : const SizedBox(),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: hasText ? _textColor : Colors.grey.shade500,
              size: 22,
            ),
            onPressed: hasText ? widget.onNext : null,
          ),
        ],
      ),
    );
  }
}
