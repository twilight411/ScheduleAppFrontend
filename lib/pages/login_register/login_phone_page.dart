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

  // ===== 字体大小统一出口 =====
  // 想调登录页上各块文字大小，只改下面这些常量即可：
  static const double _kGreetingTextSize = 35.0;        // 顶部「你好, 昵称」
  static const double _kDefaultPhoneLabelSize = 14.0;    // 「默认手机号」小字
  static const double _kDefaultPhoneNumberSize = 38.0;   // 中间脱敏手机号
  static const double _kOneClickButtonTextSize = 17.0;   // 「一键登录/注册」按钮文字
  static const double _kOtherPhoneTextSize = 15.0;       // 「其他手机号登录」文字
  static const double _kAgreementTextSize = 13.0;        // 底部协议说明文字

  // ===== 布局位置统一出口 =====
  // 想调整登录页上各块文字/按钮的位置（上下/左右），优先改下面这些常量。
  // 垂直方向（高度相关）
  static const double _kGreetingTopSpacer = 200.0;        // SafeArea 顶部到底部「你好, 昵称」之间的距离
  static const double _kAfterGreetingToPhoneBlockSpacer =
      160.0;                                             // 「你好, 昵称」到底部手机号块之间的距离（改小 = 手机号整体上移）
  static const double _kBetweenLabelAndPhoneSpacer = 8.0; // 「默认手机号」和号码之间的竖直间距
  static const double _kBetweenButtonAndOtherPhoneSpacer =
      20.0;                                              // 「一键登录/注册」和「其他手机号登录」之间的竖直间距
  static const double _kAfterButtonsToAgreementSpacer =
      32.0;                                              // 按钮区域到底部协议区域之间的距离
  static const double _kAgreementBottomSpacer = 24.0;     // 协议说明文字到底部安全区之间的距离

  // 水平方向（左右相关）
  static const double _kGreetingHorizontalPadding = 28.0;  // 「你好, 昵称」左右边距
  static const double _kButtonsHorizontalPadding = 32.0;   // 按钮区域左右边距
  static const double _kAgreementHorizontalPadding = 28.0; // 协议区域左右边距

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
                SizedBox(height: _kGreetingTopSpacer),
                // 左上偏中：你好, 昵称
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kGreetingHorizontalPadding,
                  ),
                  child: Text(
                    '你好, ${nickname.isEmpty ? '——' : nickname}',
                    style: FontManager.customFontWithColor(
                      size: _kGreetingTextSize, // 顶部欢迎语字号
                      color: _white,
                      weight: FontWeight.bold,
                    ),

                  ),
                ),
                SizedBox(height: _kAfterGreetingToPhoneBlockSpacer),
                // 默认手机号 + 脱敏号：下移且居中
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '默认手机号',
                        style: FontManager.customFontWithColor(
                          size: _kDefaultPhoneLabelSize, // 「默认手机号」小字字号
                          color: _darkGray,
                          weight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: _kBetweenLabelAndPhoneSpacer),
                      Text(
                        defaultPhoneMasked,
                        style: FontManager.customFontWithColor(
                          size: _kDefaultPhoneNumberSize, // 中间脱敏手机号字号
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kButtonsHorizontalPadding,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!agreed) {
                              // 弹出模态框，引导用户勾选协议
                              showDialog<void>(
                                context: context,
                                barrierDismissible:
                                    false, // 必须点按钮明确选择
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('提示'),
                                    content: const Text('请先阅读并同意服务条款和隐私协议'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(); // 只是关闭弹窗
                                        },
                                        child: const Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // 用户选择同意：先勾选协议，再继续登录流程
                                          onAgreementChanged(true);
                                          Navigator.of(ctx).pop();
                                          onOneClickLogin();
                                        },
                                        child: const Text('同意并继续'),
                                      ),
                                    ],
                                  );
                                },
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
                              size: _kOneClickButtonTextSize, // 按钮文字字号
                              color: _white,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: _kBetweenButtonAndOtherPhoneSpacer),
                      Center(
                        child: GestureDetector(
                          onTap: onOtherPhone,
                          child: Text(
                            '其他手机号登录',
                            style: FontManager.customFontWithColor(
                              size: _kOtherPhoneTextSize, // 其他手机号登录文字字号
                              color: _linkGray,
                              weight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: _kAfterButtonsToAgreementSpacer),
                // 底部协议区（背景图已含底部框，仅排文案与勾选）
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kAgreementHorizontalPadding,
                  ),
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
                              size: _kAgreementTextSize, // 协议说明文字字号
                              color: _agreementGray,
                              weight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: _kAgreementBottomSpacer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
