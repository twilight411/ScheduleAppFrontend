import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/font_manager.dart';
import '../../utils/resource_manager.dart';

/// 04 登录注册 - 其他手机号登录页：输入手机号 + 验证码 + 重新发送 + 协议勾选
class LoginOtherPhonePage extends StatefulWidget {
  const LoginOtherPhonePage({
    super.key,
    required this.onVerifySuccess,
  });

  final void Function(String phone) onVerifySuccess;

  @override
  State<LoginOtherPhonePage> createState() => _LoginOtherPhonePageState();
}

class _LoginOtherPhonePageState extends State<LoginOtherPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  int _countdown = 0;
  Timer? _timer;

  static const Color _white = Colors.white;
  static const Color _darkGray = Color(0xFF4A4A4A);
  static const Color _greenBtn = Color(0xFF5A7D5A);
  static const Color _inputBg = Color(0xFFE8F0E8);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) _countdown--;
      });
      if (_countdown <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onResend() {
    if (_countdown > 0) return;
    // 这里实际项目应调用后端发送验证码，目前只做倒计时效果
    _startCountdown();
  }

  void _onSubmit() {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (phone.length == 11 && code.length >= 4) {
      widget.onVerifySuccess(phone);
    }
  }

  void _onLoginTap() {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入正确的手机号'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final code = _codeController.text.trim();
    if (code.length < 4) return;
    _onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ResourceManager.loginRegister.backgroundVerify,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF6B8E6B)),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: _white, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    '获取验证码',
                    style: FontManager.customFontWithColor(
                      size: 28,
                      color: _white,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        onChanged: (_) => setState(() {}),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: '请输入你的手机号',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                          ),
                          counterText: '',
                          filled: true,
                          fillColor: _inputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: FontManager.customFontWithColor(
                          size: 16,
                          color: _darkGray,
                          weight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _codeController,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: '请输入验证码',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                          ),
                          counterText: '',
                          filled: true,
                          fillColor: _inputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: FontManager.customFontWithColor(
                          size: 18,
                          color: _darkGray,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _countdown > 0 ? null : _onResend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _greenBtn,
                        foregroundColor: _white,
                        disabledBackgroundColor: _greenBtn.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        _countdown > 0 ? '重新发送(${_countdown}s)' : '重新发送',
                        style: FontManager.customFontWithColor(
                          size: 16,
                          color: _white,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // 此处不再要求再次勾选协议，只保留顶部首次同意的结果；
                // 如需展示说明，可在背景图或其他位置加静态文案。
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onLoginTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (_phoneController.text.trim().length == 11 &&
                                    _codeController.text.trim().length >= 4)
                                ? _greenBtn
                                : _greenBtn.withOpacity(0.6),
                        foregroundColor: _white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        '登录',
                        style: FontManager.customFontWithColor(
                          size: 17,
                          color: _white,
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
}

