import 'package:flutter/material.dart';
import '../../utils/font_manager.dart';
import '../../utils/resource_manager.dart';

/// 04 登录注册 - 手机号页：你好{昵称}、默认手机号、一键登录/注册、其他手机号登录、协议勾选
class LoginPhonePage extends StatelessWidget {
  const LoginPhonePage({
    super.key,
    required this.nickname,
    required this.defaultPhoneMasked,
    required this.onOneClickLogin,
    required this.onOtherPhone,
    required this.agreed,
    required this.onAgreementChanged,
  });

  final String nickname;
  final String defaultPhoneMasked;
  final VoidCallback onOneClickLogin;
  final VoidCallback onOtherPhone;
  final bool agreed;
  final ValueChanged<bool> onAgreementChanged;

  static const Color _white = Colors.white;
  static const Color _darkGray = Color(0xFF4A4A4A);
  static const Color _greenBtn = Color(0xFF5A7D5A);
  /// 其他手机号登录、协议文案等浅灰（与目标图一致）
  static const Color _linkGray = Color(0xFF8B7355);
  static const Color _agreementGray = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景已含叶子和底部协议框，不再单独叠加
          Positioned.fill(
            child: Image.asset(
              ResourceManager.loginRegister.background,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF6B8E6B)),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // 左上偏中：你好, 昵称
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    '你好, ${nickname.isEmpty ? '——' : nickname}',
                    style: FontManager.customFontWithColor(
                      size: 28,
                      color: _white,
                      weight: FontWeight.bold,
                    ),

                  ),
                ),
                const SizedBox(height: 380),
                // 默认手机号 + 脱敏号：下移且居中
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '默认手机号',
                        style: FontManager.customFontWithColor(
                          size: 14,
                          color: _darkGray,
                          weight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        defaultPhoneMasked,
                        style: FontManager.customFontWithColor(
                          size: 22,
                          color: const Color(0xFF3D6B3D),
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // 居中：一键登录/注册 + 其他手机号登录
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!agreed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('请先勾选服务条款和隐私协议'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            onOneClickLogin();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: agreed ? _greenBtn : _greenBtn.withOpacity(0.6),
                            foregroundColor: _white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Text(
                            '一键登录/注册',
                            style: FontManager.customFontWithColor(
                              size: 17,
                              color: _white,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: onOtherPhone,
                          child: Text(
                            '其他手机号登录',
                            style: FontManager.customFontWithColor(
                              size: 15,
                              color: _linkGray,
                              weight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // 底部协议区（背景图已含底部框，仅排文案与勾选）
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => onAgreementChanged(!agreed),
                        child: Icon(
                          agreed ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 22,
                          color: _white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: GestureDetector(
                          onTap: () => onAgreementChanged(!agreed),
                          child: Text(
                            '已经阅读并同意服务条款和隐私协议',
                            style: FontManager.customFontWithColor(
                              size: 13,
                              color: _agreementGray,
                              weight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
